import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import 'cube_widget.dart';
import 'solved_overlay.dart';

class GameScreen extends ConsumerWidget {
  final int levelIndex;
  const GameScreen({super.key, required this.levelIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: gameState == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Background gradient
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0D1B2A), Color(0xFF1B2E4A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

                // Top bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            gameState.level.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        _DifficultyStars(
                            difficulty: gameState.level.difficulty),
                      ],
                    ),
                  ),
                ),

                // Cube
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.92,
                    height: MediaQuery.of(context).size.width * 0.92,
                    child: const CubeWidget(),
                  ),
                ),

                // Bottom HUD
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _HUD(gameState: gameState),
                    ),
                  ),
                ),

                // Solved overlay
                if (gameState.phase == AnimationPhase.solved)
                  SolvedOverlay(
                    moveCount: gameState.moveCount,
                    parMoves: gameState.level.parMoves,
                    onNext: () {
                      final idx = ref.read(currentLevelIndexProvider);
                      final levels = ref.read(levelsProvider).valueOrNull ?? [];
                      if (idx + 1 < levels.length) {
                        ref.read(currentLevelIndexProvider.notifier).state =
                            idx + 1;
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    onReplay: () {
                      ref.read(gameProvider.notifier).reset();
                    },
                  ),
              ],
            ),
    );
  }
}

class _DifficultyStars extends StatelessWidget {
  final int difficulty;
  const _DifficultyStars({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          Icons.star,
          size: 14,
          color: i < difficulty ? Colors.amber : Colors.white24,
        ),
      ),
    );
  }
}

class _HUD extends ConsumerWidget {
  final GameState gameState;
  const _HUD({required this.gameState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _HudButton(
          icon: Icons.refresh,
          label: '重置',
          onTap: () => ref.read(gameProvider.notifier).reset(),
        ),
        _MoveCounter(
          moves: gameState.moveCount,
          par: gameState.level.parMoves,
        ),
        _HudButton(
          icon: Icons.lightbulb_outline,
          label: '提示',
          onTap: () {
            final hint = gameState.level.hintText;
            if (hint != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(hint),
                  backgroundColor: Colors.indigo,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class _HudButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _HudButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: Colors.white70, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }
}

class _MoveCounter extends StatelessWidget {
  final int moves;
  final int par;
  const _MoveCounter({required this.moves, required this.par});

  @override
  Widget build(BuildContext context) {
    final color = moves <= par ? Colors.lightGreenAccent : Colors.orangeAccent;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$moves',
          style: TextStyle(
              color: color, fontSize: 36, fontWeight: FontWeight.bold),
        ),
        Text(
          '步 / 标准$par步',
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}
