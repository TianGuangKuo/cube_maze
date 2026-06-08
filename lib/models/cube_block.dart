import 'package:flutter/foundation.dart';
import 'face.dart';

// Each block stores a 6-bit connectionMask directly.
// Bit order: top=0x01 bottom=0x02 right=0x04 left=0x08 front=0x10 back=0x20
@immutable
class CubeBlock {
  final int connectionMask;

  const CubeBlock(this.connectionMask);

  bool get isEmpty => connectionMask == 0;

  bool connectsTo(Face face) => (connectionMask & faceBit[face]!) != 0;

  int get connectionCount =>
      connectionMask.toRadixString(2).split('').where((c) => c == '1').length;

  Map<String, dynamic> toJson(int x, int y, int z) =>
      {'x': x, 'y': y, 'z': z, 'mask': connectionMask};

  @override
  String toString() =>
      'CubeBlock(mask=0x${connectionMask.toRadixString(16).padLeft(2, '0')})';
}

const kEmpty = CubeBlock(0);
