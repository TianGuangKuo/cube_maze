import 'package:flutter/foundation.dart';

@immutable
class Coordinate {
  final int x, y, z;
  const Coordinate(this.x, this.y, this.z);

  bool get isInBounds => x >= 0 && x < 4 && y >= 0 && y < 4 && z >= 0 && z < 4;

  Coordinate operator +(Coordinate other) =>
      Coordinate(x + other.x, y + other.y, z + other.z);

  @override
  bool operator ==(Object other) =>
      other is Coordinate && x == other.x && y == other.y && z == other.z;

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  String toString() => '($x,$y,$z)';
}

const kStart = Coordinate(0, 0, 0);
const kEnd = Coordinate(3, 3, 3);

const kNeighborDeltas = [
  Coordinate(1, 0, 0),
  Coordinate(-1, 0, 0),
  Coordinate(0, 1, 0),
  Coordinate(0, -1, 0),
  Coordinate(0, 0, 1),
  Coordinate(0, 0, -1),
];
