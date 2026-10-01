import 'package:doever/core/notifications/reminder_service.dart';

class FakeReminders implements ReminderService {
  final scheduled = <int, DateTime>{};
  final cancelled = <int>[];
  bool allow = true, fail = false;
  int permissionRequests = 0;
  @override
  Future<void> showFocusCompletion({
    required String title,
    required String body,
  }) async {
    if (fail) throw StateError('OS failed');
  }

  @override
  bool get supported => true;
  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return allow;
  }

  @override
  Future<void> cancel(int id) async {
    if (fail) throw StateError('OS failed');
    cancelled.add(id);
    scheduled.remove(id);
  }

  @override
  Future<void> schedule({
    required int id,
    required String taskId,
    required String title,
    required DateTime at,
  }) async {
    if (fail) throw StateError('OS failed');
    scheduled[id] = at;
  }
}
