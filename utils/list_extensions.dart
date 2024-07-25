// ignore_for_file: unused_import

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

  Iterable<(T, T)> pairs() sync* {
    for (final (index, item1) in indexed) {
      for (final item2 in skip(index+1)) {
        yield (item1, item2);
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