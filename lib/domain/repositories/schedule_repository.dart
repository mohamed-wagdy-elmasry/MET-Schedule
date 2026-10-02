/// Repository contract — domain layer knows nothing about data sources.
library;

import '../entities/schedule_entry.dart';

abstract class ScheduleRepository {
  /// Returns every entry for both groups.
  Future<List<ScheduleEntry>> getAllEntries();

  /// Returns entries for a specific [group] on a specific [day].
  Future<List<ScheduleEntry>> getEntriesForDay(String group, String day);

  /// Returns entries relevant to a specific [group], [day], and [section].
  Future<List<ScheduleEntry>> getFilteredEntries(String group, String day, int section);

  /// Returns the full week filtered for [group] and [section].
  Future<Map<String, List<ScheduleEntry>>> getWeeklySchedule(String group, int section);

  /// Returns campus directory data.
  Future<List<Map<String, dynamic>>> getCampusDirectory();

  /// Updates an existing entry in the schedule.
  Future<void> updateEntry(ScheduleEntry original, ScheduleEntry updated);

  /// Adds a new schedule entry.
  Future<void> addEntry(ScheduleEntry newEntry);

  /// Deletes a schedule entry.
  Future<void> deleteEntry(ScheduleEntry entry);

  /// Resets the schedule to the default official timetable.
  Future<void> resetScheduleToDefault();

  /// Returns true if the user has custom schedule modifications.
  Future<bool> hasCustomSchedule();
}
