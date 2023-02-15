import 'package:flutter/material.dart';
import 'package:flutter_barcode_sdk/dynamsoft_barcode.dart';

class OverlayPainter extends CustomPainter {
  final List<BarcodeResult> results;

  const OverlayPainter(this.results);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    for (var result in results) {
      canvas.drawLine(Offset(result.x1.toDouble(), result.y1.toDouble()),
          Offset(result.x2.toDouble(), result.y2.toDouble()), paint);
      canvas.drawLine(Offset(result.x2.toDouble(), result.y2.toDouble()),
          Offset(result.x3.toDouble(), result.y3.toDouble()), paint);
      canvas.drawLine(Offset(result.x3.toDouble(), result.y3.toDouble()),
          Offset(result.x4.toDouble(), result.y4.toDouble()), paint);
      canvas.drawLine(Offset(result.x4.toDouble(), result.y4.toDouble()),
          Offset(result.x1.toDouble(), result.y1.toDouble()), paint);

      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: result.text,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 24.0,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(
          canvas, Offset(result.x1.toDouble(), result.y1.toDouble()));
    }
  }

  @override
  bool shouldRepaint(OverlayPainter oldDelegate) =>
      results != oldDelegate.results;
}
