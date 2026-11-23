import 'package:material_ui/material_ui.dart';
import 'package:medilinkmovil/core/theme/medilink_theme.dart';

class MedilinkLogo extends StatelessWidget {
  const MedilinkLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomPaint(size: Size(48, 48), painter: _MarcaPainter()),
        SizedBox(width: 12),
        Text(
          'MediLink',
          style: TextStyle(
            color: medilinkInk,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

class _MarcaPainter extends CustomPainter {
  const _MarcaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 32;
    canvas.scale(scale);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 32, 32),
        const Radius.circular(8),
      ),
      Paint()..color = medilinkInk,
    );

    final trazo = Paint()
      ..color = medilinkCrema
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final marca = Path()
      ..moveTo(9, 21.5)
      ..lineTo(9, 10.5)
      ..lineTo(16, 17.5)
      ..lineTo(23, 10.5)
      ..lineTo(23, 21.5);
    canvas.drawPath(marca, trazo);
    canvas.drawCircle(
      const Offset(23, 10.5),
      2.4,
      Paint()..color = medilinkCoral,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
