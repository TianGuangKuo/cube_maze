import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../rendering/cube_painter.dart';
import '../utils/coordinate.dart';

class CubeWidget extends ConsumerStatefulWidget {
  const CubeWidget({super.key});

  @override
  ConsumerState<CubeWidget> createState() => _CubeWidgetState();
}

class _CubeWidgetState extends ConsumerState<CubeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ballCtrl;
  late Animation<double> _ballAnim;

  // Ball screen-space lerp: from previous position center to new position center
  Coordinate _prevBallPos = kStart;
  Coordinate _currBallPos = kStart;

  @override
  void initState() {
    super.initState();
    _ballCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _ballAnim = CurvedAnimation(parent: _ballCtrl, curve: Curves.easeInOut);
    _ballCtrl.addStatusListener(_onBallAnimStatus);
  }

  @override
  void dispose() {
    _ballCtrl.dispose();
    super.dispose();
  }

  void _onBallAnimStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _prevBallPos = _currBallPos;
      ref.read(gameProvider.notifier).onBallAnimationComplete();
    }
  }

  @override
  void didUpdateWidget(CubeWidget old) {
    super.didUpdateWidget(old);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<GameState?>(gameProvider, (prev, next) {
      if (next == null) return;
      if (prev?.ballPosition != next.ballPosition) {
        _prevBallPos = prev?.ballPosition ?? kStart;
        _currBallPos = next.ballPosition;
        _ballCtrl
          ..reset()
          ..forward();
      }
    });

    final gameState = ref.watch(gameProvider);
    if (gameState == null) return const SizedBox.shrink();

    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.biggest;
      return GestureDetector(
        onPanUpdate: (details) {
          if (gameState.phase != AnimationPhase.idle) return;
          ref.read(gameProvider.notifier).rotateCube(details.delta, size);
        },
        onPanEnd: (_) {
          ref.read(gameProvider.notifier).onDragEnd();
        },
        child: AnimatedBuilder(
          animation: _ballAnim,
          builder: (context, _) {
            // Interpolate ball position for smooth animation
            final t = _ballAnim.value;
            final dx = (_currBallPos.x - _prevBallPos.x) * t;
            final dy = (_currBallPos.y - _prevBallPos.y) * t;
            // Use fractional offset for rendering
            final ballOffset = Offset(dx, dy);

            return CustomPaint(
              size: size,
              painter: CubePainter(
                cube: gameState.level.cube,
                orientation: gameState.cubeOrientation,
                ballPosition: _prevBallPos,
                ballOffset: ballOffset,
                traveledPath: gameState.traveledPath,
              ),
            );
          },
        ),
      );
    });
  }
}
