import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:ruangpeduliapp/data/content_api.dart';
import 'package:ruangpeduliapp/data/donation_api.dart';
import 'package:ruangpeduliapp/data/inventory_api.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const Color _kPink = Color(0xFFF47B8C);
const Color _kPinkLight = Color(0xFFFDE8EC);
const String _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';
const String _model = 'llama-3.3-70b-versatile';

// ─── Model ────────────────────────────────────────────────────────────────────

class _ChatMsg {
  final String text;
  final bool isUser;
  const _ChatMsg({required this.text, required this.isUser});
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ChatbotMasyarakatScreen extends StatefulWidget {
  final int? userId;
  const ChatbotMasyarakatScreen({super.key, this.userId});

  @override
  State<ChatbotMasyarakatScreen> createState() =>
      _ChatbotMasyarakatScreenState();
}

class _ChatbotMasyarakatScreenState extends State<ChatbotMasyarakatScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isLoading = false;
  bool _loadingContext = true;
  bool _loadingNearest = false;
  bool _loadingUrgent = false;

  List<PantiProfileModel> _pantiList = [];
  final List<Map<String, String>> _history = [];

  final _picker = ImagePicker();
  final _stt = SpeechToText();
  bool _sttReady = false;
  bool _listening = false;

  static const _kMsgKey = 'masyarakat_chat_messages';
  static const _kTsKey  = 'masyarakat_chat_timestamp';

  static const _kWelcome = 'Halo 👋\n'
      'Terima kasih atas niat baik Anda untuk membantu.\n'
      'Saya dapat membantu menunjukkan kebutuhan paling mendesak dari panti yang membutuhkan saat ini.\n'
      'Apakah Anda ingin mengetahui kebutuhan prioritas sekarang?';

