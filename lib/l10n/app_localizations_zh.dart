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

  @override
  String get backgroundTitle => '工作区背景';

  @override
  String get backgroundDescription => '让工作区更有个性。选择一张能让你专注的图片。';

  @override
  String get backgroundPreview => '工作区预览';

  @override
  String get backgroundApplying => '正在准备背景…';

  @override
  String get backgroundChoose => '选择图片';

  @override
  String get backgroundChange => '更换图片';

  @override
  String get backgroundRemove => '移除背景';

  @override
  String get backgroundLoadError => '无法打开已保存的图片。请选择其他图片或移除背景。';

  @override
  String get backgroundFormats => 'PNG、JPEG 或 WebP · 最大 20 MB。横向图片效果最佳。';

  @override
  String get backgroundLocal => '保存在此设备上，不会修改原始图片。';

  @override
  String get backgroundInvalid =>
      '请选择有效的静态 PNG、JPEG 或 WebP 图片（最大 20 MB、4000 万像素）。';

  @override
  String get notesLabel => '笔记';

  @override
  String get newPage => '新建页面';

  @override
  String get untitledPage => '无标题';

  @override
  String get noNotes => '还没有笔记。创建页面开始写作。';

  @override
  String get searchPages => '搜索页面';

  @override
  String get searchPage => '在页面中查找';

  @override
  String get noteSaved => '已保存到本地';

  @override
  String get noteSaving => '正在保存…';

  @override
  String get noteSaveFailed => '更改未保存。离开前请重试。';

  @override
  String get noteHint => '开始输入，或输入 / 添加块';

  @override
  String get blockActions => '块操作';

  @override
  String get addBlock => '添加块';

  @override
  String get duplicateBlock => '复制';

  @override
  String get changeBlock => '更改块类型';

  @override
  String get blockDeleted => '块已删除';

  @override
  String get pageDeleted => '页面已删除';

  @override
  String get createNoteTask => '创建 Doever 任务';

  @override
  String get noteTaskCreated => '已在任务中创建';

  @override
  String get noteRedo => '重做';

  @override
  String get previousMatch => '上一个结果';

  @override
  String get nextMatch => '下一个结果';

  @override
  String get noteUrl => '网址（http 或 https）';

  @override
  String get noteInvalidUrl => '请输入有效的 http 或 https 地址。';

  @override
  String get noteOpenLink => '打开链接';

  @override
  String get noteImage => '选择图片';

  @override
  String get noteImageError => '图片不可用';

  @override
  String get noteToggleBody => '折叠内容';

  @override
  String get noteIcon => '提示图标（可选）';

  @override
  String get noteText => '文本';

  @override
  String get noteH1 => '一级标题';

  @override
  String get noteH2 => '二级标题';

  @override
  String get noteH3 => '三级标题';

  @override
  String get noteBullet => '无序列表';

  @override
  String get noteNumbered => '有序列表';

  @override
  String get noteTodo => '待办事项';

  @override
  String get noteQuote => '引用';

  @override
  String get noteDivider => '分隔线';

  @override
  String get noteCode => '代码';

  @override
  String get noteCallout => '提示';

  @override
  String get noteLink => '链接';

  @override
  String get noteToggle => '折叠块';

  @override
  String get noteChoosePage => '选择页面，或创建新页面。';

  @override
  String get themeStudio => '主题工作室';

  @override
  String get themeStudioSubtitle => '让 Doever 更具个性';

  @override
  String get themeLayers => '基础、表面与强调色';

  @override
  String get themeFoundation => '基础';

  @override
  String get themeSurface => '表面';

  @override
  String get themeAccent => '强调色';

  @override
  String get themeFoundationDescription => '工作区背景和整体氛围。';

  @override
  String get themeSurfaceDescription => '卡片、面板、输入框及浮层内容。';

  @override
  String get themeAccentDescription => '操作、焦点、选中状态及个性。';

  @override
  String get themeApply => '应用';

  @override
  String get themeUnsaved => '未保存的主题更改';

  @override
  String get themeLeavePrompt => '离开主题工作室前应用更改吗？';

  @override
  String get themeContinueEditing => '继续编辑';

  @override
  String get themeDiscard => '放弃更改';

  @override
  String get themeNameInvalid => '请为主题输入 1–200 个字符的名称。';

  @override
  String get themeApplied => '主题已应用';

  @override
  String get themeApplyFailed => '无法应用此主题。你的更改仍然保留。';

  @override
  String get themeUntitled => '未命名主题';

  @override
  String get themeRename => '重命名主题';

  @override
  String themeDeleteTitle(String name) {
    return '删除“$name”？';
  }

  @override
  String get themeDeleteMessage => '此已保存的主题将被永久删除。';

  @override
  String get themeFile => 'Doever 主题';

  @override
  String get themeFileTooLarge => '主题文件过大。请选择小于 64 KB 的文件。';

  @override
  String get themeFileInvalid => '此文件不是有效的 Doever 主题。';

  @override
  String get themeExportFailed => '无法导出此主题。';

  @override
  String get themeSaveFailed => '无法保存更改。请重试。';

  @override
  String get themeBack => '返回设置';

  @override
  String get themeRedo => '重做';

  @override
  String get themeThemes => '主题';

  @override
  String get themeLivePreview => '实时预览';

  @override
  String get themePreviewHint => '应用前在整个 Doever 中预览更改';

  @override
  String get themePreviewInApp => '在应用中预览';

  @override
  String get themeContrastGood => '对比度 · 良好';

  @override
  String get themeContrastProtected => '对比度 · 可读性已保护';

  @override
  String get themeName => '主题名称';

  @override
  String get themeReset => '重置主题';

  @override
  String get themeMode => '模式';

  @override
  String get themeAutoBalance => '自动平衡';

  @override
  String get themeAutoBalanceDescription => '保持层次清晰且易于阅读。';

  @override
  String get themeLowContrast => '所选颜色对比度较低';

  @override
  String get themeBalanceContrast => '自动平衡对比度';

  @override
  String get themeBalanced => '已自动平衡';

  @override
  String get themeFix => '自动修复';

  @override
  String get themeKeep => '仍然保留';

  @override
  String get themeGallery => '主题库';

  @override
  String get themeImport => '导入主题';

  @override
  String get themeExport => '导出主题';

  @override
  String get themeGalleryDescription => '从精选主题或已保存的主题开始。';

  @override
  String get themeBuiltIn => '内置';

  @override
  String get themeSaved => '已保存';

  @override
  String get themeNew => '新建主题';

  @override
  String get themeEmpty => '你保存的主题将显示在这里。';

  @override
  String get themeActive => '已应用';

  @override
  String themeActions(String name) {
    return '$name 的操作';
  }

  @override
  String get themeResetLayer => '重置图层';

  @override
  String get themeSolid => '纯色';

  @override
  String get themeGradient => '渐变';

  @override
  String get themeColors => '颜色';

  @override
  String get themeAddStop => '添加色标';

  @override
  String get themeRemoveStop => '移除色标';

  @override
  String themeColorStop(int number) {
    return '色标 $number';
  }

  @override
  String get themeDirection => '方向';

  @override
  String get themeTopBottom => '从上到下';

  @override
  String get themeBottomTop => '从下到上';

  @override
  String get themeLeftRight => '从左到右';

  @override
  String get themeRightLeft => '从右到左';

  @override
  String get themeTopLeftBottomRight => '从左上到右下';

  @override
  String get themeTopRightBottomLeft => '从右上到左下';

  @override
  String get themeBottomLeftTopRight => '从左下到右上';

  @override
  String get themeBottomRightTopLeft => '从右下到左上';

  @override
  String get themeAdvanced => '高级';

  @override
  String get themeAdvancedDescription => '色调、强度和渐变强度';

  @override
  String get themeTone => '色调';

  @override
  String get themeIntensity => '强度';

  @override
  String get themeGradientStrength => '渐变强度';

  @override
  String themePercent(String label, int value) {
    return '$label $value%';
  }

  @override
  String get themeHexInvalid => '请使用 #RRGGBB';

  @override
  String get themeSaturationBrightness => '饱和度和亮度';

  @override
  String get themeHue => '色相';

  @override
  String themeHueDegrees(int value) {
    return '色相 $value 度';
  }

  @override
  String get themeRecentColors => '最近使用的颜色';

  @override
  String get themePreviewSemantics => '主题预览：导航、任务、文本、输入框及操作';

  @override
  String get themePersonalSpace => '你的个人空间';

  @override
  String get themeRoom => '为重要的事留出空间。';

  @override
  String get themeSampleDone => '规划一天';

  @override
  String get themeSampleTask => '查看项目笔记';

  @override
  String get themeLocal => '所有更改均保存在本地';

  @override
  String get themeCreate => '创建';

  @override
  String get themeHierarchyBalanced => '已平衡基础与表面，使层次更清晰。';

  @override
  String get themeHierarchyLow => '基础与表面的层次区分较弱。';

  @override
  String get themeAccentAdjusted => '已调整强调色，确保前景文字清晰可读。';

  @override
  String get themeGradientMissing => '渐变至少需要两种颜色。';

  @override
  String get themeLightAdjusted => '已调整图层色调，确保浅色模式可读。';

  @override
  String get themeDarkAdjusted => '已调整图层色调，确保深色模式可读。';

  @override
  String themeCopyName(String name) {
    return '$name 副本';
  }

  @override
  String get themePresetMidnight => '午夜';

  @override
  String get themePresetGraphite => '石墨';

  @override
  String get themePresetOcean => '海洋';

  @override
  String get themePresetAurora => '极光';

  @override
  String get themePresetEmber => '余烬';

  @override
  String get themePresetForest => '森林';

  @override
  String get themePresetSand => '沙色';

  @override
  String get focusLabel => '专注';

  @override
  String get focusTagline => '为思绪留一片宁静。';

  @override
  String get focusLocal => '原创合成环境音，完全离线。';

  @override
  String get focusMixer => '你的混音';

  @override
  String get focusLibrary => '声音库';

  @override
  String get focusPresets => '适合此刻';

  @override
  String get focusCustom => '你的声景';

  @override
  String get focusNew => '新建声景';

  @override
  String get focusSave => '保存声景';

  @override
  String get focusCopy => '保存副本';

  @override
  String get focusDelete => '删除此声景？';

  @override
  String get focusPlay => '播放';

  @override
  String get focusPause => '暂停';

  @override
  String get focusStop => '停止';

  @override
  String get focusMute => '静音';

  @override
  String get focusUnmute => '取消静音';

  @override
  String get focusMaster => '总音量';

  @override
  String get focusDynamic => '动态氛围';

  @override
  String get focusDynamicHint => '缓慢而细微的音量变化。';

  @override
  String get focusAdd => '添加声音';

  @override
  String get focusRemove => '移除声音';

  @override
  String get focusLimit => '每个混音最多八种声音。';

  @override
  String get focusEmpty => '选择一个声景，或创建自己的声景。';

  @override
  String get focusAddHint => '从声音库添加声音以开始。';

  @override
  String get focusUnsaved => '已编辑混音 · 保存到声音库';

  @override
  String get focusAudioError => '无法启动或更新音频。请重试播放。';

  @override
  String get focusStorageError => '无法保存更改。关闭前请重试。';

  @override
  String get focusNoise => '噪声';

  @override
  String get focusWeather => '天气';

  @override
  String get focusNature => '自然';

  @override
  String get focusCozy => '温馨';

  @override
  String get focusUrban => '城市';

  @override
  String get focusWorkspace => '工作空间';

  @override
  String get focusWhite => '白噪声';

  @override
  String get focusPink => '粉红噪声';

  @override
  String get focusBrown => '棕噪声';

  @override
  String get focusGrey => '灰噪声';

  @override
  String get focusLightRain => '小雨';

  @override
  String get focusHeavyRain => '大雨';

  @override
  String get focusThunder => '滚雷';

  @override
  String get focusWind => '风';

  @override
  String get focusOcean => '海浪';

  @override
  String get focusStream => '溪流';

  @override
  String get focusBirds => '鸟鸣';

  @override
  String get focusCrickets => '夜间蟋蟀';

  @override
  String get focusFireplace => '壁炉';

  @override
  String get focusVinyl => '黑胶杂音';

  @override
  String get focusCafe => '咖啡馆氛围';

  @override
  String get focusTrain => '火车旅程';

  @override
  String get focusKeyboard => '轻柔键盘声';

  @override
  String get focusOffice => '安静办公室';

  @override
  String get focusDeepPreset => '深度专注';

  @override
  String get focusCafePreset => '雨中咖啡馆';

  @override
  String get focusNightPreset => '夜间编程';

  @override
  String get focusForestPreset => '林间学习';

  @override
  String get focusStormPreset => '暴风雨之夜';

  @override
  String get focusJourneyPreset => '宁静旅途';
}
