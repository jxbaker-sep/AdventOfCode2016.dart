
import 'package:collection/collection.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'utils/input.dart';
import 'utils/my_iterable_extensions.dart';
import 'utils/my_string_extensions.dart';
import 'utils/parse_utils.dart';

typedef Subnet = ({bool isHypernet, String address});
typedef Ipv7 = List<Subnet>;

final Parser<Ipv7>  tlsMatcher = ((plain & hypernet).star() & plain.optional())
  .map((m) => (m[0] as List<List<dynamic>>).flattenedToList.whereType<Subnet>().toList() + (m[1] == null ? [] : [m[1] as Subnet]));

final plain = lexical.map((m) => (isHypernet: false, address: m));

final hypernet = (string("[") & lexical & string("]"))
  .map((m) => (isHypernet: true, address: m[1] as String));

List<Ipv7> parse(String s) => s.lines().map((line) => tlsMatcher.allMatches(line).first).toList();

Future<void> main() async {
  final sample = parse(await getInput('day07.sample'));
  final sample2 = parse(await getInput('day07.sample.2'));
  final data = parse(await getInput('day07'));
  group("Day07", (){
    test("part 1 sample", () => expect(do1(sample), equals(2)));
    test("part 1 data", () => expect(do1(data), equals(105)));
    test("part 2 sample", () => expect(do2(sample2), equals(3)));
    test("part 2 data", () => expect(do2(data), equals(258)));
  });
}

int do2(List<Ipv7> list) => list.where(supportsSSL).length;

Iterable<List<int>> abas(String data) => 
  data.codeUnits.windows(3).where((window) => window[0] == window[2] && window[0] != window[1]);

bool containsBAB(String data, List<int> aba) =>
  data.codeUnits.windows(3).any((window) => window[0] == aba[1] && window[1] == aba[0] && window[2] == aba[1]);

bool supportsSSL(Ipv7 element) => element
  .where((segment) => !segment.isHypernet)
  .flatmap((segment) => abas(segment.address))
  .any((aba) => element.any((segment) => segment.isHypernet && containsBAB(segment.address, aba)));

int do1(List<Ipv7> list) => list.where(supportsTls).length;

bool containsAbba(String s) {
  return s.codeUnits.windows(4).any((window) => window[0] == window[3] && window[1] == window[2] && window[0] != window[1]);
}

bool supportsTls(Ipv7 element) => 
  element.where((m) => !m.isHypernet).any((m) => containsAbba(m.address)) && 
  element.where((m) => m.isHypernet).every((m) => !containsAbba(m.address));
