import 'package:flutter/foundation.dart';
import 'game_cube.dart';

@immutable
class GameLevel {
  final int id;
  final String name;
  final int difficulty;
  final int parMoves;
  final GameCube cube;
  final List<double> initialOrientation; // quaternion [x,y,z,w]
  final String? hintText;

  const GameLevel({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.parMoves,
    required this.cube,
    required this.initialOrientation,
    this.hintText,
  });

  factory GameLevel.fromJson(Map<String, dynamic> json) {
    final orientation = (json['initial_orientation'] as List?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [0.0, 0.0, 0.0, 1.0];
    return GameLevel(
      id: json['id'] as int,
      name: json['name'] as String,
      difficulty: json['difficulty'] as int,
      parMoves: json['par_moves'] as int,
      cube: GameCube.fromJson(json['blocks'] as List),
      initialOrientation: orientation,
      hintText: json['hint_text'] as String?,
    );
  }
}
