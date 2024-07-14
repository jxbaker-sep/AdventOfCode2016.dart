import 'package:collection/collection.dart';

extension MyIterableExtensions<T> on Iterable<T> {
  int sumBy(int Function(T t) callback) {
    return isEmpty ? 0 : map(callback).reduce((a,b)=>a+b);
  }

  int maxBy(int Function(T t) callback) => map(callback).max;
  int minBy(int Function(T t) callback) => map(callback).min;

  Iterable<T2> flatmap<T2>(Iterable<T2> Function(T t) callback) {
    return map(callback).expand((i)=>i);
  }

  Map<T2, T3> toMap<T2, T3>(T2 Function(T t) asKey, T3 Function(T t) asValue) {
    final result = <T2, T3>{};
    for(final item in this) {
      result[asKey(item)] = asValue(item);
    }
    return result;
  }
}
