import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title:const Text('Polar Chart with Circles Example')),
      body: Center(
        child: PolarChartWithCircles(
          segmentDataList: [
            SegmentData(value: 20, label: 'A', color: Colors.red),
            SegmentData(value: 50, label: 'B', color: Colors.green),
            SegmentData(value: 80, label: 'C', color: Colors.blue),
            SegmentData(value: 30, label: 'D', color: Colors.yellow),
            SegmentData(value: 70, label: 'E', color: Colors.orange),
          ],
          numberOfCircles: 5,
          radius: 150,
          strokeWidth: 1.0,
        ),
      ),
    ),
  ));
}

class SegmentData {
  final double value;
  final String label;
  final Color color;

  SegmentData({
    required this.value,
    required this.label,
    required this.color,
  });
}

class PolarChartWithCircles extends StatelessWidget {
  final List<SegmentData> segmentDataList;
  final int numberOfCircles;
  final double radius;
  final double strokeWidth;

  PolarChartWithCircles({
    required this.segmentDataList,
    required this.numberOfCircles,
    required this.radius,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(radius * 2, radius * 2),
      painter: PolarChartWithCirclesPainter(
        segmentDataList: segmentDataList,
        numberOfCircles: numberOfCircles,
        radius: radius,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class PolarChartWithCirclesPainter extends CustomPainter {
  final List<SegmentData> segmentDataList;
  final int numberOfCircles;
  final double radius;
  final double strokeWidth;

  PolarChartWithCirclesPainter({
    required this.segmentDataList,
    required this.numberOfCircles,
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (min(size.width, size.height) / 2) * 0.9;
    final step = maxRadius / numberOfCircles.toDouble();

    // Draw concentric circles
    final circlePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    for (double r = step; r <= maxRadius; r += step) {
      canvas.drawCircle(center, r, circlePaint);
    }

    // Draw each segment and display values
    final segmentAngleStep = 2 * pi / segmentDataList.length;
    double startAngle = -pi / 2;
    for (final segmentData in segmentDataList) {
      final angle = startAngle + segmentAngleStep;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(center.dx + cos(startAngle) * segmentData.value, center.dy + sin(startAngle) * segmentData.value)
        ..arcTo(Rect.fromCircle(center: center, radius: segmentData.value), startAngle, segmentAngleStep, false)
        ..lineTo(center.dx, center.dy)
        ..close();

      final paint = Paint()
        ..color = segmentData.color
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);

      // Draw black line between slices
      final dividerLinePaint = Paint()
        ..color = Colors.grey
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;
      // Calculate end point of the divider line at the edge of the last circle
      final endPoint = Offset(center.dx + cos(startAngle) * maxRadius, center.dy + sin(startAngle) * maxRadius);
      canvas.drawLine(center, endPoint, dividerLinePaint);

      // Display value on the corner
      final midAngle = startAngle + segmentAngleStep / 2;
      final labelRadius = segmentData.value + 20; // Adjust label radius
      final labelPoint = Offset(
        center.dx + labelRadius * cos(midAngle),
        center.dy + labelRadius * sin(midAngle),
      );

      final valueTextPainter = TextPainter(
        text: TextSpan(
          text: '${segmentData.value}',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      valueTextPainter.layout();
      final valueTextOffset = Offset(
        labelPoint.dx - valueTextPainter.width / 2,
        labelPoint.dy - valueTextPainter.height / 2,
      );
      valueTextPainter.paint(canvas, valueTextOffset);

      startAngle = angle;
    }

    // Display segment names at the center of each segment
    final segmentNameRadius = maxRadius + 20; // Radius for segment names
    final segmentNameAngleStep = 2 * pi / segmentDataList.length;
    for (int i = 0; i < segmentDataList.length; i++) {
      final angle = i * segmentNameAngleStep - pi / 2 + segmentNameAngleStep / 2;
      final labelPoint = Offset(center.dx + segmentNameRadius * cos(angle), center.dy + segmentNameRadius * sin(angle));
      final valueTextPainter = TextPainter(
        text: TextSpan(
          text: segmentDataList[i].label,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      valueTextPainter.layout();
      final valueTextOffset = Offset(
        labelPoint.dx - valueTextPainter.width / 2,
        labelPoint.dy - valueTextPainter.height / 2,
      );
      valueTextPainter.paint(canvas, valueTextOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
