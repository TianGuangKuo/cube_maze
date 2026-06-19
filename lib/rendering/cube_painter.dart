import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import '../models/cube_block.dart';
import '../models/face.dart';
import '../models/game_cube.dart';
import '../utils/coordinate.dart';

class CubePainter extends CustomPainter {
  final GameCube cube;
  final Quaternion orientation;
  final Coordinate ballPosition;
  final Offset ballOffset; // fractional step for animation (in cell units)
  final List<Coordinate> traveledPath;

  CubePainter({
    required this.cube,
    required this.orientation,
    required this.ballPosition,
    this.ballOffset = Offset.zero,
    required this.traveledPath,
  });

  static const double _cellSize = 40.0;
  // Cells are centered: (0,0,0) center is at (-1.5,-1.5,-1.5) in world units
  static const double _half = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Build list sorted back→front (painter's algorithm)
    final cells = <_CellEntry>[];
    for (int z = 0; z < 4; z++) {
      for (int y = 0; y < 4; y++) {
        for (int x = 0; x < 4; x++) {
          final c = Coordinate(x, y, z);
          if (cube.at(c).isEmpty) continue;
          final worldPos = _cellWorld(x, y, z);
          final rotated = orientation.rotate(worldPos);
          cells.add(_CellEntry(c, rotated.z));
        }
      }
    }
    cells.sort((a, b) => a.depth.compareTo(b.depth));

    // Viewer direction in cube-local space (inverse of orientation applied to (0,0,1))
    final invQ = orientation.conjugated();
    final viewDir = invQ.rotate(Vector3(0, 0, 1))..normalize();

    for (final entry in cells) {
      _drawCell(canvas, entry.coord, viewDir, center);
    }

    _drawBall(canvas, center);
  }

  Vector3 _cellWorld(int x, int y, int z) => Vector3(
        (x - _half).toDouble(),
        (y - _half).toDouble(),
        (z - _half).toDouble(),
      );

  // 8 unit-cube corner offsets (local space, centered on origin)
  static final List<List<double>> _cornerOffsets = [
    [-0.5, -0.5, -0.5], // 0
    [0.5, -0.5, -0.5], // 1
    [-0.5, 0.5, -0.5], // 2
    [0.5, 0.5, -0.5], // 3
    [-0.5, -0.5, 0.5], // 4
    [0.5, -0.5, 0.5], // 5
    [-0.5, 0.5, 0.5], // 6
    [0.5, 0.5, 0.5], // 7
  ];

  // Each face: (Face, outward normal vector, 4 corner indices)
  static final _faceSpecs = <(Face, List<double>, List<int>)>[
    (Face.top, [0.0, 1.0, 0.0], [2, 3, 7, 6]),
    (Face.bottom, [0.0, -1.0, 0.0], [4, 5, 1, 0]),
    (Face.right, [1.0, 0.0, 0.0], [1, 5, 7, 3]),
    (Face.left, [-1.0, 0.0, 0.0], [4, 0, 2, 6]),
    (Face.front, [0.0, 0.0, 1.0], [4, 5, 7, 6]),
    (Face.back, [0.0, 0.0, -1.0], [0, 1, 3, 2]),
  ];

  void _drawCell(Canvas canvas, Coordinate c, Vector3 viewDir, Offset center) {
    final block = cube.at(c);

    // Compute screen positions of 8 corners
    final cx = c.x.toDouble();
    final cy = c.y.toDouble();
    final cz = c.z.toDouble();

    final screenCorners = List.generate(8, (i) {
      final off = _cornerOffsets[i];
      final wp = Vector3(
        cx - _half + off[0],
        cy - _half + off[1],
        cz - _half + off[2],
      );
      return _project(orientation.rotate(wp), center);
    });

    for (final spec in _faceSpecs) {
      final (face, normalArr, cornerIdx) = spec;

      final normal = Vector3(normalArr[0], normalArr[1], normalArr[2]);
      // Back-face cull
      if (normal.dot(viewDir) <= 0.02) continue;

      final pts = cornerIdx.map((i) => screenCorners[i]).toList();
      final path = Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..lineTo(pts[2].dx, pts[2].dy)
        ..lineTo(pts[3].dx, pts[3].dy)
        ..close();

      final brightness = 0.28 + normal.dot(viewDir) * 0.42;
      Color faceColor;
      faceColor = HSLColor.fromAHSL(0.68, 215, 0.55, brightness).toColor();

      canvas.drawPath(path, Paint()..color = faceColor.withOpacity(0.38));

      // Pipe opening on this face
      if (block.connectsTo(face)) {
        final fc =
            pts.fold(Offset.zero, (a, b) => a + b) / pts.length.toDouble();
        _drawPipeOpening(
          canvas,
          fc,
          false,
          block.connectionCount,
        );
      }
    }
  }

  void _drawPipeOpening(
      Canvas canvas, Offset faceCenter, bool active, int connections) {
    final radius = _cellSize * 0.16;
    final color = active
        ? Colors.orange.shade200
        : (connections >= 5 ? Colors.white70 : const Color(0xFF80D4FF));
    canvas.drawCircle(
      faceCenter,
      radius,
      Paint()..color = color,
    );
    // Outer ring
    canvas.drawCircle(
      faceCenter,
      radius * 1.5,
      Paint()
        ..color = color.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _drawBall(Canvas canvas, Offset center) {
    // Interpolate world position
    final wx = (ballPosition.x + ballOffset.dx) - _half;
    final wy = (ballPosition.y + ballOffset.dy) - _half;
    final wz = ballPosition.z.toDouble() - _half;

    final screen = _project(orientation.rotate(Vector3(wx, wy, wz)), center);
    final radius = _cellSize * 0.27;

    final gradient = RadialGradient(
      center: const Alignment(-0.35, -0.4),
      radius: 0.75,
      colors: [
        Colors.white,
        Colors.grey.shade300,
        Colors.grey.shade500,
        Colors.grey.shade800,
      ],
      stops: const [0.0, 0.25, 0.65, 1.0],
    );

    final rect = Rect.fromCircle(center: screen, radius: radius);
    canvas.drawCircle(
        screen, radius, Paint()..shader = gradient.createShader(rect));
    canvas.drawCircle(
      screen + Offset(-radius * 0.28, -radius * 0.28),
      radius * 0.18,
      Paint()..color = Colors.white.withOpacity(0.85),
    );
  }

  Offset _project(Vector3 v, Offset center) => Offset(
        center.dx + v.x * _cellSize,
        center.dy - v.y * _cellSize,
      );

  @override
  bool shouldRepaint(CubePainter old) =>
      old.orientation != orientation ||
      old.ballPosition != ballPosition ||
      old.ballOffset != ballOffset ||
      old.traveledPath.length != traveledPath.length;
}

class _CellEntry {
  final Coordinate coord;
  final double depth;
  _CellEntry(this.coord, this.depth);
}
