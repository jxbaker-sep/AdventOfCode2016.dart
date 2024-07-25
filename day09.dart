import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'utils/input.dart';
import 'utils/parse_utils.dart';

Future<void> main() async {
  final data = await getInput('day09');
  group("Day 09", (){
    group("Part 1", (){
      test("sample 1", () => expect(decompress("ADVENT"), equals("ADVENT")));
      test("sample 2", () => expect(decompress("A(1x5)BC"), equals("ABBBBBC")));
      test("sample 3", () => expect(decompress("A(2x2)BCD(2x2)EFG"), equals("ABCBCDEFEFG")));
      test("sample 4", () => expect(decompress("(6x1)(1x3)A"), equals("(1x3)A")));
      test("sample 5", () => expect(decompress("X(8x2)(3x3)ABCY"), equals("X(3x3)ABC(3x3)ABCY")));
      test("data", () => expect(decompress(data).length, equals(152851)));
    });

    group("Part 2", (){
      test("sample 1", () => expect(decompressX("(3x3)XYZ"), equals("XYZXYZXYZ")));
      test("sample 2", () => expect(decompressX("X(8x2)(3x3)ABCY"), equals("XABCABCABCABCABCABCY")));
      test("sample 3", () => expect(decompressXL("(27x12)(20x12)(13x14)(7x10)(1x12)A"), equals(241920)));
      test("sample 4", () => expect(decompressXL("(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN"), equals(445)));
      test("data", () => expect(decompressXL(data), equals(0)));

    });
  });
}

int decompressXL(String s) {
  final m = matcher.parse(s);
  if (m is Success) {
    final after = s.substring(m.position);
    final taken = after.substring(0, m.value.$2);
    final remainder = after.substring(m.value.$2);
    return m.value.$1.length + decompressXL(taken) * m.value.$3 + decompressXL(remainder);
  }
  return s.length;
}

String decompressX(String s) {
  final m = matcher.parse(s);
  if (m is Success) {
    final after = s.substring(m.position);
    final taken = after.substring(0, m.value.$2);
    final remainder = after.substring(m.value.$2);
    return m.value.$1 + decompressX(taken) * m.value.$3 + decompressX(remainder);
  }
  return s;
}

final matcher = seq3(noneOf("(").star().flatten(), number.before('('), number.between('x', ')'));

String decompress(String s) { 
  final m = matcher.parse(s);
  if (m is Success) {
    return m.value.$1 + decompress3(s.substring(m.position), m.value.$2, m.value.$3);
  }
  return s;
}

String decompress3(String s, int take, int repeat) {
  return s.substring(0, take) * repeat + decompress(s.substring(take));
}