
class Position {
  final int x;
  final int y;

  Position(this.x, this.y);

  @override
  bool operator==(Object other) =>
      other is Position && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);

  Iterable<Position> neighbors() sync* {
    yield Position(x-1, y-1);
    yield Position(x+0, y-1);
    yield Position(x+1, y-1);
    yield Position(x-1, y);
    yield Position(x+1, y);
    yield Position(x-1, y+1);
    yield Position(x+0, y+1);
    yield Position(x+1, y+1);
  }

  Position operator+(Vector other) => Position(x + other.x, y + other.y);

  // ignore: non_constant_identifier_names
  static final Position Zero = Position(0, -1);
}

class Vector {
  final int x;
  final int y;

  Vector(this.x, this.y);

  @override
  bool operator==(Object other) =>
      other is Vector && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);

  Vector operator*(int magnitude) => Vector(x * magnitude, y * magnitude);

  // ignore: non_constant_identifier_names
  static final Vector North = Vector(0, -1);
  // ignore: non_constant_identifier_names
  static final Vector South = Vector(0, 1);
  // ignore: non_constant_identifier_names
  static final Vector East = Vector(1, 0);
  // ignore: non_constant_identifier_names
  static final Vector West = Vector(-1, 0);
}


extension PositionExtensions on Position {
  int manhattanDistance(Position other) => (x - other.x).abs() + (y - other.y).abs();

  Iterable<Position> neighbors() sync* {
    yield* orthogonalNeighbors();
    yield* diagonalNeighbors();
  }

  Iterable<Position> orthogonalNeighbors() sync* {
    yield this + Vector.North;
    yield this + Vector.East;
    yield this + Vector.West;
    yield this + Vector.South;
  }

  Iterable<Position> diagonalNeighbors() sync* {
    yield this + Vector.North + Vector.East;
    yield this + Vector.North + Vector.West;
    yield this + Vector.South + Vector.East;
    yield this + Vector.South + Vector.West;
  }
}

extension VectorExtensions on Vector {
  Vector rotateLeft() => Vector(y, -x);
  Vector rotateRight() => Vector(-y, x);
}
