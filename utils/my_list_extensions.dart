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