import '../../lists/domain/task_list.dart';
import 'task.dart';

abstract interface class TaskRepository {
  Future<void> initialize();
  Stream<List<Task>> watchTasks(TaskQuery query);
  Stream<Task?> watchTask(String id);
  Future<Task?> getTask(String id);
  Future<String> createTask(
    String title, {
    String listId = inboxId,
    TaskPatch? patch,
  });
  Future<void> updateTask(String id, TaskPatch patch);
  Future<void> completeTask(String id, bool completed);
  Future<void> deleteTask(String id);
  Future<void> restoreTask(String id);
  Stream<List<TaskList>> watchLists();
  Future<String> createList(String name);
  Future<void> renameList(String id, String name);
  Future<void> deleteList(String id);
  Future<void> reorderList(String id, {String? beforeId, String? afterId});
  Stream<List<TaskStep>> watchSteps(String taskId);
  Future<void> addStep(String taskId, String title);
  Future<void> updateStep(String id, {String? title, bool? completed});
  Future<void> deleteStep(String id);
  Future<void> reorderStep(String id, {String? beforeId, String? afterId});
}
