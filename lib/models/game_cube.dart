import 'package:flutter/foundation.dart';
import '../utils/coordinate.dart';
import 'cube_block.dart';
import 'face.dart';

@immutable
class GameCube {
  // Flat array length 64, index = x + 4*y + 16*z
  final List<CubeBlock> blocks;

  const GameCube(this.blocks);

  factory GameCube.empty() =>
      GameCube(List.unmodifiable(List.filled(64, kEmpty)));

  factory GameCube.fromJson(List<dynamic> blocksJson) {
    final list = List<CubeBlock>.filled(64, kEmpty, growable: false);
    for (final b in blocksJson) {
      final x = b['x'] as int;
      final y = b['y'] as int;
      final z = b['z'] as int;
      list[_idx(x, y, z)] = CubeBlock(b['mask'] as int);
    }
    return GameCube(List.unmodifiable(list));
  }

  static int _idx(int x, int y, int z) => x + 4 * y + 16 * z;

  CubeBlock at(Coordinate c) => blocks[_idx(c.x, c.y, c.z)];

  bool areConnected(Coordinate a, Coordinate b) {
    final delta = Coordinate(b.x - a.x, b.y - a.y, b.z - a.z);
    final face = deltaToFace[delta];
    if (face == null) return false;
    return at(a).connectsTo(face) && at(b).connectsTo(oppositeFace[face]!);
  }
}
