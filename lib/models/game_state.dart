import 'package:vector_math/vector_math_64.dart';
import '../utils/coordinate.dart';
import 'game_level.dart';

enum AnimationPhase { idle, ballRolling, solved }

class GameState {
  final GameLevel level;
  final Quaternion cubeOrientation;
  final Coordinate ballPosition;
  final List<Coordinate> traveledPath;
  final AnimationPhase phase;
  final int moveCount;

  GameState({
    required this.level,
    required this.cubeOrientation,
    required this.ballPosition,
    required this.traveledPath,
    required this.phase,
    required this.moveCount,
  });

  factory GameState.fromLevel(GameLevel level) {
    final q = level.initialOrientation;
    return GameState(
      level: level,
      cubeOrientation: Quaternion(q[0], q[1], q[2], q[3]),
      ballPosition: kStart,
      traveledPath: [kStart],
      phase: AnimationPhase.idle,
      moveCount: 0,
    );
  }

  GameState copyWith({
    Quaternion? cubeOrientation,
    Coordinate? ballPosition,
    List<Coordinate>? traveledPath,
    AnimationPhase? phase,
    int? moveCount,
  }) {
    return GameState(
      level: level,
      cubeOrientation: cubeOrientation ?? this.cubeOrientation,
      ballPosition: ballPosition ?? this.ballPosition,
      traveledPath: traveledPath ?? this.traveledPath,
      phase: phase ?? this.phase,
      moveCount: moveCount ?? this.moveCount,
    );
  }

  bool get isSolved => ballPosition == kEnd;
}
