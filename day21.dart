import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'utils/function_extensions.dart';
import 'utils/input.dart';
import 'utils/list_extensions.dart';
import 'utils/parse_utils.dart';
import 'utils/string_extensions.dart';

Future<void> main() async {
  final sample = parse(await getInput('day21.sample'));
  final data = parse(await getInput('day21'));

  group('Day 21', (){
    group('Part 1', (){
      test('1', () => expect(swapPositions(4, 0, 'abcde'.split('')).join(), equals('ebcda')));
      test('1', () => expect(swapLetters('d', 'b', 'ebcda'.split('')).join(), equals('edcba')));
      test('1', () => expect(reversePositions(0, 4, 'edcba'.split('')).join(), equals('abcde')));
      test('1', () => expect(rotateLeft(1, 'abcde'.split('')).join(), equals('bcdea')));
      test('1', () => expect(moveXtoY(1, 4, 'bcdea'.split('')).join(), equals('bdeac')));
      test('1', () => expect(moveXtoY(3, 0, 'bdeac'.split('')).join(), equals('abdec')));
      test('1', () => expect(rotatePosition('b', 'abdec'.split('')).join(), equals('ecabd')));
      test('1', () => expect(rotatePosition('d', 'ecabd'.split('')).join(), equals('decab')));
      test('Sample', () => expect(do1(sample, 'abcde'), equals('decab')));
      test('Data', () => expect(do1(data, 'abcdefgh'), equals('aefgbcdh')));
    });
    group('Part 2', (){
      test('Data', () => expect(do2(data, 'fbgdceah'), equals('egcdahbf'))); // hcaedfgb incorrect
    });
  });
}

String do2(List<OperationFunction> operations, String needle) =>
  'abcdefgh'.split('').permute().where((it) => do1(operations, it.join()) == needle).first.join();

String do1(List<OperationFunction> operations, String s) =>
  operations.fold(s.split(''), (list, operator) => operator(list)).join('');

List<OperationFunction> parse(String s) => s.lines().map((l) => matcher.allMatches(l).single).toList();

typedef OperationFunction = List<String> Function(List<String>);

List<String> swapPositions(int x, int y, List<String> input) {
  final (a,b) = (input[x], input[y]);
  input[x] = b;
  input[y] = a;
  return input;
}

List<String> swapLetters(String a, String b, List<String> input) {
  final x = input.indexOf(a);
  final y = input.indexOf(b);
  return swapPositions(x, y, input);
}

List<String> rotateRight(int steps, List<String> input) {
  final temp = (input.length - steps) % input.length;
  return input.skip(temp).followedBy(input.take(temp)).toList();
}

List<String> rotateLeft(int steps, List<String> input) {
  return input.skip(steps).followedBy(input.take(steps)).toList();
}

List<String> rotatePosition(String a, List<String> input) {
  final i = input.indexOf(a);
  return rotateRight(i + 1 + (i >= 4 ? 1 : 0), input);
}

List<String> reversePositions(int x, int y, List<String> input) {
  return input.take(x).followedBy(input.skip(x).take(y-x+1).toList().reversed)
    .followedBy(input.skip(y+1)).toList();
}

List<String> moveXtoY(int x, int y, List<String> input) {
  final item = input[x];
  final without = input.sublist(0, x) + input.sublist(x+1);
  return without.sublist(0, y) + [item] + without.sublist(y);
}

final matcher = [swapPositionsP, swapLetterP, rotateRightP, rotateLeftP,
  rotateBasedP, reverseP, moveMatcher].toChoiceParser();

final swapPositionsP = seq2(number.between("swap position", "with position"), number)
  .map((m) => apply2(swapPositions, m.$1, m.$2));

final swapLetterP = seq2(letter().between("swap letter", "with letter"), letter())
  .map((m) => apply2(swapLetters, m.$1, m.$2));

final rotateRightP = number.between("rotate right", "step")
  .map((m) => apply1(rotateRight, m));

final rotateLeftP = number.between("rotate left", "step")
  .map((m) => apply1(rotateLeft, m));

final rotateBasedP = letter().before("rotate based on position of letter")
  .map((m) => apply1(rotatePosition, m));

final reverseP = seq2(number.between('reverse positions', 'through'), number)
  .map((m) => apply2(reversePositions, m.$1, m.$2));

final moveMatcher = seq2(number.between('move position', 'to position'), number)
  .map((m) => apply2(moveXtoY, m.$1, m.$2));