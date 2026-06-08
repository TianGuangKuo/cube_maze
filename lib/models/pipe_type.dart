// 9 pipe shapes defined by canonical face-connection bitmasks.
// Face bit order: top=0x01 bottom=0x02 right=0x04 left=0x08 front=0x10 back=0x20

enum PipeType {
  deadEnd,      // 1 face
  straight,     // 2 faces: top+bottom (opposite)
  elbow,        // 2 faces: top+right (adjacent)
  tFlat,        // 3 faces: top+right+left (T in horizontal plane)
  tSpatial,     // 3 faces: top+bottom+right (T through vertical)
  crossFlat,    // 4 faces: top+right+bottom+left (cross in plane)
  crossSpatial, // 4 faces: top+bottom+right+front (3D cross)
  fiveWay,      // 5 faces: all except back
  sixWay,       // 6 faces: all
}

const canonicalMask = {
  PipeType.deadEnd:      0x01, // top
  PipeType.straight:     0x03, // top + bottom
  PipeType.elbow:        0x05, // top + right
  PipeType.tFlat:        0x0D, // top + right + left
  PipeType.tSpatial:     0x07, // top + bottom + right
  PipeType.crossFlat:    0x0F, // top + bottom + right + left
  PipeType.crossSpatial: 0x17, // top + bottom + right + front
  PipeType.fiveWay:      0x1F, // all except back
  PipeType.sixWay:       0x3F, // all 6 faces
};

// 24 valid cube orientations as face-index permutations.
// Entry i maps face-bit-index [0..5] to new face-bit-index after rotation i.
// Face indices: top=0, bottom=1, right=2, left=3, front=4, back=5
const List<List<int>> orientation24 = [
  [0, 1, 2, 3, 4, 5], // 0: identity
  [4, 5, 2, 3, 1, 0], // 1: rot X +90
  [1, 0, 2, 3, 5, 4], // 2: rot X 180
  [5, 4, 2, 3, 0, 1], // 3: rot X -90
  [2, 3, 1, 0, 4, 5], // 4: rot Z +90
  [4, 5, 1, 0, 3, 2], // 5: rot Z+90 then X+90
  [3, 2, 0, 1, 4, 5], // 6: rot Z 180
  [5, 4, 0, 1, 2, 3], // 7: rot Z+90 then X-90 (= Z-90 X+90)
  [1, 0, 3, 2, 4, 5], // 8: rot Z -90
  [4, 5, 3, 2, 0, 1], // 9: rot Z-90 then X+90
  [0, 1, 3, 2, 5, 4], // 10: rot Z-90 then X180
  [5, 4, 3, 2, 1, 0], // 11: rot Z-90 then X-90
  [0, 1, 4, 5, 3, 2], // 12: rot Y +90
  [2, 3, 4, 5, 1, 0], // 13: rot Y+90 then Z+90
  [1, 0, 5, 4, 2, 3], // 14: rot Y+90 then X+90 (up->front)
  [3, 2, 5, 4, 0, 1], // 15: rot Y+90 then Z-90
  [0, 1, 5, 4, 2, 3], // 16: rot Y 180
  [2, 3, 5, 4, 0, 1], // 17: rot Y180 then Z+90
  [1, 0, 4, 5, 3, 2], // 18: rot Y180 then X+90
  [3, 2, 4, 5, 1, 0], // 19: rot Y180 then Z-90
  [0, 1, 5, 4, 3, 2], // 20: rot Y -90
  [2, 3, 0, 1, 5, 4], // 21: rot Y-90 then Z+90
  [1, 0, 4, 5, 2, 3], // 22: rot Y-90 then X+90
  [3, 2, 1, 0, 5, 4], // 23: rot Y-90 then Z-90
];

int applyOrientation(int canonMask, int orientationIndex) {
  final perm = orientation24[orientationIndex];
  int result = 0;
  for (int i = 0; i < 6; i++) {
    if (canonMask & (1 << i) != 0) {
      result |= (1 << perm[i]);
    }
  }
  return result;
}
