/// Concrete repository implementation — delegates to [LocalScheduleDataSource]
/// and applies filtering logic.
library;

import '../../domain/entities/schedule_entry.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/local_schedule_datasource.dart';
import '../../core/constants/app_constants.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final LocalScheduleDataSource _dataSource;

  ScheduleRepositoryImpl(this._dataSource);

  @override
  Future<List<ScheduleEntry>> getAllEntries() => _dataSource.loadSchedule();

  @override
  Future<List<ScheduleEntry>> getEntriesForDay(String group, String day) async {
    final all = await _dataSource.loadSchedule();
    final normDay = LocalScheduleDataSource.normalizeDay(day);
    return all
        .where((e) => e.group == group && e.day == normDay)
        .toList()
      ..sort(_byStartTime);
  }

  @override
  Future<List<ScheduleEntry>> getFilteredEntries(
    String group,
    String day,
    int section,
  ) async {
    final all = await _dataSource.loadSchedule();
    final normDay = LocalScheduleDataSource.normalizeDay(day);
    return all
        .where((e) =>
            e.group == group &&
            e.day == normDay &&
            e.isRelevantForSection(section))
        .toList()
      ..sort(_byStartTime);
  }

  @override
  Future<Map<String, List<ScheduleEntry>>> getWeeklySchedule(
    String group,
    int section,
  ) async {
    final all = await _dataSource.loadSchedule();
    final Map<String, List<ScheduleEntry>> weekly = {};

    for (final day in AppConstants.daysEn) {
      weekly[day] = all
          .where((e) =>
              e.group == group &&
              e.day == day &&
              e.isRelevantForSection(section))
          .toList()
        ..sort(_byStartTime);
    }

    return weekly;
  }

  @override
  Future<List<Map<String, dynamic>>> getCampusDirectory() =>
      _dataSource.loadCampusDirectory();

  @override
  Future<void> updateEntry(ScheduleEntry original, ScheduleEntry updated) async {
    final all = await _dataSource.loadSchedule();
    final index = all.indexWhere((e) =>
        e.group == original.group &&
        e.day == original.day &&
        e.startTime == original.startTime &&
        e.subjectId == original.subjectId);

    if (index >= 0) {
      all[index] = updated;
    } else {
      all.add(updated);
    }
    await _dataSource.saveSchedule(all);
  }

  @override
  Future<void> addEntry(ScheduleEntry newEntry) async {
    final all = await _dataSource.loadSchedule();
    all.add(newEntry);
    await _dataSource.saveSchedule(all);
  }

  @override
  Future<void> deleteEntry(ScheduleEntry entry) async {
    final all = await _dataSource.loadSchedule();
    all.removeWhere((e) =>
        e.group == entry.group &&
        e.day == entry.day &&
        e.startTime == entry.startTime &&
        e.subjectId == entry.subjectId);
    await _dataSource.saveSchedule(all);
  }

  @override
  Future<void> resetScheduleToDefault() => _dataSource.resetScheduleToDefault();

  @override
  Future<bool> hasCustomSchedule() => _dataSource.hasCustomEdits();

  /// Sort comparator by start time (earliest to latest), then by end time.
  int _byStartTime(ScheduleEntry a, ScheduleEntry b) {
    final (ah, am) = a.startTimeParts;
    final (bh, bm) = b.startTimeParts;
    final startDiff = (ah * 60 + am) - (bh * 60 + bm);
    if (startDiff != 0) return startDiff;

    final (eah, eam) = a.endTimeParts;
    final (ebh, ebm) = b.endTimeParts;
    final endDiff = (eah * 60 + eam) - (ebh * 60 + ebm);
    if (endDiff != 0) return endDiff;

    return a.type.compareTo(b.type);
  }
}
