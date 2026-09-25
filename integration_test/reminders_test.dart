import 'package:doever/core/notifications/local_reminders.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android adapter schedules, replaces and cancels an OS reminder',
    (tester) async {
      final reminders = LocalReminders();
      final plugin = FlutterLocalNotificationsPlugin();
      const id = 2147000000;
      try {
        await reminders.schedule(
          id: id,
          taskId: 'smoke',
          title: 'Doever test reminder',
          at: DateTime.now().toUtc().add(const Duration(hours: 1)),
        );
        expect(
          (await plugin.pendingNotificationRequests()).where((r) => r.id == id),
          hasLength(1),
        );
        await reminders.cancel(id);
        await reminders.schedule(
          id: id,
          taskId: 'smoke',
          title: 'Updated test reminder',
          at: DateTime.now().toUtc().add(const Duration(hours: 2)),
        );
        final pending = (await plugin.pendingNotificationRequests()).where(
          (r) => r.id == id,
        );
        expect(pending, hasLength(1));
        expect(pending.single.body, 'Updated test reminder');
        await reminders.cancel(id);
        expect(
          (await plugin.pendingNotificationRequests()).where((r) => r.id == id),
          isEmpty,
        );
      } finally {
        await reminders.cancel(id);
      }
    },
  );
}
