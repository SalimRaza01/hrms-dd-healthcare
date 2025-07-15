import 'package:hive_flutter/hive_flutter.dart';

clearHive() {
  final trackBox = Hive.box('trackBox');

  if (trackBox.isNotEmpty) {
    final firstEntry = trackBox.getAt(0);
    final timestampString = firstEntry?['timestamp'];

    if (timestampString != null) {
      final entryTimestamp = DateTime.parse(timestampString);
      final now = DateTime.now();

      final isSameDay = entryTimestamp.year == now.year &&
          entryTimestamp.month == now.month &&
          entryTimestamp.day == now.day;

      if (!isSameDay) {
        trackBox.clear();
        Hive.box('movementBox').clear();
        Hive.box('markerBox').clear();
      }
    }
  }
}