// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Doever';

  @override
  String get tagline => '做重要的事。';

  @override
  String get myDay => '我的一天';

  @override
  String get important => '重要';

  @override
  String get planned => '已计划';

  @override
  String get tasks => '任务';

  @override
  String get lists => '你的列表';

  @override
  String get newList => '新建列表';

  @override
  String get renameList => '重命名列表';

  @override
  String get deleteList => '删除列表';

  @override
  String get deleteListMessage => '此列表中的任务将移至“任务”。';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get delete => '删除';

  @override
  String get rename => '重命名';

  @override
  String get settings => '设置';

  @override
  String get search => '搜索任务';

  @override
  String get searchHint => '搜索标题和备注';

  @override
  String get addTask => '添加任务';

  @override
  String get taskTitle => '任务标题';

  @override
  String get addStep => '添加步骤';

  @override
  String get renameStep => '重命名步骤';

  @override
  String get notes => '备注';

  @override
  String get notesHint => '添加备注…';

  @override
  String get dueDate => '截止日期';

  @override
  String get reminder => '提醒';

  @override
  String get repeat => '重复';

  @override
  String get never => '从不';

  @override
  String get daily => '每天';

  @override
  String get weekdays => '工作日';

  @override
  String get weekly => '每周';

  @override
  String get monthly => '每月';

  @override
  String get yearly => '每年';

  @override
  String get moveTo => '移至列表';

  @override
  String get removeDate => '移除截止日期';

  @override
  String get removeReminder => '移除提醒';

  @override
  String get addToMyDay => '添加到“我的一天”';

  @override
  String get removeFromMyDay => '从“我的一天”移除';

  @override
  String get markImportant => '标记为重要';

  @override
  String get unmarkImportant => '取消重要标记';

  @override
  String get completeTask => '完成任务';

  @override
  String get uncompleteTask => '重新打开任务';

  @override
  String get completeStep => '完成步骤';

  @override
  String get uncompleteStep => '重新打开步骤';

  @override
  String get deleteStep => '删除步骤';

  @override
  String get deleteTask => '删除任务';

  @override
  String get taskDeleted => '任务已删除';

  @override
  String get undo => '撤销';

  @override
  String get closeDetails => '关闭详情';

  @override
  String get taskDetails => '任务详情';

  @override
  String get emptyDay => '今天没有计划。';

  @override
  String get emptyDayHint => '在下方添加任务，或从其他列表移入。';

  @override
  String get emptyImportant => '没有重要任务。';

  @override
  String get emptyImportantHint => '为任务加星标，方便随时查看。';

  @override
  String get emptyPlanned => '没有已计划的任务。';

  @override
  String get emptyPlannedHint => '设有截止日期的任务将显示在这里。';

  @override
  String get emptyTasks => '从这里开始吧。';

  @override
  String get emptyTasksHint => '在下方添加你的第一个任务。';

  @override
  String get emptySearch => '未找到任务。';

  @override
  String get emptySearchHint => '试试其他标题或备注中的词语。';

  @override
  String get theme => '外观';

  @override
  String get systemTheme => '跟随系统';

  @override
  String get lightTheme => '浅色';

  @override
  String get darkTheme => '深色';

  @override
  String get showCompleted => '显示已完成的任务';

  @override
  String get preferences => '偏好设置';

  @override
  String get privacyTitle => '本地存储，安心使用';

  @override
  String get privacyBody => '你的任务仅保存在此设备上。无需账户，没有分析、广告或跟踪。';

  @override
  String get validationError => '请检查输入后重试。标题不能为空，提醒时间必须在未来。';

  @override
  String get persistenceError => '无法保存更改。请检查可用存储空间后重试。';

  @override
  String get notificationError => '提醒不可用或通知权限已被拒绝。请检查系统通知设置。';

  @override
  String get unexpectedError => '出了点问题。请重试。';

  @override
  String get loadError => '无法加载任务。请重试。';

  @override
  String get retry => '重试';

  @override
  String get reminderPending => '提醒更改未能生效。Doever 将自动重试。';

  @override
  String get remindersUnsupported => '此平台不支持定时提醒。';

  @override
  String get moveUp => '上移';

  @override
  String get moveDown => '下移';

  @override
  String get reorder => '重新排序';

  @override
  String get openNavigation => '打开导航菜单';

  @override
  String get quickAddHint => '新建任务：Ctrl/Cmd+N';

  @override
  String get searchShortcutHint => '搜索：Ctrl/Cmd+F';

  @override
  String get completed => '已完成';

  @override
  String get taskUnavailable => '此任务已不可用。';

  @override
  String get startupError => 'Doever 无法打开本地存储。请检查可用空间后重试。';

  @override
  String get saving => '正在保存…';

  @override
  String get saved => '已保存在此设备上';

  @override
  String get reminderTiming => 'Android 可能为节省电量而延迟提醒。';

  @override
  String get recurrenceHint => '完成当前任务后会创建下一次任务。每次任务的提醒需单独设置。';

  @override
  String get steps => '步骤';

  @override
  String get back => '返回';

  @override
  String get clearSearch => '清除搜索';

  @override
  String get today => '今天';

  @override
  String get allLocal => '存储在此设备上';

  @override
  String taskCount(int count) {
    return '$count 个任务';
  }

  @override
  String dueOn(String date) {
    return '截止日期：$date';
  }

  @override
  String remindOn(String date) {
    return '提醒时间：$date';
  }

  @override
  String get titleRequired => '请输入任务标题。';

  @override
  String get language => '语言';
}
