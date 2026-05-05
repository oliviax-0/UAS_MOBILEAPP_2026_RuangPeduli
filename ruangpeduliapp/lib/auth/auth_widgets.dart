// ignore_for_file: use_key_in_widget_constructors, deprecated_member_use

import 'package:flutter/material.dart';

// ── Custom overlay popup ──
void showCustomPopup(
  BuildContext context,
  String message, {
  bool isError = true,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _CustomPopup(
      message: message,
      isError: isError,
      onDismiss: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

class _CustomPopup extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _CustomPopup({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  State<_CustomPopup> createState() => _CustomPopupState();
}

class _CustomPopupState extends State<_CustomPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();

    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;
      await _ctrl.reverse();
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isError ? const Color(0xFFF43D5E) : Colors.green;
    final icon = widget.isError
        ? Icons.error_outline_rounded
        : Icons.check_circle_outline_rounded;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Inline error / info text ──
class InlineMessage extends StatelessWidget {
  final String? message;
  final bool isError;

  const InlineMessage({super.key, this.message, this.isError = true});

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) return const SizedBox.shrink();
    final color = isError ? const Color(0xFFF43D5E) : Colors.green.shade600;
    final icon = isError
        ? Icons.info_outline_rounded
        : Icons.check_circle_outline_rounded;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message!,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared gradient + wave background ──
class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        // Gradient
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
        // Wave — dinaikkan lebih tinggi (70% dari bawah)
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: size.height * 0.70,
            width: size.width,
            child: CustomPaint(painter: _AuthWavePainter()),
          ),
        ),
        child,
      ],
    );
  }
}

class _AuthWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Layer belakang transparan
    final paintBack = Paint()
      ..color = Colors.white.withOpacity(0.40)
      ..style = PaintingStyle.fill;

    final pathBack = Path()
      ..moveTo(0, size.height * 0.18)
      ..quadraticBezierTo(size.width * 0.20, size.height * 0.02,
          size.width * 0.50, size.height * 0.12)
      ..quadraticBezierTo(
          size.width * 0.80, size.height * 0.22, size.width, size.height * 0.08)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathBack, paintBack);

    // Layer depan — warna cream/putih kemerahan
    final paintFront = Paint()
      ..color = const Color(0xFFFFF0F2)
      ..style = PaintingStyle.fill;

    final pathFront = Path()
      ..moveTo(0, size.height * 0.28)
      ..quadraticBezierTo(size.width * 0.22, size.height * 0.10,
          size.width * 0.50, size.height * 0.20)
      ..quadraticBezierTo(
          size.width * 0.78, size.height * 0.30, size.width, size.height * 0.16)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathFront, paintFront);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Shared dark button ──
class DarkButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const DarkButton({super.key, required this.label, required this.onTap});

  @override
  State<DarkButton> createState() => _DarkButtonState();
}

class _DarkButtonState extends State<DarkButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFF111111) : const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.20),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
        ),
        child: Center(
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared back button ──
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child:
            const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

// ── Shared underline text field ──
class UnderlineField extends StatefulWidget {
  final String label;
  final String hint;
  final bool obscure;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const UnderlineField({
    super.key,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  State<UnderlineField> createState() => _UnderlineFieldState();
}

class _UnderlineFieldState extends State<UnderlineField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final isObscured = widget.obscure && _hidden;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A))),
        const SizedBox(height: 10),
        TextField(
          controller: widget.controller,
          obscureText: isObscured,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: hasError
                        ? const Color(0xFFF43D5E)
                        : Colors.grey.shade300)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: hasError
                        ? const Color(0xFFF43D5E)
                        : const Color(0xFFF43D5E),
                    width: 1.5)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            suffixIcon: widget.obscure
                ? GestureDetector(
                    onTap: () => setState(() => _hidden = !_hidden),
                    child: Icon(
                      _hidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                  )
                : null,
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 13, color: Color(0xFFF43D5E)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFF43D5E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Row with two expanded children ──
class RowWithTwoExpandedChildren extends StatelessWidget {
  final Widget child1;
  final Widget child2;

  const RowWithTwoExpandedChildren({
    required this.child1,
    required this.child2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: child1,
        ),
        Expanded(
          flex: 1,
          child: child2,
        ),
      ],
    );
  }
}

// ── Row with one expanded child ──
class RowWithOneExpandedChild extends StatelessWidget {
  final Widget child;

  const RowWithOneExpandedChild({required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text('Your text here'),
          ),
        ),
      ],
    );
  }
}
