import 'package:collection/collection.dart';

import 'utils/input.dart';
import 'utils/iterable_extensions.dart';
import 'utils/string_extensions.dart';
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
    if (amount + used > size) throw Exception();
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
  final data = parse(await getInput('day22'));
  // final sample = parse(await getInput('day22.sample'));
  myTest(do1(data), 993);

  // Note: part 2 was done by hand. I could make an algorithm for it now that
  // I understand the limited shape of the data, but why bother?
  // print("sample");
  // test(do2(sample), 7);
  // print("data");
  // test(do2(data), 202);

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

typedef SearchNode = ({Position dataLocation, Grid grid, List<Position> shoveList, List<Position> cursorTail, int steps});

extension on SearchNode {
  int get priority => steps + (shoveList.firstOrNull ?? dataLocation).manhattanDistance();
}

int priorityFunction(SearchNode a, SearchNode b) => a.priority - b.priority;

int do2(List<GridNode> start_) {
  final goal = Position.Zero;
  final open = PriorityQueue<SearchNode>(priorityFunction);
  final startGrid = Grid(start_);
  final startLocation = Position(startGrid.columns  -1, 0);
  final closed = {startLocation: 0};
  open.add((dataLocation: startLocation, grid: startGrid, shoveList: [], cursorTail: [], steps: 0));
  print(startLocation);
  print(start_.where((it) => it.used == 0).toList());
  while (open.isNotEmpty) {
    final current = open.removeFirst();

    final already2 = closed[current.shoveList.firstOrNull ?? current.dataLocation];
    if (already2 is int && already2 < current.steps) continue;


    for(final neighbor in neighbors(current)) {
      if (neighbor.dataLocation == goal) return neighbor.steps;
      final already = closed[neighbor.shoveList.firstOrNull ?? neighbor.dataLocation];
      if (already is int && already < neighbor.steps) continue;
      if (neighbor.shoveList.isEmpty) {
        closed[neighbor.dataLocation] = neighbor.steps;
      }
      open.add(neighbor);
    }
  }
  throw Exception();
}

Iterable<SearchNode> neighbors(SearchNode node) sync* {
  if (node.shoveList.isEmpty) {
    for(final neighbor in node.dataLocation.orthogonalNeighbors()
      .where((neighbor) => node.grid.contains(neighbor))
      .where((neighbor) => !node.cursorTail.contains(neighbor))
    ) {
      final nn = node.grid.nodes[neighbor]!;
      final cursor = node.grid.nodes[node.dataLocation]!;
      if (nn.size < cursor.used) continue;

      if (nn.avail >= cursor.used) {
        // print('moving cursor to $neighbor');
        yield (dataLocation: neighbor, grid: move(node.grid, [node.dataLocation, neighbor]), shoveList: [], cursorTail: node.cursorTail + [node.dataLocation], steps: node.steps + 1);
      }
      if (nn.used > 0) {
        // print('shoving from cursor into $neighbor');
        yield (dataLocation: node.dataLocation, grid: node.grid, shoveList: [neighbor], cursorTail: node.cursorTail, steps: node.steps + 2);
      }
    }
    return;
  }

  for(final neighbor in node.shoveList.last.orthogonalNeighbors()
    .where((neighbor) => node.grid.contains(neighbor))
    .where((neighbor) => node.dataLocation != neighbor)
    .where((neighbor) => !node.shoveList.contains(neighbor))) {
    final shovingTo = node.grid.nodes[neighbor]!;
    final shovingFrom = node.grid.nodes[node.shoveList.last]!;

    if (shovingTo.size < shovingFrom.used) continue;

    if (shovingTo.avail >= shovingFrom.used) {
      // print('moving $shovingFrom to $shovingTo');
      yield (dataLocation: node.shoveList.first, 
        grid: move(node.grid, [node.dataLocation] + node.shoveList + [neighbor]), 
        shoveList: [], 
        cursorTail: node.cursorTail + [node.dataLocation], 
        steps: node.steps
      );
    } 
    if (shovingTo.used > 0) {
      // print('shoving $shovingFrom to $shovingTo');
      yield (dataLocation: node.dataLocation, grid: node.grid, shoveList: node.shoveList + [shovingTo.p], cursorTail: node.cursorTail, steps: node.steps + 1);
    }
  }
}

Grid move(Grid original, List<Position> sourceToDestination) {
  final nodes = original.nodes.values.toMap((it) => it.p, (it) => it);
  for(var i = sourceToDestination.length - 2; i >= 0; i--) {
    final source = sourceToDestination[i];
    final destination = sourceToDestination[i+1];
    final originalSource = nodes[source]!;
    final originalDestination = nodes[destination]!;
    nodes[source] = originalSource.addData(-originalSource.used);
    nodes[destination] = originalDestination.addData(originalSource.used);
  }

  return Grid(nodes.values);
}