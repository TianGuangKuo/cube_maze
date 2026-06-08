import 'package:flutter/material.dart';

class SolvedOverlay extends StatefulWidget {
  final int moveCount;
  final int parMoves;
  final VoidCallback onNext;
  final VoidCallback onReplay;

  const SolvedOverlay({
    super.key,
    required this.moveCount,
    required this.parMoves,
    required this.onNext,
    required this.onReplay,
  });

  @override
  State<SolvedOverlay> createState() => _SolvedOverlayState();
}

class _SolvedOverlayState extends State<SolvedOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.4)));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int get _stars {
    if (widget.moveCount <= widget.parMoves) return 3;
    if (widget.moveCount <= widget.parMoves * 1.5) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A2E4A), Color(0xFF0D1B2A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: Colors.lightBlueAccent.withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                      color: Colors.lightBlueAccent.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 2)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🎉 通关！',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.star_rounded,
                          size: 36,
                          color: i < _stars ? Colors.amber : Colors.white24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '用了 ${widget.moveCount} 步',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _OverlayBtn(
                          label: '再玩一次',
                          icon: Icons.replay,
                          color: Colors.white12,
                          textColor: Colors.white70,
                          onTap: widget.onReplay,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _OverlayBtn(
                          label: '下一关',
                          icon: Icons.arrow_forward_ios,
                          color: Colors.lightBlueAccent.withOpacity(0.25),
                          textColor: Colors.lightBlueAccent,
                          onTap: widget.onNext,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverlayBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  const _OverlayBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: textColor.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
