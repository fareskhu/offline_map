import 'dart:ui';
import 'package:flutter/material.dart';

Future<Widget> getMarkerBitmap(int size, {required Color color}) async {
  final PictureRecorder pictureRecorder = PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint paint1 = Paint()
    ..color = color; // Dynamic color based on tree status
  final Paint paint2 = Paint()..color = Colors.white;

  canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
  canvas.drawCircle(
      Offset(size / 2, size / 2), size / 2.5, paint2); // Adjusted size
  canvas.drawCircle(
      Offset(size / 2, size / 2), size / 3.0, paint1); // Adjusted size

  final img = await pictureRecorder.endRecording().toImage(size, size);
  final data = await img.toByteData(format: ImageByteFormat.png);

  return Image.memory(data!.buffer.asUint8List(),
      width: size.toDouble(), height: size.toDouble());
}
