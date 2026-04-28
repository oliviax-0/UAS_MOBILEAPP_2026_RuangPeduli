import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ruangpeduliapp/masyarakat/transaksi/konfirmasi_metode_screen.dart';

class KonfirmasiPembayaranScreen extends StatefulWidget {
  final String namaPanti;
  final String terkumpul;
  final String imagePath;
  final int? pantiId;
  final int? userId;

  const KonfirmasiPembayaranScreen({
    super.key,
    required this.namaPanti,
    required this.terkumpul,
    required this.imagePath,
    this.pantiId,
    this.userId,
  });

  @override
  State<KonfirmasiPembayaranScreen> createState() =>
      _KonfirmasiPembayaranScreenState();
}

class _KonfirmasiPembayaranScreenState
    extends State<KonfirmasiPembayaranScreen> {
  final _nominalCtrl = TextEditingController(text: '');
  String? _nominalError;

  @override
  void initState() {
    super.initState();
    _nominalCtrl.addListener(_formatNominal);
  }

  // Auto-format: keeps only digits, inserts thousand-separator dots
  void _formatNominal() {
    final raw = _nominalCtrl.text.replaceAll('.', '');
    if (raw.isEmpty) return;
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) buffer.write('.');
      buffer.write(raw[i]);
    }
    final formatted = buffer.toString();
    if (_nominalCtrl.text != formatted) {
      _nominalCtrl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  @override
  void dispose() {
    _nominalCtrl.removeListener(_formatNominal);
    _nominalCtrl.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    if (mounted) setState(() => _nominalError = msg);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _onKonfirmasi() async {
    final raw = _nominalCtrl.text.replaceAll('.', '');
    if (raw.isEmpty) {
      _showError('Masukkan nominal donasi');
      return;
    }
    final nominal = int.tryParse(raw) ?? 0;
    if (nominal < 1000) {
      _showError('Nominal minimal Rp1.000');
      return;
    }
    if (mounted) setState(() => _nominalError = null);

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => KonfirmasiMetodeScreen(
          namaPanti: widget.namaPanti,
          terkumpul: widget.terkumpul,
          imagePath: widget.imagePath,
          nominal: _nominalCtrl.text,
          pantiId: widget.pantiId,
          userId: widget.userId,
        ),
      ),
    );
    if (result == true && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App Bar ──
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back_rounded,
                        size: 22, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Konfirmasi Pembayaran',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pilihan Anda',
                        style: TextStyle(
                            fontSize: 14, color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 10),

                    // ── Panti card ──
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: const Color(0xFFEEEEEE)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _PantiImage(
                                path: widget.imagePath, width: 80, height: 70),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.namaPanti,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A1A1A)),
                                ),
                                const SizedBox(height: 4),
                                Text(widget.terkumpul,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Nominal input ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nominal',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Rp ',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A1A1A))),
                              Expanded(
                                child: TextField(
                                  controller: _nominalCtrl,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A1A1A)),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                              height: 16, color: Color(0xFFEEEEEE)),
                          if (_nominalError != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                _nominalError!,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red.shade400),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // ── Konfirmasi button ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF47B8C),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        onPressed: _onKonfirmasi,
                        child: const Text('Konfirmasi',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PantiImage extends StatelessWidget {
  final String path;
  final double width;
  final double height;
  const _PantiImage(
      {required this.path, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final isNetwork =
        path.startsWith('http://') || path.startsWith('https://');
    if (isNetwork) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    if (path.isEmpty) return _placeholder();
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() => Container(
        width: width,
        height: height,
        color: const Color(0xFFDDCDD0),
        child: Icon(Icons.home_work_rounded,
            size: 32, color: Colors.grey.shade400),
      );
}