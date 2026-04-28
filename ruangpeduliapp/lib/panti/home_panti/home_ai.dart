import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:ruangpeduliapp/data/finance_api.dart';
import 'package:ruangpeduliapp/data/inventory_api.dart';
import 'package:ruangpeduliapp/data/residents_api.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const Color kPink = Color(0xFFF28C9F);
const Color kPinkLight = Color(0xFFFDE8EC);

const String _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';
const String _model = 'llama-3.3-70b-versatile';

// ─── Data Model ──────────────────────────────────────────────────────────────

class ChatMessage {
  final String text;
  final bool isUser;
  final String? imagePath;
  const ChatMessage({required this.text, required this.isUser, this.imagePath});
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class HomeAIPanti extends StatefulWidget {
  final int? userId;
  final int? pantiId;
  const HomeAIPanti({super.key, this.userId, this.pantiId});

  @override
  State<HomeAIPanti> createState() => _HomeAIPantiState();
}

class _HomeAIPantiState extends State<HomeAIPanti> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _loadingContext = true;

  final List<Map<String, String>> _history = [];
  static const String _staticPrompt =
      'Kamu adalah Bobi, asisten AI untuk aplikasi RuangPeduli, '
      'sebuah platform manajemen panti asuhan di Indonesia. '
      'Kamu HANYA boleh menjawab pertanyaan yang berkaitan dengan aplikasi RuangPeduli dan operasional panti asuhan, '
      'seperti manajemen penghuni, keuangan, inventaris, pegawai, kebutuhan panti, berita, donasi, dan fitur-fitur dalam aplikasi RuangPeduli. '
      'Jika pengguna bertanya tentang topik di luar RuangPeduli (misalnya politik, hiburan, teknologi umum, atau hal-hal yang tidak berkaitan dengan panti asuhan dan aplikasi ini), '
      'tolak dengan sopan dan arahkan kembali ke topik RuangPeduli. '
      'Contoh penolakan: "Maaf, saya hanya bisa membantu pertanyaan seputar aplikasi RuangPeduli dan operasional panti asuhan. Ada yang bisa saya bantu terkait panti kamu?" '
      'Jawab dalam Bahasa Indonesia yang ramah dan profesional. '
      'HANYA gunakan format tabel Markdown (| Kolom | Kolom |) jika pengguna secara eksplisit meminta laporan keuangan. '
      'Untuk pertanyaan lainnya, jawab dengan teks biasa tanpa tabel.';

  Timer? _contextTimer;

  final _picker = ImagePicker();
  final _stt = SpeechToText();
  bool _sttReady = false;
  bool _listening = false;

  static const _kMsgKey = 'panti_chat_messages';
  static const _kTsKey  = 'panti_chat_timestamp';

