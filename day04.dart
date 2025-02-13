import 'package:collection/collection.dart';
import 'package:petitparser/petitparser.dart';

import 'utils/input.dart';
import 'utils/string_extensions.dart';
import 'utils/parse_utils.dart';
import 'utils/test.dart';


class Room {
  final String encryptedName;
  final int sectorId;
  final String checksum;

  Room(this.encryptedName, this.sectorId, this.checksum);

  @override
  String toString() => 'Room($encryptedName, $sectorId, $checksum)';
}

final nameMatcher = (
  (lexical &
  string("-")).plus()
).map((m) => m.flattened.join().chomp('-'));

final matcher = (
  nameMatcher &
  number &
  lexical.between('[', ']')
  ).map((m) {
    return Room(m[0] as String, m[1] as int, m[2] as String);
  });

List<Room> parse(String s) => s.lines().map((it) => matcher.allMatches(it).first).toList();

Future<void> main() async {
  myTest(isRealRoom(parse('aaaaa-bbb-z-y-x-123[abxyz]')[0]), true);
  myTest(isRealRoom(parse('a-b-c-d-e-f-g-h-987[abcde]')[0]), true);
  myTest(isRealRoom(parse('not-a-real-room-404[oarel]')[0]), true);
  myTest(isRealRoom(parse('totally-real-room-200[decoy]')[0]), false);

  final data = parse(await getInput('day04'));
  myTest(data.where(isRealRoom).map((it) => it.sectorId).sum, 173787);

  myTest(data.where(isRealRoom)
    .firstWhere((room) => decypher(room) == 'northpole object storage')
    .sectorId,
    548);

  // for (final room in data.where(isRealRoom)) {
  //   print('${decypher(room)}, ${room.sectorId}');
  // }
}

bool isRealRoom(Room room) {
  final temp = room.encryptedName.split('').where((c) => c != '-')
    .groupFoldBy((c) => c, (int? p, c) => (p ?? 0) + 1)
    .entries.toList();
  temp.sort((e1, e2) => e2.value == e1.value 
    ? e1.key.compareTo(e2.key)
    :  e2.value - e1.value);
  final checksum = temp.map((t) => t.key).take(5).join();
  return checksum == room.checksum;
}


String shift(String c, int sectorId) {
  final alpha = 'abcdefghijklmnopqrstuvwxyz';
  final i = alpha.indexOf(c);
  return alpha[(i + sectorId) % alpha.length];
}

String decypher(Room room) {
  return room.encryptedName.split('-')
    .map((w) => w.split('').map((c) => shift(c, room.sectorId)).join())
    .join(' ');
}