  final List<_ChatMsg> _messages = [
    const _ChatMsg(text: _kWelcome, isUser: false),
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _initContext();
    _initStt();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_kTsKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - ts > const Duration(hours: 24).inMilliseconds) {
      await prefs.remove(_kMsgKey);
      await prefs.remove(_kTsKey);
      return;
    }
    final raw = prefs.getStringList(_kMsgKey);
    if (raw == null || raw.isEmpty) return;
    final loaded = raw.map((s) {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return _ChatMsg(text: m['text'] as String, isUser: m['isUser'] as bool);
    }).toList();
    if (mounted) setState(() { _messages..clear()..addAll(loaded); });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _messages.map((m) => jsonEncode({'text': m.text, 'isUser': m.isUser})).toList();
    await prefs.setStringList(_kMsgKey, raw);
    await prefs.setInt(_kTsKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _initContext() async {
    final buffer = StringBuffer();
    buffer.writeln(
      'Kamu adalah asisten AI khusus untuk aplikasi RuangPeduli, platform donasi panti asuhan di Indonesia.\n'
      '\n'
      'ATURAN MUTLAK — TIDAK BOLEH DILANGGAR:\n'
      '1. Kamu HANYA boleh menjawab pertanyaan yang berkaitan langsung dengan RuangPeduli, yaitu:\n'
      '   - Informasi panti asuhan yang terdaftar di RuangPeduli\n'
      '   - Kebutuhan barang, inventaris, dan stok panti\n'
      '   - Donasi: cara berdonasi, jumlah donasi, riwayat donasi pengguna\n'
      '   - Informasi kontak dan lokasi panti asuhan\n'
      '2. Jika pengguna bertanya tentang topik APA PUN di luar daftar di atas — termasuk namun tidak terbatas pada: '
      'matematika, sains, teknologi umum, politik, hiburan, kesehatan umum, resep masakan, olahraga, cuaca, '
      'atau topik umum lainnya — kamu WAJIB menolak dan TIDAK BOLEH menjawab pertanyaan tersebut.\n'
      '3. Saat menolak, gunakan respons ini persis: '
      '"Maaf, saya hanya dapat membantu pertanyaan seputar RuangPeduli dan panti asuhan. '
      'Ada yang bisa saya bantu terkait donasi atau kebutuhan panti?"\n'
      '\n'
      'Jawab dalam Bahasa Indonesia yang ramah dan informatif. Jangan gunakan tabel kecuali diminta.',
    );

    try {
      final pantiList = await ProfileApi().fetchAllPanti();
      if (pantiList.isNotEmpty) {
        _pantiList = pantiList;
        buffer.writeln('\n=== DATA PANTI ASUHAN YANG TERDAFTAR ===');
        for (final p in pantiList) {
          buffer.writeln('- ${p.namaPanti} | Lokasi: ${p.alamatPanti} | Telp: ${p.nomorPanti} | Dana terkumpul: ${p.formattedTotalTerkumpul} | Koordinat: ${p.lat ?? "-"},${p.lng ?? "-"}');
        }

        // Load kebutuhan (wishlist items posted by each panti)
        try {
          final allKebutuhan = await KebutuhanApi().fetchAllKebutuhan();
          if (allKebutuhan.isNotEmpty) {
            buffer.writeln('\n=== KEBUTUHAN BARANG PER PANTI ===');
            // group by panti
            final grouped = <String, List<KebutuhanItemModel>>{};
            for (final k in allKebutuhan) {
              grouped.putIfAbsent(k.pantiName, () => []).add(k);
            }
            for (final entry in grouped.entries) {
              buffer.writeln('${entry.key}:');
              for (final item in entry.value) {
                buffer.writeln('  - ${item.nama} (${item.jumlah} ${item.satuan})');
              }
            }
          } else {
            buffer.writeln('\n=== KEBUTUHAN BARANG PER PANTI ===\n(belum ada data kebutuhan)');
          }
        } catch (_) {}

        // Load inventory alert data for each panti
        buffer.writeln('\n=== STATUS INVENTARIS PER PANTI ===');
        bool anyInventory = false;
        for (final p in pantiList) {
          try {
            final categories = await InventoryApi().fetchCategories(p.id);
            if (categories.isNotEmpty) {
              anyInventory = true;
              final urgent = categories.where((c) => c.hasAlert).toList();
              final normal = categories.where((c) => !c.hasAlert).toList();
              buffer.writeln('${p.namaPanti}:');
              if (urgent.isNotEmpty) {
                buffer.writeln('  [MENDESAK] ${urgent.map((c) => '${c.name} (tersedia: ${c.availableCount}/${c.itemCount})').join(', ')}');
              }
              if (normal.isNotEmpty) {
                buffer.writeln('  [CUKUP] ${normal.map((c) => c.name).join(', ')}');
              }
            }
          } catch (_) {}
        }
        if (!anyInventory) {
          buffer.writeln('(belum ada data inventaris)');
        }
      }
    } catch (_) {}

    // User's own donation summary
    if (widget.userId != null) {
      try {
        final donations = await DonationApi().fetchDonations(widget.userId!);
        final totalInt = donations.fold<int>(0, (sum, d) => sum + d.jumlah);
        final pantiSet = donations.map((d) => d.namaPanti).toSet();
        final formatted = _formatRp(totalInt);
        buffer.writeln('\n=== RIWAYAT DONASI PENGGUNA INI ===');
        buffer.writeln('Total donasi: Rp$formatted');
        buffer.writeln('Jumlah transaksi: ${donations.length}');
        if (pantiSet.isNotEmpty) {
          buffer.writeln('Panti yang pernah didonasi: ${pantiSet.join(', ')}');
        } else {
          buffer.writeln('Belum pernah berdonasi.');
        }
      } catch (_) {}
    }

    _history.add({'role': 'system', 'content': buffer.toString()});
    if (mounted) setState(() => _loadingContext = false);
  }

  // ── Suggestion: nearest panti ──────────────────────────────────────────────

  Future<void> _onSuggestNearest() async {
    if (_loadingNearest || _isLoading || _loadingContext) return;
    setState(() => _loadingNearest = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _sendSilent('Panti mana yang paling dekat dengan saya?', 'Panti terdekat');
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        _sendSilent('Panti mana yang paling dekat dengan saya?', 'Panti terdekat');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      ).timeout(const Duration(seconds: 10));

      final withDist = <MapEntry<PantiProfileModel, double>>[];
      for (final p in _pantiList) {
        if (p.lat != null && p.lng != null) {
          final d = Geolocator.distanceBetween(pos.latitude, pos.longitude, p.lat!, p.lng!);
          withDist.add(MapEntry(p, d));
        }
      }
      withDist.sort((a, b) => a.value.compareTo(b.value));

      String hiddenContext;
      if (withDist.isEmpty) {
        hiddenContext = 'Panti mana yang paling dekat dengan saya?';
      } else {
        final top = withDist.take(3).toList();
        final buf = StringBuffer('Lokasi saya saat ini: ${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}.\n'
            'Berdasarkan koordinat ini, berikut panti terdekat:\n');
        for (final e in top) {
          final km = (e.value / 1000).toStringAsFixed(1);
          buf.writeln('- ${e.key.namaPanti}: $km km');
        }
        buf.write('Rekomendasikan panti mana yang sebaiknya saya kunjungi atau donasikan dan berikan informasi lebih lanjut.');
        hiddenContext = buf.toString();
      }
      _sendSilent(hiddenContext, 'Panti terdekat');
    } catch (_) {
      _sendSilent('Panti mana yang paling dekat dengan lokasi saya?', 'Panti terdekat');
    } finally {
      if (mounted) setState(() => _loadingNearest = false);
    }
  }

