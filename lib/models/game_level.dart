import 'package:flutter/foundation.dart';
import 'game_cube.dart';

const _facePairs = [
  (0x01, 0x02),
  (0x04, 0x08),
  (0x10, 0x20),
];

@immutable
class AssemblyPiece {
  final int x;
  final int y;
  final int z;
  final int mask;
  final String role;
  final String label;
  final String? note;

  const AssemblyPiece({
    required this.x,
    required this.y,
    required this.z,
    required this.mask,
    required this.role,
    required this.label,
    this.note,
  });

  factory AssemblyPiece.fromJson(Map<String, dynamic> json, int index) {
    return AssemblyPiece(
      x: json['x'] as int,
      y: json['y'] as int,
      z: json['z'] as int,
      mask: json['mask'] as int,
      role: json['role'] as String? ?? 'decoy',
      label: json['label'] as String? ?? '模块${index + 1}',
      note: json['note'] as String?,
    );
  }

  String get coordinateLabel => '($x,$y,$z)';
  bool get isMainPath => role == 'path';

  String get pipeShapeLabel {
    final count = connectionCount;
    if (count == 1) return '单口管';
    if (count == 2) return _hasOppositePair(mask) ? '双口直管' : '双口弯管';
    if (count == 3) return _hasOppositePair(mask) ? '三口立体T管' : '三口平面T管';
    if (count == 4) return _missingOppositePair(mask) ? '四口平面十字管' : '四口立体十字管';
    if (count == 5) return '五口管';
    if (count == 6) return '六口管';
    return '未知管道';
  }

  int get connectionCount {
    var value = mask;
    var count = 0;
    while (value > 0) {
      count += value & 1;
      value >>= 1;
    }
    return count;
  }

  bool get isValidPipeShape => connectionCount >= 1 && connectionCount <= 6;
}

bool _hasOppositePair(int mask) {
  return _facePairs
      .any((pair) => (mask & pair.$1) != 0 && (mask & pair.$2) != 0);
}

bool _missingOppositePair(int mask) {
  return _facePairs
      .any((pair) => (mask & pair.$1) == 0 && (mask & pair.$2) == 0);
}

@immutable
class GameLevel {
  final int id;
  final String name;
  final int difficulty;
  final int parMoves;
  final GameCube cube;
  final List<double> initialOrientation; // quaternion [x,y,z,w]
  final String? hintText;
  final String assemblyTitle;
  final String assemblyGoal;
  final List<AssemblyPiece> assemblyPieces;
  final List<String> assemblySteps;

  const GameLevel({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.parMoves,
    required this.cube,
    required this.initialOrientation,
    this.hintText,
    required this.assemblyTitle,
    required this.assemblyGoal,
    required this.assemblyPieces,
    required this.assemblySteps,
  });

  factory GameLevel.fromJson(Map<String, dynamic> json) {
    final orientation = (json['initial_orientation'] as List?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [0.0, 0.0, 0.0, 1.0];
    final blocksJson = json['blocks'] as List;
    final assembly = json['assembly'] as Map<String, dynamic>?;
    return GameLevel(
      id: json['id'] as int,
      name: json['name'] as String,
      difficulty: json['difficulty'] as int,
      parMoves: json['par_moves'] as int,
      cube: GameCube.fromJson(blocksJson),
      initialOrientation: orientation,
      hintText: json['hint_text'] as String?,
      assemblyTitle: assembly?['title'] as String? ?? '${json['name']} 组装说明',
      assemblyGoal:
          assembly?['goal'] as String? ?? '按坐标放置64个管道模块，让钢珠从(0,0,0)滚到(3,3,3)。',
      assemblyPieces: List.unmodifiable(blocksJson.asMap().entries.map(
            (entry) => AssemblyPiece.fromJson(
              entry.value as Map<String, dynamic>,
              entry.key,
            ),
          )),
      assemblySteps: List.unmodifiable(
        (assembly?['steps'] as List? ??
                const <String>[
                  '确认坐标方向：x 从左到右，y 从下到上，z 从后到前。',
                  '先摆放标记为主通路的模块，再摆放干扰模块。',
                  '检查起点(0,0,0)和终点(3,3,3)，开始钢珠挑战。',
                ])
            .map((e) => e.toString()),
      ),
    );
  }
}
