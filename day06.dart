import 'package:collection/collection.dart';
import 'package:test/test.dart';

import 'utils/input.dart';
import 'utils/my_string_extensions.dart';
import 'utils/my_list_extensions.dart';


List<String> parse(String s) => s.lines();

Future<void> main() async {
  final sample = parse(await getInput('day06.sample'));
  final data = parse(await getInput('day06'));

  test('Day 06 part 1 sample', () => expect(do1(sample), equals('easter')));
  test('Day 06 part 1 data', () => expect(do1(data), equals('ygjzvzib')));
  test('Day 06 part 2 sample', () => expect(do2(sample), equals('advent')));
  test('Day 06 part 2 data', () => expect(do2(data), equals('pdesmnoz')));

}

String do1(List<String> messages) {
  final inverted = messages.map((m) => m.split('')).toList().invert();

  return inverted.map((column) {
    final collected = column.groupFoldBy((it) => it, (int? previous, it) => (previous ?? 0) + 1);
    return collected.entries.reduce((a, b) => a.value > b.value ? a : b ).key;
  }).join();
}

String do2(List<String> messages) {
  final inverted = messages.map((m) => m.split('')).toList().invert();

  return inverted.map((column) {
    final collected = column.groupFoldBy((it) => it, (int? previous, it) => (previous ?? 0) + 1);
    return collected.entries.reduce((a, b) => a.value < b.value ? a : b ).key;
  }).join();
}