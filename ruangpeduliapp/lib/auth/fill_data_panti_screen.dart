import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ruangpeduliapp/auth/auth_widgets.dart';
import 'package:ruangpeduliapp/data/data.dart';
import 'package:ruangpeduliapp/data/regional_api.dart';
import 'package:ruangpeduliapp/auth/verification_screen.dart';
import 'package:ruangpeduliapp/auth/success_screen.dart';

class FillDataPantiScreen extends StatefulWidget {
  final String email;
  final String password;
  final String? googleIdToken;

  const FillDataPantiScreen({
    super.key,
    required this.email,
    required this.password,
    this.googleIdToken,
  });

  @override
  State<FillDataPantiScreen> createState() => _FillDataPantiScreenState();
}

class _FillDataPantiScreenState extends State<FillDataPantiScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  // ── Text controllers ──
  final _namaPantiController = TextEditingController();
  final _jalanController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nomorPantiController = TextEditingController();
  final _kodePosController = TextEditingController();

  // ── Regional cascade state ──
  final _regionalApi = RegionalApi();
  List<ProvinceModel> _provinces = [];
  List<CityModel> _cities = [];
  List<DistrictModel> _districts = [];
  List<VillageModel> _villages = [];

  ProvinceModel? _selectedProvince;
  CityModel? _selectedCity;
  DistrictModel? _selectedDistrict;
  VillageModel? _selectedVillage;

  bool _loadingProvinces = false;
  bool _loadingCities = false;
  bool _loadingDistricts = false;
  bool _loadingVillages = false;

  // ── Validation errors ──
  String? _namaPantiError;
  String? _jalanError;
  String? _provinsiError;
  String? _kotaError;
  String? _kecamatanError;
  String? _kelurahanError;
  String? _usernameError;
  String? _nomorPantiError;
  String? _tncError;
  String? _generalError;

  bool _agreeTnC = true;
  bool _loading = false;
  final _api = AuthApi();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _controller.forward();
    });
    _loadProvinces();
  }

  @override
  void dispose() {
    _controller.dispose();
    _namaPantiController.dispose();
    _jalanController.dispose();
    _usernameController.dispose();
    _nomorPantiController.dispose();
    _kodePosController.dispose();
    super.dispose();
  }

  // ── Load provinces ──
  Future<void> _loadProvinces() async {
    setState(() => _loadingProvinces = true);
    try {
      final list = await _regionalApi.fetchProvinces();
      if (mounted) setState(() { _provinces = list; _loadingProvinces = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingProvinces = false);
    }
  }

  // ── On province selected ──
  Future<void> _onProvinceChanged(ProvinceModel? p) async {
    setState(() {
      _selectedProvince = p;
      _selectedCity = null;
      _selectedDistrict = null;
      _selectedVillage = null;
      _cities = [];
      _districts = [];
      _villages = [];
      _provinsiError = null;
    });
    if (p == null) return;
    setState(() => _loadingCities = true);
    try {
      final list = await _regionalApi.fetchCities(p.id);
      if (mounted) setState(() { _cities = list; _loadingCities = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingCities = false);
    }
  }

  // ── On city selected ──
  Future<void> _onCityChanged(CityModel? c) async {
    setState(() {
      _selectedCity = c;
      _selectedDistrict = null;
      _selectedVillage = null;
      _districts = [];
      _villages = [];
      _kotaError = null;
    });
    if (c == null) return;
    setState(() => _loadingDistricts = true);
    try {
      final list = await _regionalApi.fetchDistricts(c.id);
      if (mounted) setState(() { _districts = list; _loadingDistricts = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingDistricts = false);
    }
  }

  // ── On district selected ──
  Future<void> _onDistrictChanged(DistrictModel? d) async {
    setState(() {
      _selectedDistrict = d;
      _selectedVillage = null;
      _villages = [];
      _kecamatanError = null;
    });
    if (d == null) return;
    setState(() => _loadingVillages = true);
    try {
      final list = await _regionalApi.fetchVillages(d.id);
      if (mounted) setState(() { _villages = list; _loadingVillages = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingVillages = false);
    }
  }

  // ── Submit ──
  void _onSelanjutnya() {
    final username = _usernameController.text.trim();
    final namaPantiErr =
        _namaPantiController.text.isEmpty ? 'Wajib diisi' : null;
    final jalanErr = _jalanController.text.isEmpty ? 'Wajib diisi' : null;
    final provinsiErr = _selectedProvince == null ? 'Wajib dipilih' : null;
    final kotaErr = _selectedCity == null ? 'Wajib dipilih' : null;
    final kecamatanErr = _selectedDistrict == null ? 'Wajib dipilih' : null;
    final kelurahanErr = _selectedVillage == null ? 'Wajib dipilih' : null;
    final usernameErr = username.isEmpty
        ? 'Wajib diisi'
        : (!RegExp(r'[a-zA-Z]').hasMatch(username) ||
                !RegExp(r'\d').hasMatch(username))
            ? 'Username harus mengandung huruf dan angka'
            : null;
    final nomorErr =
        _nomorPantiController.text.isEmpty ? 'Wajib diisi' : null;
    final tncErr =
        !_agreeTnC ? 'Anda harus menyetujui S&K terlebih dahulu' : null;

    setState(() {
      _namaPantiError = namaPantiErr;
      _jalanError = jalanErr;
      _provinsiError = provinsiErr;
      _kotaError = kotaErr;
      _kecamatanError = kecamatanErr;
      _kelurahanError = kelurahanErr;
      _usernameError = usernameErr;
      _nomorPantiError = nomorErr;
      _tncError = tncErr;
      _generalError = null;
    });

    if (namaPantiErr != null || jalanErr != null || provinsiErr != null ||
        kotaErr != null || kecamatanErr != null || kelurahanErr != null ||
        usernameErr != null || nomorErr != null || tncErr != null) {
      return;
    }

    // Build full alamat string
    final alamatFull = [
      _jalanController.text.trim(),
      'Kel. ${_selectedVillage!.name}',
      'Kec. ${_selectedDistrict!.name}',
      _selectedCity!.name,
      _selectedProvince!.name,
      if (_kodePosController.text.trim().isNotEmpty)
        _kodePosController.text.trim(),
    ].join(', ');

    setState(() => _loading = true);

    if (widget.googleIdToken != null) {
      _api.googleRegister(
        idToken: widget.googleIdToken!,
        role: 'panti',
        username: username,
        namaPanti: _namaPantiController.text.trim(),
        alamatPanti: alamatFull,
        nomorPanti: _nomorPantiController.text.trim(),
        provinsiPanti: _selectedProvince!.name,
        kabupatenKotaPanti: _selectedCity!.name,
        kecamatanPanti: _selectedDistrict!.name,
        kelurahanPanti: _selectedVillage!.name,
        kodePosPanti: _kodePosController.text.trim().isNotEmpty
            ? _kodePosController.text.trim()
            : null,
      ).then((result) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => SuccessScreen(
                    role: 'panti',
                    userId: result['user_id'] as int?,
                    pantiId: result['panti_id'] as int?,
                  )),
          (route) => false,
        );
      }).catchError((e) {
        if (!mounted) return;
        setState(() => _generalError = '$e');
      }).whenComplete(() {
        if (mounted) setState(() => _loading = false);
      });
    } else {
      _api.startRegister(RegisterData(
        username: username,
        email: widget.email,
        password: widget.password,
        role: 'panti',
        namaPanti: _namaPantiController.text.trim(),
        alamatPanti: alamatFull,
        nomorPanti: _nomorPantiController.text.trim(),
        provinsiPanti: _selectedProvince!.name,
        kabupatenKotaPanti: _selectedCity!.name,
        kecamatanPanti: _selectedDistrict!.name,
        kelurahanPanti: _selectedVillage!.name,
        kodePosPanti: _kodePosController.text.trim().isNotEmpty
            ? _kodePosController.text.trim()
            : null,
      )).then((pendingId) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationScreen(
              pendingId: pendingId,
              email: widget.email,
              role: 'panti',
            ),
          ),
        );
      }).catchError((e) {
        if (!mounted) return;
        setState(() => _generalError = '$e');
      }).whenComplete(() {
        if (mounted) setState(() => _loading = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFA5B1),
                  Color(0xFFF47B8C),
                  Color(0xFFF43D5E),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Wave
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: size.height * 0.75,
              width: size.width,
              child: CustomPaint(painter: _FillDataWavePainter()),
            ),
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 8),
                        child: AuthBackButton(),
                      ),
                      SizedBox(height: size.height * 0.18),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            const Text(
                              'Isi Data',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // ── Username ──
                            const _SectionLabel('Username'),
                            const SizedBox(height: 8),
                            _RoundedField(
                              controller: _usernameController,
                              hint: 'Contoh: panti_sayapibu1',
                              errorText: _usernameError,
                              onChanged: (_) => setState(() => _usernameError = null),
                            ),
                            const SizedBox(height: 20),

                            // ── Nama Panti ──
                            const _SectionLabel('Nama Panti'),
                            const SizedBox(height: 8),
                            _RoundedField(
                              controller: _namaPantiController,
                              hint: 'Contoh: Panti Sayap Ibu Bintaro',
                              errorText: _namaPantiError,
                              onChanged: (_) => setState(() => _namaPantiError = null),
                            ),
                            const SizedBox(height: 20),

                            // ── Jalan & Nomor ──
                            const _SectionLabel('Alamat'),
                            const SizedBox(height: 8),
                            _RoundedField(
                              controller: _jalanController,
                              hint: 'Contoh: Jl. Sudirman No. 5',
                              errorText: _jalanError,
                              onChanged: (_) => setState(() => _jalanError = null),
                            ),
                            const SizedBox(height: 20),

                            // ── Provinsi ──
                            const _SectionLabel('Provinsi'),
                            const SizedBox(height: 8),
                            _CascadeDropdown<ProvinceModel>(
                              value: _selectedProvince,
                              items: _provinces,
                              loading: _loadingProvinces,
                              hint: 'Pilih provinsi',
                              errorText: _provinsiError,
                              itemLabel: (p) => p.name,
                              onChanged: _onProvinceChanged,
                            ),
                            const SizedBox(height: 20),

                            // ── Kabupaten/Kota ──
                            const _SectionLabel('Kabupaten / Kota'),
                            const SizedBox(height: 8),
                            _CascadeDropdown<CityModel>(
                              value: _selectedCity,
                              items: _cities,
                              loading: _loadingCities,
                              hint: _selectedProvince == null
                                  ? 'Pilih provinsi terlebih dahulu'
                                  : 'Pilih kabupaten/kota',
                              enabled: _selectedProvince != null,
                              errorText: _kotaError,
                              itemLabel: (c) => c.name,
                              onChanged: _onCityChanged,
                            ),
                            const SizedBox(height: 20),

                            // ── Kecamatan ──
                            const _SectionLabel('Kecamatan'),
                            const SizedBox(height: 8),
                            _CascadeDropdown<DistrictModel>(
                              value: _selectedDistrict,
                              items: _districts,
                              loading: _loadingDistricts,
                              hint: _selectedCity == null
                                  ? 'Pilih kota/kabupaten terlebih dahulu'
                                  : 'Pilih kecamatan',
                              enabled: _selectedCity != null,
                              errorText: _kecamatanError,
                              itemLabel: (d) => d.name,
                              onChanged: _onDistrictChanged,
                            ),
                            const SizedBox(height: 20),

                            // ── Kelurahan ──
                            const _SectionLabel('Kelurahan'),
                            const SizedBox(height: 8),
                            _CascadeDropdown<VillageModel>(
                              value: _selectedVillage,
                              items: _villages,
                              loading: _loadingVillages,
                              hint: _selectedDistrict == null
                                  ? 'Pilih kecamatan terlebih dahulu'
                                  : 'Pilih kelurahan',
                              enabled: _selectedDistrict != null,
                              errorText: _kelurahanError,
                              itemLabel: (v) => v.name,
                              onChanged: (v) => setState(() {
                                _selectedVillage = v;
                                _kelurahanError = null;
                              }),
                            ),
                            const SizedBox(height: 20),

                            // ── Kode Pos ──
                            const _SectionLabel('Kode Pos'),
                            const SizedBox(height: 8),
                            _RoundedField(
                              controller: _kodePosController,
                              hint: 'Contoh: 15310',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(5),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // ── Nomor Panti ──
                            const _SectionLabel('Nomor Panti'),
                            const SizedBox(height: 8),
                            _RoundedField(
                              controller: _nomorPantiController,
                              hint: 'Contoh: 0812-3456-7890',
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[\d-]')),
                                _PhoneFormatter(),
                              ],
                              errorText: _nomorPantiError,
                              onChanged: (_) => setState(() => _nomorPantiError = null),
                            ),
                            const SizedBox(height: 24),

                            // ── Syarat dan Ketentuan ──
                            const Text(
                              'Syarat dan Ketentuan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _agreeTnC,
                                    onChanged: (val) => setState(
                                        () => _agreeTnC = val ?? false),
                                    activeColor: const Color(0xFF2C2C2C),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                          height: 1.5),
                                      children: const [
                                        TextSpan(
                                            text:
                                                'Saya mengakui telah membaca dan menyetujui Syarat & Ketentuan dan Kebijakan Ruang Peduli. '),
                                        TextSpan(
                                          text: 'Baca selengkapnya.',
                                          style: TextStyle(
                                            color: Color(0xFFF43D5E),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_tncError != null)
                              InlineMessage(message: _tncError),
                            const SizedBox(height: 24),

                            InlineMessage(message: _generalError),
                            if (_generalError != null) const SizedBox(height: 8),

                            Center(
                              child: SizedBox(
                                width: size.width * 0.55,
                                child: DarkButton(
                                  label: _loading ? 'Memproses...' : 'Sign Up',
                                  onTap: _loading ? () {} : _onSelanjutnya,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cascading dropdown ──
class _CascadeDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final bool loading;
  final bool enabled;
  final String hint;
  final String? errorText;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const _CascadeDropdown({
    required this.value,
    required this.items,
    required this.hint,
    required this.itemLabel,
    required this.onChanged,
    this.loading = false,
    this.enabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: enabled
                ? const Color(0xFFF0E8EA)
                : const Color(0xFFE8E0E2),
            borderRadius: BorderRadius.circular(12),
            border: hasError
                ? Border.all(color: const Color(0xFFF43D5E), width: 1.5)
                : null,
          ),
          child: loading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFFF47B8C)),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: value,
                    isExpanded: true,
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        hint,
                        style: TextStyle(
                            fontSize: 14,
                            color: enabled
                                ? Colors.grey.shade400
                                : Colors.grey.shade300),
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    borderRadius: BorderRadius.circular(12),
                    items: enabled
                        ? items
                            .map((item) => DropdownMenuItem<T>(
                                  value: item,
                                  child: Text(itemLabel(item),
                                      style: const TextStyle(fontSize: 14)),
                                ))
                            .toList()
                        : [],
                    onChanged: enabled ? onChanged : null,
                  ),
                ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 13, color: Color(0xFFF43D5E)),
              const SizedBox(width: 4),
              Text(errorText!,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFFF43D5E))),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Section Label ──
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A1A),
      ),
    );
  }
}

