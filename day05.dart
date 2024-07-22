import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'utils/test.dart';
import 'utils/xrange.dart';

void main() {
  final sample = 'abc';
  test(do1(sample), '18f47a30');
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

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}