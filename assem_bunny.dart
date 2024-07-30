

// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:either_dart/either.dart';
import 'package:petitparser/petitparser.dart';

import 'utils/parse_utils.dart';
import 'utils/string_extensions.dart';

List<AssemBunnyInstruction> parseAssemBunny(String s) => s.lines().map((m) => matcher.allMatches(m).single).toList();

enum RegisterLabel {
  a,b,d,c,out
}

class Registers {
  int a = 0;
  int b = 0;
  int c = 0;
  int d = 0;
  int out = 0;

  Registers();

  Registers.from(Registers other) {
    a = other.a;
    b = other.b;
    c = other.c;
    d = other.d;
    out = other.out;
  }

  void set(RegisterLabel r, int value) {
    switch (r) {
      case RegisterLabel.a: a = value;
      case RegisterLabel.b: b = value;
      case RegisterLabel.c: c = value;
      case RegisterLabel.d: d = value;
      case RegisterLabel.out: out = value;
    }
  }

  int get(RegisterLabel r) {
    switch (r) {
      case RegisterLabel.a: return a;
      case RegisterLabel.b: return b;
      case RegisterLabel.c: return c;
      case RegisterLabel.d: return d;
      case RegisterLabel.out: return out;
    }
  }

  @override
  bool operator==(Object other) =>
      other is Registers && a == other.a && b == other.b && c == other.c && d == other.d && out == other.out;
      
  @override
  int get hashCode => Object.hashAll([a,b,c,d,out]);
       
}

Registers assemBunnyExecute(Iterable<AssemBunnyInstruction> originalInstructions, [Map<RegisterLabel, int> registerMods = const {}])
  => assemBunnyIterate(originalInstructions, registerMods).last;

Iterable<Registers> assemBunnyIterate(Iterable<AssemBunnyInstruction> originalInstructions, [Map<RegisterLabel, int> registerMods = const {}]) sync* {
  final instructions = originalInstructions.toList();
  final r = Registers();
  for (final entry in (registerMods).entries) {
    r.set(entry.key, entry.value);
  }
  var pc = 0;

  bool multiplyOptimize() {
    if (pc < instructions.length - 5) {
      if (instructions[pc + 0] case CopyInstruction(source: var s0, destination: var d0)) 
      if (instructions[pc + 1] case Inc(increment: var i1, destination: var d1)) 
      if (instructions[pc + 2] case Inc(increment: var i2, destination: var d2) when i2 == -1 && d0 == d2) 
      if (instructions[pc + 3] case Jnz(condition: var c3, pcShift: var shift3) when shift3.fold((_) => false, (r) => r == -2) && c3.fold((l) => l == d2, (_) => false)) 
      if (instructions[pc + 4] case Inc(increment: var i4, destination: var d4) when i4 == -1) 
      if (instructions[pc + 5] case Jnz(condition: var c5, pcShift: var shift5) when shift5.fold((_) => false, (r) => r == -5) && c5.fold((l) => l == d4, (_) => false)) {
        // d0 is same as d2, don't need to set
        r.set(d1, r.get(d1) + i1 * r.get(d4) * r.resolve(s0));
        r.set(d2, 0);
        r.set(d4, 0);
        pc += 6;
        return true;
      }
    }
    return false;
  }

  bool toggle() {
    if (instructions[pc] case Tgl tgl) {
      final index = pc + r.get(tgl.destination);
      if (index < instructions.length) instructions[index] = instructions[index].toggle();
      pc += 1;
      return true;
    }
    return false;
  }

  while (pc < instructions.length) {
    if (multiplyOptimize()) continue;
    if (toggle()) continue;
    final i = instructions[pc];
    pc += i.execute(r) ?? 1;
    if (i is Out) yield Registers.from(r);
  }
  yield r;
}

abstract class AssemBunnyInstruction {
  int? execute(Registers r);
  AssemBunnyInstruction toggle();
}

typedef RValue = Either<RegisterLabel, int>;

extension on Registers {
  int resolve(RValue l) => l.fold((x) => get(x), (i) => i);
}

class NulledCopyInstruction extends AssemBunnyInstruction {
  final RValue source;
  final int destination;

  NulledCopyInstruction(this.source, this.destination);
  
  @override
  int? execute(Registers r) {
    return null;
  }
  
  @override
  AssemBunnyInstruction toggle() => Jnz(source, Right(destination));
}

class CopyInstruction extends AssemBunnyInstruction {
  final RValue source;
  final RegisterLabel destination;

  CopyInstruction(this.source, this.destination);
  
  @override
  int? execute(Registers r) {
    r.set(destination, r.resolve(source));
    return null;
  }
  
  @override
  AssemBunnyInstruction toggle() => Jnz(source, Left(destination));
}

class Inc extends AssemBunnyInstruction {
  final int increment;
  final RegisterLabel destination;

  Inc(this.increment, this.destination);  
  
  @override
  int? execute(Registers r) {
    r.set(destination, r.get(destination) + increment);
    return null;
  }
  
  @override
  AssemBunnyInstruction toggle() => Inc(-increment, destination);
}

class Jnz extends AssemBunnyInstruction {
  final RValue condition;
  final RValue pcShift;

  Jnz(this.condition, this.pcShift);
  
  @override
  int? execute(Registers r) {
    return (r.resolve(condition) != 0) ? r.resolve(pcShift) : null;
  }
  
  @override
  AssemBunnyInstruction toggle() => pcShift.fold((l) => CopyInstruction(condition, l), (r) => NulledCopyInstruction(condition, r));
}

class Tgl extends AssemBunnyInstruction {
  final RegisterLabel destination;

  Tgl(this.destination);
  
  @override
  int? execute(Registers r) {
    throw UnimplementedError();
  }
  
  @override
  AssemBunnyInstruction toggle() => Inc(1, destination);
}

class Out extends AssemBunnyInstruction {
  final RValue source;

  Out(this.source);
  
  @override
  int? execute(Registers r) {
    r.out = r.resolve(source);
    return null;
  }
  
  @override
  AssemBunnyInstruction toggle() {
    throw UnimplementedError();
  }
}

final matcher = [copyLiteralP, copyRegisterP, incP, decP , jnz, tglP, outP].toChoiceParser();
final copyLiteralP = seq2(number.before("cpy"), registerP).map((m) => CopyInstruction(Right(m.$1), m.$2));
final copyRegisterP = seq2(registerP.before("cpy"), registerP).map((m) => CopyInstruction(Left(m.$1), m.$2));
final incP = registerP.before("inc").map((m) => Inc(1, m));
final decP = registerP.before("dec").map((m) => Inc(-1, m));
final tglP = registerP.before("tgl").map((m) => Tgl(m));
final jnz = seq2(rValueP.before("jnz"), rValueP).map((m) => Jnz(m.$1, m.$2));
final outP = rValueP.before("out").map((m) => Out(m));

final registerP = oneOf(['a', 'b', 'c', 'd']).map((m) => switch(m) { 
  'a' => RegisterLabel.a, 
  'b' => RegisterLabel.b, 
  'c' => RegisterLabel.c, 
  'd' => RegisterLabel.d,
  _ => throw Exception() 
});
final rValueP = (registerP | number).map((m) => switch(m) {
  int i => Right<RegisterLabel, int>(i),
  RegisterLabel m => Left<RegisterLabel, int>(m),
  _ => throw Exception()
}); 