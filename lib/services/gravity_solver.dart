import 'package:vector_math/vector_math_64.dart';
import '../models/game_cube.dart';
import '../models/face.dart';
import '../utils/coordinate.dart';

/// Computes the next cell the ball should move to based on cube orientation.
/// World gravity is (0, -1, 0). We transform it to cube-local space.
/// The ball moves to the neighbor with the best alignment to gravity,
/// provided a pipe connection exists.
Coordinate? nextBallStep(
  Coordinate current,
  GameCube cube,
  Quaternion cubeOrientation,
) {
  // Inverse quaternion rotates world vectors into cube-local space
  final invQ = cubeOrientation.conjugated();
  final worldGravity = Vector3(0, -1, 0);
  final localGravity = invQ.rotate(worldGravity)..normalize();

  Coordinate? best;
  double bestDot = -0.5; // threshold: must have meaningful gravity component

  for (final delta in kNeighborDeltas) {
    final neighbor = current + delta;
    if (!neighbor.isInBounds) continue;
    if (!cube.areConnected(current, neighbor)) continue;

    // Project neighbor direction onto local gravity
    final dir = Vector3(delta.x.toDouble(), delta.y.toDouble(), delta.z.toDouble());
    final dot = localGravity.dot(dir);
    if (dot > bestDot) {
      bestDot = dot;
      best = neighbor;
    }
  }
  return best;
}

/// Returns the face index (0-5) corresponding to a Vector3 direction.
/// Used for visual feedback: which face is "down" right now.
Face gravityFace(Quaternion cubeOrientation) {
  final invQ = cubeOrientation.conjugated();
  final localG = invQ.rotate(Vector3(0, -1, 0))..normalize();

  final directions = [
    (Face.top,    Vector3( 0,  1,  0)),
    (Face.bottom, Vector3( 0, -1,  0)),
    (Face.right,  Vector3( 1,  0,  0)),
    (Face.left,   Vector3(-1,  0,  0)),
    (Face.front,  Vector3( 0,  0,  1)),
    (Face.back,   Vector3( 0,  0, -1)),
  ];

  Face best = Face.bottom;
  double bestDot = -2;
  for (final (face, dir) in directions) {
    final d = localG.dot(dir);
    if (d > bestDot) {
      bestDot = d;
      best = face;
    }
  }
  return best;
}
