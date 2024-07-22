import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'utils/input.dart';
// import 'utils/test.dart';
import 'utils/xrange.dart';
import 'package:test/test.dart';


Future<void> main() async {
  final sample = 'abc';
  final data = await getInput('day05');
  // test(do1(sample), '18f47a30');
  // test(do1(data), '2414bc77');
  // test(do2(data), '437e60fc');
  test('Day 5 part 1, sample', () => expect(do1(sample), equals('18f47a30')));
}

String do1(String id) {
  var result = '';
  for(final i in xrange(0xFFFFFFFF)) {
    final md5 = generateMd5('$id$i');
    if (md5.startsWith('00000')) {
      result += md5[5];
      if (result.length == 8) return result;
    }
  }
  throw Exception();
}

String do2(String id) {
  var result = Iterable.generate(8, (_) => null as String?).toList();
  for(final i in xrange(0xFFFFFFFF)) {
    final md5 = generateMd5('$id$i');
    if (md5.startsWith('00000') && ['0','1','2','3','4','5','6','7'].contains(md5[5])) {
      final position = int.parse(md5[5]);
      final letter = md5[6];
      result[position] ??= letter;
      if (result.every((element) => element != null)) return result.whereType<String>().join();
    }
  }
  throw Exception();
}

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}