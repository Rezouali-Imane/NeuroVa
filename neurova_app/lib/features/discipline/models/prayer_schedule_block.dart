import '../services/prayer_times_service.dart';

class PrayerScheduleBlock {
  final String name;
  final DateTime scheduledAt;
  final String timeLabel;

  const PrayerScheduleBlock({
    required this.name,
    required this.scheduledAt,
    required this.timeLabel,
  });
}

const _protectedPrayerNames = {'Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'};

List<PrayerScheduleBlock> buildPrayerScheduleBlocks(
  List<PrayerTime>? prayerTimes, {
  DateTime? referenceDate,
}) {
  if (prayerTimes == null || prayerTimes.isEmpty) return const [];

  final date = referenceDate ?? DateTime.now();

  final blocks = prayerTimes
      .where((prayer) => _protectedPrayerNames.contains(prayer.name))
      .map((prayer) {
        final scheduledAt = _parsePrayerTime(prayer.time, date);
        if (scheduledAt == null) return null;

        return PrayerScheduleBlock(
          name: prayer.name,
          scheduledAt: scheduledAt,
          timeLabel: _formatTime(scheduledAt),
        );
      })
      .whereType<PrayerScheduleBlock>()
      .toList()
    ..sort((left, right) => left.scheduledAt.compareTo(right.scheduledAt));

  return blocks;
}

DateTime? _parsePrayerTime(String time, DateTime referenceDate) {
  final normalized = time.trim().split(' ').first;
  final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(normalized);
  if (match == null) return null;

  final hour = int.tryParse(match.group(1) ?? '');
  final minute = int.tryParse(match.group(2) ?? '');
  if (hour == null || minute == null) return null;

  return DateTime(referenceDate.year, referenceDate.month, referenceDate.day, hour, minute);
}

String _formatTime(DateTime time) {
  final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final suffix = time.hour >= 12 ? 'PM' : 'AM';
  return '$hour12:$minute $suffix';
}