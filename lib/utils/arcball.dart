import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

/// Converts a screen drag delta into a quaternion rotation.
Quaternion arcballDelta(Offset dragDelta, Size viewportSize) {
  final sensitivity = pi / viewportSize.shortestSide;
  final angleX = dragDelta.dy * sensitivity;
  final angleY = dragDelta.dx * sensitivity;

  final qY = Quaternion.axisAngle(Vector3(0, 1, 0), angleY);
  final qX = Quaternion.axisAngle(Vector3(1, 0, 0), -angleX);

  return (qY * qX)..normalize();
}
