abstract interface class ReminderService {
  bool get supported;
  Future<bool> requestPermission();
  Future<void> schedule({
    required int id,
    required String taskId,
    required String title,
    required DateTime at,
  });
  Future<void> cancel(int id);
}
