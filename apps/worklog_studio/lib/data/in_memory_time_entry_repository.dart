// import 'package:worklog_studio/domain/time_entry.dart';
// import 'package:worklog_studio/domain/time_tracker.dart';

// class InMemoryTimeEntryRepository implements TimeEntryRepository {
//   TimeEntry? _active;
//   final List<TimeEntry> _entries = [];

//   @override
//   TimeEntry? getActive() {
//     return _active;
//   }

//   @override
//   void insert(TimeEntry entry) {
//     if (entry.status == TimeEntryStatus.running) {
//       if (_active != null) {
//         throw StateError('Only one running TimeEntry is allowed');
//       }
//       _active = entry;
//     }
//     _entries.add(entry);
//   }

//   @override
//   void update(TimeEntry entry) {
//     final index = _entries.indexWhere((e) => e.id == entry.id);
//     if (index == -1) {
//       throw StateError('TimeEntry not found');
//     }

//     _entries[index] = entry;

//     if (entry.status == TimeEntryStatus.running) {
//       _active = entry;
//     } else if (_active?.id == entry.id) {
//       _active = null;
//     }
//   }

//   // ---------
//   // Helpers (not part of domain contract, but useful later)
//   // ---------

//   List<TimeEntry> getAll() {
//     return List.unmodifiable(_entries);
//   }
// }
