import '../utils/coordinate.dart';

enum Face {
  top,    // +Y  bit 0
  bottom, // -Y  bit 1
  right,  // +X  bit 2
  left,   // -X  bit 3
  front,  // +Z  bit 4
  back,   // -Z  bit 5
}

const faceBit = {
  Face.top:    0x01,
  Face.bottom: 0x02,
  Face.right:  0x04,
  Face.left:   0x08,
  Face.front:  0x10,
  Face.back:   0x20,
};

const oppositeFace = {
  Face.top:    Face.bottom,
  Face.bottom: Face.top,
  Face.right:  Face.left,
  Face.left:   Face.right,
  Face.front:  Face.back,
  Face.back:   Face.front,
};

// Which face you exit when stepping in each delta direction
final deltaToFace = {
  Coordinate(1, 0, 0):  Face.right,
  Coordinate(-1, 0, 0): Face.left,
  Coordinate(0, 1, 0):  Face.top,
  Coordinate(0, -1, 0): Face.bottom,
  Coordinate(0, 0, 1):  Face.front,
  Coordinate(0, 0, -1): Face.back,
};