  final List<ChatMessage> _messages = [
    const ChatMessage(text: 'Halo! Saya Bobi. Ada yang bisa saya bantu?', isUser: false),
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _initContext();
    _contextTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _refreshContext();
    });
    _stt.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _listening = false);
        }
      },
      onError: (_) { if (mounted) setState(() => _listening = false); },
    ).then((ok) { if (mounted) setState(() => _sttReady = ok); });
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
      return ChatMessage(text: m['text'] as String, isUser: m['isUser'] as bool);
    }).toList();
    if (mounted) setState(() { _messages
      ..clear()
      ..addAll(loaded); });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _messages.map((m) => jsonEncode({'text': m.text, 'isUser': m.isUser})).toList();
    await prefs.setStringList(_kMsgKey, raw);
    await prefs.setInt(_kTsKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<String> _buildDynamicContext() async {
    final buffer = StringBuffer();

    if (widget.userId != null) {
      try {
        final results = await Future.wait([
          FinanceApi().fetchDashboard(widget.userId!),
          FinanceApi().fetchTransactions(widget.userId!),
        ]);
        final dashboard    = results[0] as FinanceDashboard;
        final transactions = results[1] as List<TransactionModel>;

        buffer.writeln('\n=== DATA KEUANGAN PANTI (REAL-TIME) ===');
        buffer.writeln('Total Pemasukan Bulan Ini: Rp ${dashboard.totalPemasukan.toInt()}');
        buffer.writeln('Total Pengeluaran Bulan Ini: Rp ${dashboard.totalPengeluaran.toInt()}');
        buffer.writeln('Saldo Saat Ini: Rp ${dashboard.saldo.toInt()}');
        if (transactions.isNotEmpty) {
          buffer.writeln('\nRiwayat Transaksi Terakhir:');
          for (final tx in transactions.take(10)) {
            final type = tx.isIncome ? 'Pemasukan' : 'Pengeluaran';
            buffer.writeln('- [$type] ${tx.category}: Rp ${tx.jumlah.toInt()} (${tx.tanggal}) - Catatan: ${tx.subLabel.isEmpty ? '-' : tx.subLabel}');
          }
        }
      } catch (_) {}

      try {
        final residents = await Future.wait([
          ResidentsApi().fetchPenghuni(widget.userId!),
          ResidentsApi().fetchPekerja(widget.userId!),
        ]);
        final penghuni = residents[0] as List<PenghuniModel>;
        final pekerja  = residents[1] as List<PekerjaModel>;
        final now      = DateTime.now().year;

        final lakiCount      = penghuni.where((p) => p.jenisKelamin.toLowerCase() == 'laki-laki').length;
        final perempuanCount = penghuni.length - lakiCount;
        final ages           = penghuni.map((p) => now - p.tahunLahir).toList();
        final avgAge         = ages.isEmpty ? 0 : (ages.reduce((a, b) => a + b) / ages.length).round();
        final usiaBawah12    = ages.where((a) => a < 12).length;
        final usia12to17     = ages.where((a) => a >= 12 && a <= 17).length;
        final usiaAtas17     = ages.where((a) => a > 17).length;

        final divisiMap = <String, int>{};
        for (final p in pekerja) {
          divisiMap[p.divisi] = (divisiMap[p.divisi] ?? 0) + 1;
        }

        buffer.writeln('\n=== RINGKASAN PENGHUNI & PEGAWAI ===');
        buffer.writeln('Total Penghuni: ${penghuni.length} orang');
        buffer.writeln('  - Laki-laki: $lakiCount | Perempuan: $perempuanCount');
        buffer.writeln('  - Rata-rata usia: $avgAge tahun');
        buffer.writeln('  - Usia <12 tahun: $usiaBawah12 | 12–17 tahun: $usia12to17 | >17 tahun: $usiaAtas17');
        buffer.writeln('Total Pegawai: ${pekerja.length} orang');
        if (divisiMap.isNotEmpty) {
          buffer.writeln('  - Per divisi: ${divisiMap.entries.map((e) => '${e.key}: ${e.value}').join(', ')}');
        }
      } catch (_) {}
    }

    if (widget.pantiId != null) {
      try {
        final categories = await InventoryApi().fetchCategories(widget.pantiId!);
        buffer.writeln('\n=== DATA INVENTARIS ===');
        buffer.writeln('Jumlah Kategori: ${categories.length}');
        for (final cat in categories) {
          buffer.writeln('- ${cat.name}: ${cat.itemCount} produk (${cat.availableCount} tersedia)');
        }
        final outOfStock = await InventoryApi().fetchOutOfStockItems(widget.pantiId!);
        if (outOfStock.isNotEmpty) {
          buffer.writeln('\nProduk Habis (${outOfStock.length} item):');
          for (final item in outOfStock) {
            buffer.writeln('- ${item.name} (${item.categoryName})');
          }
        }
      } catch (_) {}
    }

    return buffer.toString();
  }

  Future<void> _initContext() async {
    final dynamic = await _buildDynamicContext();
    _history.add({'role': 'system', 'content': '$_staticPrompt$dynamic'});
    if (mounted) setState(() => _loadingContext = false);
  }

  Future<void> _refreshContext() async {
    final dynamic = await _buildDynamicContext();
    if (_history.isNotEmpty) {
      _history[0] = {'role': 'system', 'content': '$_staticPrompt$dynamic'};
    }
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(backgroundColor: kPinkLight, child: Icon(Icons.camera_alt_rounded, color: kPink)),
                title: const Text('Ambil Foto', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: kPinkLight, child: Icon(Icons.photo_library_rounded, color: kPink)),
                title: const Text('Pilih dari Album', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null || !mounted) return;
    setState(() => _messages.add(ChatMessage(text: '', isUser: true, imagePath: picked.path)));
    _history.add({'role': 'user', 'content': '[Pengguna mengirim gambar]'});
    _scrollToBottom();
  }

  Future<void> _toggleMic() async {
    if (!_sttReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mikrofon tidak tersedia di perangkat ini')),
      );
      return;
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
    setState(() { _listening = true; _inputController.clear(); });
    await _stt.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() => _inputController.text = result.recognizedWords);
        if (result.finalResult) setState(() => _listening = false);
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      localeId: localeId,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isLoading || _loadingContext) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _saveHistory();
    _inputController.clear();
    _history.add({'role': 'user', 'content': text});
    _scrollToBottom();

    try {
      final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
      if (apiKey.isEmpty || apiKey == 'your_groq_api_key_here') {
        throw Exception('GROQ_API_KEY belum diisi di file .env');
      }

      final res = await http.post(
        Uri.parse(_groqUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': _history,
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      ).timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final reply = data['choices'][0]['message']['content'] as String;
        _history.add({'role': 'assistant', 'content': reply});
        if (!mounted) return;
        setState(() => _messages.add(ChatMessage(text: reply, isUser: false)));
        _saveHistory();
      } else {
        final err = jsonDecode(res.body);
        throw Exception(err['error']?['message'] ?? 'Status ${res.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _messages.add(ChatMessage(text: 'Error: $e', isUser: false)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _contextTimer?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPinkLight,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            _buildInfoBanner(),
            Expanded(
              child: SelectionArea(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (_, index) {
                    if (index == _messages.length) return _buildTypingIndicator();
                    return _buildMessageBubble(_messages[index]);
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
                child: CircularProgressIndicator(strokeWidth: 2, color: kPink),
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

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPink.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _loadingContext
                  ? 'Bobi sedang memuat data panti kamu...'
                  : 'Bobi sudah terhubung dengan data panti kamu. Tanya apa saja tentang keuangan, inventaris, atau penghuni!',
              style: TextStyle(fontSize: 11.5, color: Colors.grey[700], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 36, height: 36,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: kPink),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18),
                bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4),
              ),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: const SizedBox(width: 40, height: 16, child: _TypingDots()),
          ),
        ],
      ),
    );
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

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final copyBtn = GestureDetector(
      onTap: () => _copyMessage(message.text),
      child: Padding(
        padding: EdgeInsets.only(
          left: isUser ? 0 : 4,
          right: isUser ? 4 : 0,
          bottom: 2,
        ),
        child: Icon(Icons.copy_rounded, size: 15, color: Colors.grey[400]),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            ClipOval(
              child: Image.asset(
                'assets/images/chatbot_ai.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: kPink),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
          if (isUser) copyBtn,
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? kPink : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: isUser && message.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(message.imagePath!), width: 200, fit: BoxFit.cover),
                    )
                  : isUser
                  ? Text(
                      message.text,
                      style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.5),
                    )
                  : MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A), height: 1.5),
                        strong: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A), fontWeight: FontWeight.w700),
                        tableHead: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                        tableBody: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
                        tableBorder: TableBorder.all(color: Color(0xFFDDDDDD), width: 1),
                        tableHeadAlign: TextAlign.center,
                        tableCellsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        tableColumnWidth: const FlexColumnWidth(),
                        listBullet: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                      ),
                    ),
            ),
          ),
          if (!isUser) copyBtn,
          if (isUser)
            Container(
              width: 36, height: 36,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[300]),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(30)),
                    child: TextField(
                      controller: _inputController,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isLoading && !_loadingContext,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                      decoration: InputDecoration(
                        hintText: _loadingContext ? 'Memuat data...' : 'Apa yang bisa bantu?',
                        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: (_isLoading || _loadingContext) ? null : _sendMessage,
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: (_isLoading || _loadingContext) ? kPink.withValues(alpha: 0.5) : kPink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(onPressed: _pickImage, icon: const Icon(Icons.image_outlined, color: Color(0xFF555555), size: 22), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _toggleMic,
                  icon: Icon(
                    _listening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: _listening ? kPink : const Color(0xFF555555),
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
    );
  }
}

// ─── Typing Dots Animation ────────────────────────────────────────────────────

class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final opacity = ((t * 3 - i) % 1.0).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 7, height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPink.withValues(alpha: 0.3 + opacity * 0.7),
              ),
            );
          }),
        );
      },
    );
  }
}
