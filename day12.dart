
import 'package:test/test.dart';
import 'assem_bunny.dart';
import 'utils/input.dart';

Future<void> main() async {
  final sample = parseAssemBunny(await getInput('day12.sample'));
  final data = parseAssemBunny(await getInput('day12'));
  group("Day 12", (){
    group("Part 1", (){
      test("Sample", () => expect(assemBunnyExecute(sample).a, equals(42)));
      test("Data", () => expect(assemBunnyExecute(data).a, equals(318020)));
    });
    group("Part 2", (){
      test("Data", () => expect(assemBunnyExecute(data, {RegisterLabel.c: 1}).a, equals(9227674)));
    });
  });
}