// ── Phone number formatter: 0812-3456-7890 ──
class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll('-', '');
    if (digits.isEmpty) return next.copyWith(text: '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 13; i++) {
      if (i == 4 || i == 8) buffer.write('-');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return next.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ── Rounded text field ──
class _RoundedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _RoundedField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF0E8EA),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasError
                  ? const BorderSide(color: Color(0xFFF43D5E), width: 1.5)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFF43D5E), width: 1.5),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 13, color: Color(0xFFF43D5E)),
              const SizedBox(width: 4),
              Text(
                errorText!,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFFF43D5E)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Wave painter ──
class _FillDataWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBack = Paint()
      ..color = Colors.white.withValues(alpha: 0.40)
      ..style = PaintingStyle.fill;

    final pathBack = Path()
      ..moveTo(0, size.height * 0.14)
      ..quadraticBezierTo(size.width * 0.20, size.height * 0.02,
          size.width * 0.50, size.height * 0.10)
      ..quadraticBezierTo(
          size.width * 0.80, size.height * 0.18, size.width, size.height * 0.07)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathBack, paintBack);

    final paintFront = Paint()
      ..color = const Color(0xFFFFF0F2)
      ..style = PaintingStyle.fill;

    final pathFront = Path()
      ..moveTo(0, size.height * 0.22)
      ..quadraticBezierTo(size.width * 0.22, size.height * 0.08,
          size.width * 0.50, size.height * 0.16)
      ..quadraticBezierTo(
          size.width * 0.78, size.height * 0.24, size.width, size.height * 0.13)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathFront, paintFront);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
