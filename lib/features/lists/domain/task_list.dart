final class TaskList {
  const TaskList({
    required this.id,
    required this.name,
    required this.color,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.icon = 'list',
    this.deletedAt,
    this.taskCount = 0,
  });
  final String id, name, icon;
  final int color, taskCount;
  final double sortOrder;
  final DateTime createdAt, updatedAt;
  final DateTime? deletedAt;
}
