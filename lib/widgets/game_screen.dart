import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_level.dart';
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
          icon: Icons.menu_book_outlined,
          label: '说明',
          onTap: () => _showAssemblySheet(context, gameState),
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

  void _showAssemblySheet(BuildContext context, GameState gameState) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10223A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AssemblySheet(gameState: gameState),
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

class _AssemblySheet extends StatelessWidget {
  final GameState gameState;
  const _AssemblySheet({required this.gameState});

  @override
  Widget build(BuildContext context) {
    final level = gameState.level;

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.82,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (context, controller) {
          return ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                level.assemblyTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                level.assemblyGoal,
                style: const TextStyle(
                  color: Colors.white70,
                  height: 1.35,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.grid_4x4,
                    label: '管道模块 ${level.assemblyPieces.length} 个',
                  ),
                  const _InfoChip(icon: Icons.category_outlined, label: '九种形式'),
                  const _InfoChip(
                      icon: Icons.view_in_ar_outlined, label: '4x4x4'),
                ],
              ),
              const SizedBox(height: 22),
              const _SectionTitle('组装步骤'),
              ...level.assemblySteps.asMap().entries.map(
                    (entry) => _StepRow(
                      number: entry.key + 1,
                      text: entry.value,
                    ),
                  ),
              const SizedBox(height: 18),
              const _SectionTitle('坐标摆放清单'),
              const Text(
                '坐标格式为(x,y,z)：x左到右，y下到上，z后到前。按层检查更容易发现摆放错误。',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 10),
              ...level.assemblyPieces.map((piece) => _PieceRow(piece: piece)),
            ],
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.lightBlueAccent),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int number;
  final String text;
  const _StepRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: Colors.lightBlueAccent.withOpacity(0.18),
            child: Text(
              '$number',
              style:
                  const TextStyle(color: Colors.lightBlueAccent, fontSize: 11),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _PieceRow extends StatelessWidget {
  final AssemblyPiece piece;
  const _PieceRow({required this.piece});

  @override
  Widget build(BuildContext context) {
    final isPath = piece.isMainPath;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Icon(Icons.toll_outlined, color: Colors.white54, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${piece.label}  ${piece.coordinateLabel}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (piece.note != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      piece.note!,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            piece.pipeShapeLabel,
            style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 11),
          ),
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
