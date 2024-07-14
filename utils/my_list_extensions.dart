import 'package:collection/collection.dart';

extension MyListExtensions<T> on List<T> {
  Iterable<List<T>> permute() sync* {
    if (isEmpty) {
      yield [];
      return;
    }
    for(final (index, value) in indexed) {
      final remaining = sublist(0, index) + sublist(index + 1);
      for(final other in remaining.permute()) {
        yield [value] + other;
      }
    }
  }
}

extension MyListListExtensions<T> on List<List<T>> {
  List<List<T>> invert() {
    final columns = this[0].map((_) => <T>[]).toList();
    for (final row in this) {
      for (final (column, item) in row.indexed) {
        columns[column].add(item);
      }
    }
    return columns;
  }
}