  // ── Suggestion: urgent needs ────────────────────────────────────────────────

  Future<void> _onSuggestUrgent() async {
    if (_loadingUrgent || _isLoading || _loadingContext) return;
    setState(() => _loadingUrgent = true);
    try {
      final buf = StringBuffer('Data kebutuhan mendesak (stok habis/kritis) terkini per panti:\n');
      bool hasData = false;
      for (final p in _pantiList) {
        try {
          final categories = await InventoryApi().fetchCategories(p.id);
          final urgent = categories.where((c) => c.hasAlert).toList();
          if (urgent.isNotEmpty) {
            hasData = true;
            buf.writeln('- ${p.namaPanti}: ${urgent.map((c) => c.name).join(", ")}');
          }
        } catch (_) {}
      }
      if (!hasData) buf.writeln('(tidak ada data kebutuhan mendesak saat ini)');
      buf.write('\nBerdasarkan data ini, jelaskan panti mana yang paling membutuhkan bantuan segera dan apa yang bisa didonasikan.');
      _sendSilent(buf.toString(), 'Kebutuhan mendesak');
    } catch (_) {
      _sendSilent('Panti mana yang paling membutuhkan bantuan segera saat ini?', 'Kebutuhan mendesak');
    } finally {
      if (mounted) setState(() => _loadingUrgent = false);
    }
  }

