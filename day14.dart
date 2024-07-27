import 'dart:collection';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:test/test.dart';

import 'utils/input.dart';
import 'utils/lle.dart';
import 'utils/string_extensions.dart';
import 'utils/xrange.dart';

Future<void> main() async {
  final data = (await getInput('day14')).lines().first;
  group("Day 14", (){
    group("Part 1", (){
      test("Sample", () => expect(do1('abc'), equals(22728)));
      test("Data", () => expect(do1(data), equals(25427)));
    });
    group("Part 2", (){
      test("Sample", () => expect(do1('abc', true), equals(22551)), skip: 'too long: 45s');
      test("Data", () => expect(do1(data, true), equals(22045)), skip: 'too long: 45s');
    });
  });
}

int do1(String salt, [bool stretch = false]) {
  final threes = Queue<Md5Tuple>();
  var keyCount = 0;
  final fives = Queue<Md5Tuple>();
  for(final current in generateMd5Tuples(salt, stretch)) {
    var check = false;
    if (current.three != null) {
      // print('Adding threes: $current');
      threes.add(current);
    }
    if (current.fives.isNotEmpty) {
      // print('Adding fives: $current');
      fives.add(current);
      check = true;
    }

    if (threes.isNotEmpty && threes.first.index < current.index - 1000) {
      // print('Removing three: ${threes.first} ${current.index}');
      threes.removeFirst();
      check = true;
    }
    
    if (check) {
      for (final needle in threes.takeWhile((three) => fives.any((five) => five.index != three.index && five.fives.contains(three.three))).toList()) {
        keyCount += 1;
        // final ff = fives.where((five) => five.fives.contains(needle.three)).first;
        // print('Found $keyCount $needle $ff');
        if (keyCount == 64) return needle.index;
        threes.removeFirst();
      }
    }

    final sentinel = threes.firstOrNull?.index ?? current.index;
    for (final item in fives.takeWhile((five) => five.index <= sentinel).toList()) {
      // print('Removing five: $item ${threes.first.index}');
      fives.removeFirst();
    }
  }
  print(keyCount);
  throw Exception();
}

typedef Md5Tuple = ({int index, String? three, Set<String> fives});

Iterable<Md5Tuple> generateMd5Tuples(String salt, bool stretch) sync* {
  for(final i in xrange(22728 * 10)) {
    final md5sum = !stretch ? generateMd5('$salt$i'):
      Iterable.generate(2016).fold(generateMd5('$salt$i'), (p,_) => generateMd5(p));
    String? three;
    Set<String> fives = {};
    String current = '';
    int length = 0;
    for (final c in md5sum.split('')) {
      if (current == c) {
        length += 1;
        if (length >= 3) three ??= current;
        if (length >= 5) fives.add(current);
      } else {
        current = c;
        length = 1;
      }
    }

    yield (index: i, three: three, fives: fives);
  }
}

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}