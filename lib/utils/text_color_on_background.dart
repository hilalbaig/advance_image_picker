import 'package:flutter/material.dart';

/// Change text color based on brightness of the covered background area
Color textColorBasedOnBG(Color color) {
  final r = color.red;
  final g = color.green;
  final b = color.blue;
  //Color brightness is determined by the following formula:
  final brightness = (((r * 299) + (g * 587) + (b * 114)) / 1000).round();
  final textColor = (brightness > 125) ? Colors.black : Colors.white;
  return textColor;
}