  /// Sends [hiddenPrompt] to the AI but only shows [displayLabel] in the chat bubble.
  void _sendSilent(String hiddenPrompt, String displayLabel) {
    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMsg(text: displayLabel, isUser: true));
      _isLoading = true;
    });
    _saveHistory();
    _history.add({'role': 'user', 'content': hiddenPrompt});
    _scrollToBottom();
    _callAI();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                    backgroundColor: _kPinkLight,
                    child: Icon(Icons.camera_alt_rounded, color: _kPink)),
                title: const Text('Ambil Foto',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const CircleAvatar(
                    backgroundColor: _kPinkLight,
                    child: Icon(Icons.photo_library_rounded, color: _kPink)),
                title: const Text('Pilih dari Album',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null || !mounted) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null || !mounted) return;
    _history.add({'role': 'user', 'content': '[Pengguna mengirim gambar]'});
    _scrollToBottom();
  }

  Future<void> _initStt() async {
    final ok = await _stt.initialize(
      onStatus: (s) {
        if ((s == 'done' || s == 'notListening') && mounted) {
          setState(() => _listening = false);
        }
      },
      onError: (e) {
        debugPrint('STT error: ${e.errorMsg}');
        if (mounted) setState(() => _listening = false);
      },
      debugLogging: true,
    );
    if (mounted) setState(() => _sttReady = ok);
    debugPrint('STT initialized: $ok');
  }

  Future<void> _toggleMic() async {
    if (!_sttReady) {
      // Try re-initializing (handles cases where permission was granted after app launch)
      await _initStt();
      if (!_sttReady) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mikrofon tidak tersedia. Pastikan izin mikrofon sudah diberikan di Pengaturan.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    }
    if (_listening) {
      await _stt.stop();
      setState(() => _listening = false);
      return;
    }
    final locales = await _stt.locales();
    String? localeId;
    for (final l in locales) {
      if (l.localeId.startsWith('id')) { localeId = l.localeId; break; }
    }
    localeId ??= locales.isNotEmpty ? locales.first.localeId : null;

    setState(() { _listening = true; _inputCtrl.clear(); });
    await _stt.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() => _inputCtrl.text = result.recognizedWords);
        if (result.finalResult) setState(() => _listening = false);
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      localeId: localeId,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _isLoading || _loadingContext) return;

    setState(() {
      _messages.add(_ChatMsg(text: text, isUser: true));
      _isLoading = true;
    });
    _saveHistory();
    _inputCtrl.clear();
    _history.add({'role': 'user', 'content': text});
    _scrollToBottom();
    await _callAI();
  }

  Future<void> _callAI() async {
    try {
      final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
      if (apiKey.isEmpty || apiKey == 'your_groq_api_key_here') {
        throw Exception('GROQ_API_KEY belum diisi di file .env');
      }

      // Inject a scope reminder before the latest user message so the model
      // cannot "forget" the restriction mid-conversation.
      final messages = List<Map<String, String>>.from(_history);
      final lastUserIdx = messages.lastIndexWhere((m) => m['role'] == 'user');
      if (lastUserIdx != -1) {
        messages.insert(lastUserIdx, {
          'role': 'system',
          'content':
              'Pengingat wajib: Hanya jawab topik RuangPeduli (panti asuhan, donasi, kebutuhan panti, inventaris). '
              'Tolak semua pertanyaan di luar topik tersebut dengan kalimat penolakan yang sudah ditentukan.',
        });
      }

      final res = await http.post(
        Uri.parse(_groqUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.3,
          'max_tokens': 1024,
        }),
      ).timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final reply = data['choices'][0]['message']['content'] as String;
        _history.add({'role': 'assistant', 'content': reply});
        if (!mounted) return;
        setState(() => _messages.add(_ChatMsg(text: reply, isUser: false)));
        _saveHistory();
      } else {
        final err = jsonDecode(res.body);
        throw Exception(err['error']?['message'] ?? 'Status ${res.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _messages.add(_ChatMsg(text: 'Error: $e', isUser: false)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pesan disalin'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatRp(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPinkLight,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            _buildInfoBanner(),
            _buildSuggestionChips(),
            Expanded(
              child: SelectionArea(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == _messages.length) return _buildTypingIndicator();
                    return _buildBubble(_messages[i]);
                  },
                ),
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'AI Chat Bot',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          if (_loadingContext)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: _kPink),
              ),
            ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close_rounded,
                size: 24, color: Color(0xFF1A1A1A)),
          ),
        ],
      ),
    );
  }

  // ── Info banner ────────────────────────────────────────────────────────────

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kPink.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _loadingContext
                  ? 'Memuat data panti asuhan...'
                  : 'AI ini adalah asisten informasi yang membantu donatur mengetahui kebutuhan paling mendesak di panti secara cepat dan akurat. Melalui percakapan singkat, AI akan memberikan informasi terkini mengenai kebutuhan prioritas penghuni, sehingga bantuan dapat disalurkan secara tepat sasaran.',
              style: TextStyle(
                  fontSize: 11.5, color: Colors.grey[700], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // ── Suggestion chips ───────────────────────────────────────────────────────

  Widget _buildSuggestionChips() {
    final disabled = _isLoading || _loadingContext;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          _SuggestionChip(
            icon: _loadingNearest
                ? Icons.hourglass_top_rounded
                : Icons.location_on_rounded,
            label: 'Panti terdekat',
            loading: _loadingNearest,
            disabled: disabled,
            onTap: _onSuggestNearest,
          ),
          const SizedBox(width: 10),
          _SuggestionChip(
            icon: _loadingUrgent
                ? Icons.hourglass_top_rounded
                : Icons.priority_high_rounded,
            label: 'Kebutuhan mendesak',
            loading: _loadingUrgent,
            disabled: disabled,
            onTap: _onSuggestUrgent,
          ),
        ],
      ),
    );
  }

  // ── Typing indicator ───────────────────────────────────────────────────────

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _BotAvatar(),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ],
            ),
            child: const SizedBox(
                width: 40, height: 16, child: _TypingDots()),
          ),
        ],
      ),
    );
  }

  // ── Message bubble ─────────────────────────────────────────────────────────

  Widget _buildBubble(_ChatMsg msg) {
    final isUser = msg.isUser;
    final copyBtn = GestureDetector(
      onTap: () => _copyMessage(msg.text),
      child: Padding(
        padding: EdgeInsets.only(
            left: isUser ? 0 : 4, right: isUser ? 4 : 0, bottom: 2),
        child: Icon(Icons.copy_rounded, size: 15, color: Colors.grey[400]),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[_BotAvatar(), const SizedBox(width: 8)],
          if (isUser) copyBtn,
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? _kPink : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: isUser
                  ? Text(msg.text,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.5))
                  : MarkdownBody(
                      data: msg.text,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1A1A),
                            height: 1.5),
                        strong: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w700),
                        listBullet: const TextStyle(
                            fontSize: 14, color: Color(0xFF1A1A1A)),
                      ),
                    ),
            ),
          ),
          if (!isUser) copyBtn,
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.grey[300]),
              child: const Icon(Icons.person_rounded,
                  color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  // ── Input bar ──────────────────────────────────────────────────────────────

  Widget _buildInputBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text field + send button
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _inputCtrl,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isLoading && !_loadingContext,
                      maxLines: null,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF1A1A1A)),
                      decoration: InputDecoration(
                        hintText: _loadingContext
                            ? 'Memuat data...'
                            : 'Apa yang bisa bantu?',
                        hintStyle: const TextStyle(
                            color: Color(0xFFAAAAAA), fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: (_isLoading || _loadingContext) ? null : _sendMessage,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: (_isLoading || _loadingContext)
                          ? _kPink.withValues(alpha: 0.5)
                          : _kPink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_upward_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Action icons row
            Row(
              children: [
                _ActionIcon(
                  icon: Icons.image_outlined,
                  onTap: _pickImage,
                ),
                const SizedBox(width: 16),
                _ActionIcon(
                  icon: _listening
                      ? Icons.mic_rounded
                      : Icons.mic_none_rounded,
                  color: _listening ? _kPink : const Color(0xFF555555),
                  onTap: _toggleMic,
                ),
              ],
            ),
          ],
        ),
    );
  }
}

// ─── Suggestion Chip ──────────────────────────────────────────────────────────

class _SuggestionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool loading;
  final bool disabled;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.icon,
    required this.label,
    required this.loading,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = !disabled && !loading;
    return GestureDetector(
      onTap: active ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? _kPink : _kPink.withValues(alpha: 0.3),
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _kPink.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            loading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _kPink),
                  )
                : Icon(icon, size: 14, color: _kPink),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? _kPink : _kPink.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bot Avatar ───────────────────────────────────────────────────────────────

class _BotAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        'assets/images/chatbot_ai.png',
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 36,
          height: 36,
          decoration:
              const BoxDecoration(shape: BoxShape.circle, color: _kPink),
          child: const Icon(Icons.auto_awesome_rounded,
              color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

// ─── Action Icon ──────────────────────────────────────────────────────────────

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    this.color = const Color(0xFF555555),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color, size: 22),
    );
  }
}

// ─── Typing Dots ──────────────────────────────────────────────────────────────

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final opacity = ((t * 3 - i) % 1.0).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kPink.withValues(alpha: 0.3 + opacity * 0.7),
              ),
            );
          }),
        );
      },
    );
  }
}
