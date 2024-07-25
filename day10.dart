import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'utils/input.dart';
import 'utils/iterable_extensions.dart';
import 'utils/parse_utils.dart';
import 'utils/string_extensions.dart';

Future<void> main() async {
  final sample = parse(await getInput('day10.sample'));
  final data = parse(await getInput('day10'));

  group("Day 10", (){
    group("Part 1", (){
      test("Sample", () => expect(do1(sample.clone(), 5, 2), equals(2)));
      test("Data", () => expect(do1(data.clone(), 61, 17), equals(27)));
    });
    group("Part 2", (){
      test("Sample", () => expect(do2(sample.clone()), equals(5 * 2 * 3)));
      test("Data", () => expect(do2(data.clone()), equals(13727)));
    });
  });
}

extension on World {
  World clone() => (values: values.toList(), bots: bots.values.toMap((it) => it.id, (it) => Bot.from(it)));
}

int do1(World world, int c1, int c2) {
  final open = Queue<ValueGoesTo>.from(world.values);

  while (open.isNotEmpty) {
    final current = open.removeFirst();
    final bot = world.bots[current.bot]!;

    if (bot.isFull) throw Exception();
    bot.hands.add(current.value);
    if (bot.check(c1, c2)) return bot.id;
    if (bot.isFull) {
      for(final (value, recipientId) in [(bot.hands.min, bot.low), (bot.hands.max, bot.high)]) {
        if (recipientId < 0) continue;
        open.add((bot: recipientId, value: value));
      }
      bot.hands.clear();
    }
  }
  throw Exception();
}

int do2(World world) {
  final open = Queue<ValueGoesTo>.from(world.values);
  final outputs = <int?>[null, null, null];
  final closed = <Bot>{};

  while (open.isNotEmpty) {
    final current = open.removeFirst();
    final bot = world.bots[current.bot]!;

    if (bot.isFull) {
      print(bot.id);
      if (closed.contains(bot)) throw Exception;
      closed.add(bot);
      open.addLast(current);
      continue;
    }
    bot.hands.add(current.value);
    if (bot.isFull) {
      for(final (value, recipientId) in [(bot.hands.max, bot.high), (bot.hands.min, bot.low)]) {
        if (recipientId < 0) {
          final id = -recipientId - 1;
          if (id < outputs.length) outputs[id] = value;
          if (outputs.nonNulls.length == outputs.length) return outputs.nonNulls.product;
          continue;
        }
        open.addFirst((bot: recipientId, value: value));
      }
      closed.remove(bot);
      bot.hands.clear();
    }
  }
  throw Exception();
}


class Bot {
  final int id;
  final List<int> hands;
  final int low;
  final int high;

  Bot(this.id, this.low, this.high) : hands = [];

  Bot.from(Bot other) : id = other.id, low = other.low, high = other.high, hands = other.hands.toList();

  bool get isFull => hands.length == 2;

  bool check(int c1, int c2) {
    if (!isFull) return false;
    return [c1, c2].min == hands.min && [c1, c2].max == hands.max;
  }
}

final valueMatcher = seq2(number.before("value"), number.before("goes to bot"));
final giveMatcher = seq5(
  number.before("bot").after("gives low to"), 
  oneOf(["bot", "output"]),
  number.after("and high to"), 
  oneOf(["bot", "output"]),
  number.end()
);

typedef World = ({List<ValueGoesTo> values, Map<int, Bot> bots});

typedef ValueGoesTo = ({int value, int bot});

World parse(String s) {
  Map<int, Bot> bots = {};
  List<ValueGoesTo> values = s.lines().map((line) => valueMatcher.allMatches(line).firstOrNull)
    .nonNulls.map((m) => (value: m.$1, bot: m.$2)).toList();

  for(final line in s.lines()) {
    final m = giveMatcher.allMatches(line).firstOrNull;
    if (m != null) {
      final id = m.$1;
      final low = m.$2 == 'bot' ? m.$3 : -(m.$3+1);
      final high = m.$4 == 'bot' ? m.$5 : -(m.$5+1);
      bots[id] = Bot(id, low, high);
    }
  }

  return (values: values, bots: bots);
}