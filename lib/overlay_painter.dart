import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_sdk/dynamsoft_barcode.dart';

Widget createOverlay(List<BarcodeResult> results) {
  return CustomPaint(
    painter: OverlayPainter(results),
  );
}

class OverlayPainter extends CustomPainter {
  final List<BarcodeResult> results;

  OverlayPainter(this.results) {
    results.sort((a, b) {
      if (((a.y1 + a.y2 + a.y3 + a.y4) / 4 < (b.y1 + b.y2 + b.y3 + b.y4) / 4)) {
        return -1;
      }
      if (((a.y1 + a.y2 + a.y3 + a.y4) / 4 > (b.y1 + b.y2 + b.y3 + b.y4) / 4)) {
        return 1;
      }
      return 0;
    });

    List<BarcodeResult> all = [];
    int delta = 0;
    while (results.isNotEmpty) {
      List<BarcodeResult> sortedResults = [];
      BarcodeResult start = results[0];
      sortedResults.add(start);
      results.remove(start);

      int maxHeight = [start.y1, start.y2, start.y3, start.y4].reduce(max);
      while (results.isNotEmpty) {
        BarcodeResult tmp = results[0];

        if ([tmp.y1, tmp.y2, tmp.y3, tmp.y4].reduce(min) < maxHeight + delta) {
          sortedResults.add(tmp);
          results.remove(tmp);
        } else {
          break;
        }
      }

      sortedResults.sort(((a, b) {
        if (((a.x1 + a.x2 + a.x3 + a.x4) / 4 <
            (b.x1 + b.x2 + b.x3 + b.x4) / 4)) {
          return -1;
        }
        if (((a.x1 + a.x2 + a.x3 + a.x4) / 4 >
            (b.x1 + b.x2 + b.x3 + b.x4) / 4)) {
          return 1;
        }
        return 0;
      }));

      all += sortedResults;
    }
    results.addAll(all);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    int index = 0;

    for (var result in results) {
      double minX = result.x1.toDouble();
      double minY = result.y1.toDouble();
      if (result.x2 < minX) minX = result.x2.toDouble();
      if (result.x3 < minX) minX = result.x3.toDouble();
      if (result.x4 < minX) minX = result.x4.toDouble();
      if (result.y2 < minY) minY = result.y2.toDouble();
      if (result.y3 < minY) minY = result.y3.toDouble();
      if (result.y4 < minY) minY = result.y4.toDouble();

      canvas.drawLine(Offset(result.x1.toDouble(), result.y1.toDouble()),
          Offset(result.x2.toDouble(), result.y2.toDouble()), paint);
      canvas.drawLine(Offset(result.x2.toDouble(), result.y2.toDouble()),
          Offset(result.x3.toDouble(), result.y3.toDouble()), paint);
      canvas.drawLine(Offset(result.x3.toDouble(), result.y3.toDouble()),
          Offset(result.x4.toDouble(), result.y4.toDouble()), paint);
      canvas.drawLine(Offset(result.x4.toDouble(), result.y4.toDouble()),
          Offset(result.x1.toDouble(), result.y1.toDouble()), paint);

      // canvas.drawCircle(
      //     Offset(
      //         (result.x1.toDouble() +
      //                 result.x2.toDouble() +
      //                 result.x3.toDouble() +
      //                 result.x4.toDouble()) /
      //             4,
      //         (result.y1.toDouble() +
      //                 result.y2.toDouble() +
      //                 result.y3.toDouble() +
      //                 result.y4.toDouble()) /
      //             4),
      //     20.0,
      //     paint);

      TextPainter numberPainter = TextPainter(
        text: TextSpan(
          text: index.toString(),
          style: const TextStyle(
            color: Colors.red,
            fontSize: 60.0,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      numberPainter.layout(minWidth: 0, maxWidth: size.width);
      numberPainter.paint(canvas, Offset(minX, minY));

      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: result.text,
          style: const TextStyle(
            color: Colors.yellow,
            fontSize: 22.0,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(canvas, Offset(minX, minY));

      index += 1;
    }
  }

  @override
  bool shouldRepaint(OverlayPainter oldDelegate) =>
      results != oldDelegate.results;
}
