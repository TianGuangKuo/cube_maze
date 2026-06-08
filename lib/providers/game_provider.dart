import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import '../models/game_level.dart';
import '../models/game_state.dart';
import '../services/gravity_solver.dart';
import '../services/level_loader.dart';
import '../utils/arcball.dart';
import '../utils/coordinate.dart';

// ── Level loading ──────────────────────────────────────────────────────────

final levelsProvider = FutureProvider<List<GameLevel>>((ref) async {
  return LevelLoader().loadAll();
});

// ── Current level index ───────────────────────────────────────────────────

final currentLevelIndexProvider = StateProvider<int>((ref) => 0);

// ── Game state ────────────────────────────────────────────────────────────

final gameProvider =
    StateNotifierProvider<GameNotifier, GameState?>((ref) {
  final levels = ref.watch(levelsProvider).valueOrNull;
  if (levels == null || levels.isEmpty) return GameNotifier(null);
  final idx = ref.watch(currentLevelIndexProvider);
  return GameNotifier(GameState.fromLevel(levels[idx]));
});

class GameNotifier extends StateNotifier<GameState?> {
  GameNotifier(GameState? initial) : super(initial);

  void loadLevel(GameLevel level) {
    state = GameState.fromLevel(level);
  }

  void reset() {
    if (state == null) return;
    state = GameState.fromLevel(state!.level);
  }

  /// Called during drag: accumulate orientation delta.
  void rotateCube(Offset dragDelta, Size viewportSize) {
    if (state == null || state!.phase != AnimationPhase.idle) return;
    final delta = arcballDelta(dragDelta, viewportSize);
    final newQ = delta * state!.cubeOrientation;
    newQ.normalize();
    state = state!.copyWith(cubeOrientation: newQ);
  }

  /// Called when drag ends: compute ball step.
  void onDragEnd() {
    if (state == null || state!.phase != AnimationPhase.idle) return;
    _tryMoveBall();
  }

  void _tryMoveBall() {
    final s = state!;
    final next = nextBallStep(s.ballPosition, s.level.cube, s.cubeOrientation);
    if (next == null) return;

    final newPath = [...s.traveledPath, next];
    final phase = next == kEnd ? AnimationPhase.solved : AnimationPhase.ballRolling;

    state = s.copyWith(
      ballPosition: next,
      traveledPath: newPath,
      phase: phase,
      moveCount: s.moveCount + 1,
    );
  }

  void onBallAnimationComplete() {
    if (state == null) return;
    if (state!.phase == AnimationPhase.solved) return;
    state = state!.copyWith(phase: AnimationPhase.idle);
  }
}
