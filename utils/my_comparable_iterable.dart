extension MyComparableIterable<T extends Comparable<T>> on Iterable<T> {
  List<T> simpleSort() {
    final l = toList();
    l.sort((a,b) => a.compareTo(b));
    return l;
  }

}
