import 'package:collection/collection.dart';

import 'utils/input.dart';
import 'utils/my_iterable_extensions.dart';
import 'utils/my_string_extensions.dart';
import 'utils/position.dart';
import 'utils/test.dart';

class GridNode {
  final Position p;
  final int size;
  final int used;
  final int avail;
  final String _repr;

  GridNode(this.p, this.size, this.used, this.avail) 
    : _repr = '${p.x},${p.y},$size,$used,$avail';

  GridNode addData(int amount) {
    return GridNode(p, size, used + amount, avail - amount);
  }

  @override
  int get hashCode => _repr.hashCode;
  
  @override
  bool operator ==(Object other) {
    return other is GridNode && other._repr == _repr;
  }

  @override
  String toString() => _repr;
}

class Grid {
  final Map<Position, GridNode> nodes;
  final String _repr;
  final int rows;
  final int columns;


  Grid(Iterable<GridNode> nodes) :
    nodes = nodes.toMap((it) => it.p, (it) => it),
    rows = nodes.map((it) => it.p.y).max + 1,
    columns = nodes.map((it) => it.p.x).max + 1,
    _repr = _computeRepr(nodes);

  static String _computeRepr(Iterable<GridNode> grid) {
    final temp = grid.toList();
    temp.sort((a,b) => (a.p.y == b.p.y) ? a.p.x - b.p.x : a.p.y - b.p.y);
    return temp.map((it) => it.toString()).join(';');
  }
    
  bool contains(Position p) => nodes.containsKey(p);
  GridNode at(Position p) => nodes[p]!;

  @override
  int get hashCode => _repr.hashCode;
  
  @override
  bool operator ==(Object other) {
    return other is Grid && other._repr == _repr;
  }
}

GridNode parse1(String line) {
  final m = RegExp(r'\d+').allMatches(line).map((m) => m.group(0)!).toList();
  if (m.length != 6) throw Exception();
  return GridNode(Position(int.parse(m[0]), int.parse(m[1])), int.parse(m[2]), int.parse(m[3]), int.parse(m[4]));
}

List<GridNode> parse(String s) => s.lines().map((it) => parse1(it)).toList();

Future<void> main() async {
  final data = parse(await getInput('day21'));
  final sample = parse(await getInput('day21.sample'));
  test(do1(data), 993);

  test(do2(sample), 7);
  // test(do2(data), 0);

}

int do1(List<GridNode> nodes) {
  final sorted = nodes.map((it) => it.avail).toList();
  sorted.sort((a,b) => a - b);

  var viablePairs = 0;
  for(final node in nodes.where((node) => node.used > 0)) {
    var index = sorted.length - lowerBound(sorted, node.used);
    if (node.avail >= node.used) index -= 1;
    viablePairs += index;
  }

  return viablePairs;
}

typedef SearchNode = ({Position dataLocation, Grid grid, int steps});

int do2(List<GridNode> start_) {
  final goal = Position.Zero;
  final open = PriorityQueue<SearchNode>((a,b) => (a.steps + a.dataLocation.manhattanDistance(goal)) - (b.steps + b.dataLocation.manhattanDistance(goal)));
  final startGrid = Grid(start_);
  final startLocation = Position(startGrid.columns  -1, 0);
  final closed = {startGrid};
  open.add((dataLocation: startLocation, grid: startGrid, steps: 0));
  while (open.isNotEmpty) {
    final current = open.removeFirst();
    for(final neighbor in neighbors(current)) {
      if (neighbor.dataLocation == goal) return neighbor.steps;
      if (!closed.add(neighbor.grid)) continue;
      open.add(neighbor);
    }
  }
  throw Exception();
}

Iterable<SearchNode> neighbors(SearchNode node) sync* {
  for(final sourcePoint in node.grid.nodes.keys) {
    for (final destinationPoint in sourcePoint.orthogonalNeighbors()) {
      if (!node.grid.contains(destinationPoint)) continue;
      final sourceNode = node.grid.at(sourcePoint);
      final destinationNode = node.grid.at(destinationPoint);
      if (destinationNode.avail < sourceNode.used) continue;
      
      final tempGrid = node.grid.nodes.values.toMap((it) => it.p, (it)=>it);
      tempGrid[sourcePoint] = sourceNode.addData(-sourceNode.used);
      tempGrid[destinationPoint] = destinationNode.addData(sourceNode.used);
      final current = sourceNode.p == node.dataLocation ? destinationNode.p : node.dataLocation;
      yield (dataLocation: current, grid: Grid(tempGrid.values), steps: node.steps + 1);
    }
  }
}