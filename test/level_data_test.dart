import 'dart:convert';
import 'dart:io';

import 'package:cube_maze/models/game_level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const allowedPipeShapes = {
    '单口管',
    '双口直管',
    '双口弯管',
    '三口立体T管',
    '三口平面T管',
    '四口平面十字管',
    '四口立体十字管',
    '五口管',
    '六口管',
  };

  final files = Directory('assets/levels')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('all level files provide 64 pipe modules and instructions', () {
    expect(files, isNotEmpty);

    for (final file in files) {
      final jsonMap =
          json.decode(file.readAsStringSync()) as Map<String, dynamic>;
      final level = GameLevel.fromJson(jsonMap);
      final blocks = jsonMap['blocks'] as List<dynamic>;

      expect(blocks, hasLength(64), reason: file.path);
      expect(level.assemblyTitle, isNotEmpty, reason: file.path);
      expect(level.assemblyGoal, isNotEmpty, reason: file.path);
      expect(level.assemblySteps, isNotEmpty, reason: file.path);
      expect(level.assemblyPieces, hasLength(64), reason: file.path);

      final seen = <String>{};
      for (final piece in level.assemblyPieces) {
        expect(piece.x, inInclusiveRange(0, 3), reason: file.path);
        expect(piece.y, inInclusiveRange(0, 3), reason: file.path);
        expect(piece.z, inInclusiveRange(0, 3), reason: file.path);
        expect(piece.mask, greaterThan(0), reason: file.path);
        expect(piece.isValidPipeShape, isTrue, reason: file.path);
        expect(allowedPipeShapes.contains(piece.pipeShapeLabel), isTrue,
            reason: file.path);
        expect(piece.label, isNotEmpty, reason: file.path);
        expect(piece.role, anyOf('path', 'decoy'), reason: file.path);
        expect(seen.add(piece.coordinateLabel), isTrue, reason: file.path);
      }
    }
  });

  test('each level has one connected route from fixed start to fixed end', () {
    for (final file in files) {
      final jsonMap =
          json.decode(file.readAsStringSync()) as Map<String, dynamic>;
      final blocks =
          (jsonMap['blocks'] as List<dynamic>).cast<Map<String, dynamic>>();
      final masks = {
        for (final block in blocks)
          _key(block['x'] as int, block['y'] as int, block['z'] as int):
              block['mask'] as int,
      };

      expect(masks.containsKey(_key(0, 0, 0)), isTrue, reason: file.path);
      expect(masks.containsKey(_key(3, 3, 3)), isTrue, reason: file.path);

      final routeCount = _countRoutes(masks, _key(0, 0, 0), _key(3, 3, 3));
      expect(routeCount, 1, reason: file.path);
    }
  });
}

int _countRoutes(Map<String, int> masks, String start, String end) {
  var count = 0;
  final visited = <String>{};

  void dfs(String current) {
    if (count > 1) return;
    if (current == end) {
      count++;
      return;
    }

    visited.add(current);
    for (final next in _neighbors(current, masks)) {
      if (!visited.contains(next)) {
        dfs(next);
      }
    }
    visited.remove(current);
  }

  dfs(start);
  return count;
}

Iterable<String> _neighbors(String current, Map<String, int> masks) sync* {
  final parts = current.split(',').map(int.parse).toList();
  final x = parts[0];
  final y = parts[1];
  final z = parts[2];
  final mask = masks[current]!;

  const directions = [
    (1, 0, 0, 0x04, 0x08),
    (-1, 0, 0, 0x08, 0x04),
    (0, 1, 0, 0x01, 0x02),
    (0, -1, 0, 0x02, 0x01),
    (0, 0, 1, 0x10, 0x20),
    (0, 0, -1, 0x20, 0x10),
  ];

  for (final (dx, dy, dz, outBit, inBit) in directions) {
    final nx = x + dx;
    final ny = y + dy;
    final nz = z + dz;
    if (nx < 0 || nx > 3 || ny < 0 || ny > 3 || nz < 0 || nz > 3) {
      continue;
    }
    final nextKey = _key(nx, ny, nz);
    final nextMask = masks[nextKey];
    if (nextMask == null) continue;
    if ((mask & outBit) != 0 && (nextMask & inBit) != 0) {
      yield nextKey;
    }
  }
}

String _key(int x, int y, int z) => '$x,$y,$z';
