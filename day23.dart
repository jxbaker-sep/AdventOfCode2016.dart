import 'package:test/test.dart';

import 'assem_bunny.dart';
import 'utils/input.dart';

Future<void> main() async {
  final sample = parseAssemBunny(await getInput('day23.sample'));
  final data = parseAssemBunny(await getInput('day23'));

  group('Day 23', (){
    group('optimization tests', (){
      test('5*7', () => expect(assemBunnyExecute(parseAssemBunny(mul0))['a'], equals(35)));
    });
    group('Part 1', (){
      test('Sample', () => expect(assemBunnyExecute(sample)['a'], equals(3)));
      test('Data', () => expect(assemBunnyExecute(data, {'a':7})['a'], equals(12748)));
    });
    group('Part 2', (){
      test('Data', () => expect(assemBunnyExecute(data, {'a':12})['a'], equals(479009308)));
    });
  });
}

const String mul0 = '''
cpy 5 d
cpy 7 b
cpy b c
inc a
dec c
jnz c -2
dec d
jnz d -5
''';