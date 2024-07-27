import 'dart:collection';

final class LLE<T> extends LinkedListEntry<LLE<T>> {
  T value;
  LLE(this.value);
}