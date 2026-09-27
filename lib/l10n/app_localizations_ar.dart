// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Doever';

  @override
  String get tagline => 'أنجز ما يهمك.';

  @override
  String get myDay => 'يومي';

  @override
  String get important => 'مهم';

  @override
  String get planned => 'مخطط له';

  @override
  String get tasks => 'المهام';

  @override
  String get lists => 'قوائمك';

  @override
  String get newList => 'قائمة جديدة';

  @override
  String get renameList => 'إعادة تسمية القائمة';

  @override
  String get deleteList => 'حذف القائمة';

  @override
  String get deleteListMessage =>
      'ستنقل المهام الموجودة في هذه القائمة إلى المهام.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get delete => 'حذف';

  @override
  String get rename => 'إعادة التسمية';

  @override
  String get settings => 'الإعدادات';

  @override
  String get search => 'البحث عن المهام';

  @override
  String get searchHint => 'ابحث في العناوين والملاحظات';

  @override
  String get addTask => 'إضافة مهمة';

  @override
  String get taskTitle => 'عنوان المهمة';

  @override
  String get addStep => 'إضافة خطوة';

  @override
  String get renameStep => 'إعادة تسمية الخطوة';

  @override
  String get notes => 'ملاحظات';

  @override
  String get notesHint => 'أضف ملاحظة…';

  @override
  String get dueDate => 'تاريخ الاستحقاق';

  @override
  String get reminder => 'تذكير';

  @override
  String get repeat => 'تكرار';

  @override
  String get never => 'أبدًا';

  @override
  String get daily => 'يوميًا';

  @override
  String get weekdays => 'أيام العمل';

  @override
  String get weekly => 'أسبوعيًا';

  @override
  String get monthly => 'شهريًا';

  @override
  String get yearly => 'سنويًا';

  @override
  String get moveTo => 'نقل إلى قائمة';

  @override
  String get removeDate => 'إزالة تاريخ الاستحقاق';

  @override
  String get removeReminder => 'إزالة التذكير';

  @override
  String get addToMyDay => 'إضافة إلى يومي';

  @override
  String get removeFromMyDay => 'إزالة من يومي';

  @override
  String get markImportant => 'وضع علامة مهم';

  @override
  String get unmarkImportant => 'إزالة علامة مهم';

  @override
  String get completeTask => 'إكمال المهمة';

  @override
  String get uncompleteTask => 'إعادة فتح المهمة';

  @override
  String get completeStep => 'إكمال الخطوة';

  @override
  String get uncompleteStep => 'إعادة فتح الخطوة';

  @override
  String get deleteStep => 'حذف الخطوة';

  @override
  String get deleteTask => 'حذف المهمة';

  @override
  String get taskDeleted => 'تم حذف المهمة';

  @override
  String get undo => 'تراجع';

  @override
  String get closeDetails => 'إغلاق التفاصيل';

  @override
  String get taskDetails => 'تفاصيل المهمة';

  @override
  String get emptyDay => 'لا شيء مخطط له اليوم.';

  @override
  String get emptyDayHint => 'أضف مهمة أدناه أو انقلها من قائمة أخرى.';

  @override
  String get emptyImportant => 'لا توجد مهام مهمة.';

  @override
  String get emptyImportantHint => 'ضع نجمة على المهمة لتبقى قريبة منك.';

  @override
  String get emptyPlanned => 'لا توجد مهام مخطط لها.';

  @override
  String get emptyPlannedHint => 'ستظهر هنا المهام التي لها تاريخ استحقاق.';

  @override
  String get emptyTasks => 'مساحة لتبدأ منها.';

  @override
  String get emptyTasksHint => 'أضف مهمتك الأولى أدناه.';

  @override
  String get emptySearch => 'لم يتم العثور على مهام.';

  @override
  String get emptySearchHint => 'جرّب عنوانًا آخر أو كلمة من ملاحظاتك.';

  @override
  String get theme => 'المظهر';

  @override
  String get systemTheme => 'النظام';

  @override
  String get lightTheme => 'فاتح';

  @override
  String get darkTheme => 'داكن';

  @override
  String get showCompleted => 'إظهار المهام المكتملة';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get privacyTitle => 'محلي بطبيعته';

  @override
  String get privacyBody =>
      'تبقى مهامك على هذا الجهاز. بلا حساب أو تحليلات أو إعلانات أو تتبع.';

  @override
  String get validationError =>
      'تحقق من البيانات وحاول مجددًا. لا يمكن ترك العناوين فارغة ويجب أن تكون التذكيرات في المستقبل.';

  @override
  String get persistenceError =>
      'تعذر حفظ التغييرات. تحقق من المساحة المتاحة وحاول مجددًا.';

  @override
  String get notificationError =>
      'التذكيرات غير متاحة أو تم رفض إذن الإشعارات. تحقق من إعدادات الإشعارات في النظام.';

  @override
  String get unexpectedError => 'حدث خطأ ما. حاول مجددًا.';

  @override
  String get loadError => 'تعذر تحميل مهامك. حاول مجددًا.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get reminderPending =>
      'تعذر تطبيق تغيير في التذكير. سيحاول Doever مجددًا تلقائيًا.';

  @override
  String get remindersUnsupported =>
      'التذكيرات المجدولة غير مدعومة على هذا النظام.';

  @override
  String get moveUp => 'تحريك لأعلى';

  @override
  String get moveDown => 'تحريك لأسفل';

  @override
  String get reorder => 'إعادة الترتيب';

  @override
  String get openNavigation => 'فتح التنقل';

  @override
  String get quickAddHint => 'مهمة جديدة: Ctrl/Cmd+N';

  @override
  String get searchShortcutHint => 'بحث: Ctrl/Cmd+F';

  @override
  String get completed => 'مكتملة';

  @override
  String get taskUnavailable => 'هذه المهمة لم تعد متاحة.';

  @override
  String get startupError =>
      'تعذر على Doever فتح التخزين المحلي. تحقق من المساحة المتاحة وحاول مجددًا.';

  @override
  String get saving => 'جارٍ الحفظ…';

  @override
  String get saved => 'تم الحفظ على هذا الجهاز';

  @override
  String get reminderTiming => 'قد يؤخر Android التذكيرات لتوفير البطارية.';

  @override
  String get recurrenceHint =>
      'تُنشأ المهمة التالية عند إكمال هذه المهمة. تضبط التذكيرات لكل مرة على حدة.';

  @override
  String get steps => 'الخطوات';

  @override
  String get back => 'رجوع';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get today => 'اليوم';

  @override
  String get allLocal => 'محفوظ على هذا الجهاز';

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة',
      many: '$count مهمة',
      few: '$count مهام',
      two: 'مهمتان',
      one: 'مهمة واحدة',
      zero: 'لا مهام',
    );
    return '$_temp0';
  }

  @override
  String dueOn(String date) {
    return 'تاريخ الاستحقاق: $date';
  }

  @override
  String remindOn(String date) {
    return 'ذكرني في $date';
  }

  @override
  String get titleRequired => 'أدخل عنوان المهمة.';

  @override
  String get language => 'اللغة';

  @override
  String get backgroundTitle => 'خلفية مساحة العمل';

  @override
  String get backgroundDescription =>
      'اجعل هذه المساحة خاصة بك. اختر صورة تساعدك على التركيز.';

  @override
  String get backgroundPreview => 'معاينة مساحة العمل';

  @override
  String get backgroundApplying => 'جارٍ إعداد الخلفية…';

  @override
  String get backgroundChoose => 'اختيار صورة';

  @override
  String get backgroundChange => 'تغيير الصورة';

  @override
  String get backgroundRemove => 'إزالة الخلفية';

  @override
  String get backgroundLoadError =>
      'تعذر فتح الصورة المحفوظة. اختر صورة أخرى أو أزل الخلفية.';

  @override
  String get backgroundFormats =>
      'PNG أو JPEG أو WebP · حتى 20 ميغابايت. الصور الأفقية هي الأنسب.';

  @override
  String get backgroundLocal =>
      'محفوظة على هذا الجهاز. تبقى صورتك الأصلية دون تغيير.';

  @override
  String get backgroundInvalid =>
      'اختر صورة ثابتة وصالحة بصيغة PNG أو JPEG أو WebP (حتى 20 ميغابايت و40 ميغابكسل).';

  @override
  String get notesLabel => 'الملاحظات';

  @override
  String get newPage => 'صفحة جديدة';

  @override
  String get untitledPage => 'بدون عنوان';

  @override
  String get noNotes => 'لا توجد ملاحظات بعد. أنشئ صفحة لبدء الكتابة.';

  @override
  String get searchPages => 'البحث في الصفحات';

  @override
  String get searchPage => 'البحث في الصفحة';

  @override
  String get noteSaved => 'تم الحفظ محليًا';

  @override
  String get noteSaving => 'جارٍ الحفظ…';

  @override
  String get noteSaveFailed => 'لم تُحفظ التغييرات. أعد المحاولة قبل المغادرة.';

  @override
  String get noteHint => 'اكتب شيئًا أو اكتب / لإضافة كتل';

  @override
  String get blockActions => 'إجراءات الكتلة';

  @override
  String get addBlock => 'إضافة كتلة';

  @override
  String get duplicateBlock => 'تكرار';

  @override
  String get changeBlock => 'تغيير نوع الكتلة';

  @override
  String get blockDeleted => 'تم حذف الكتلة';

  @override
  String get pageDeleted => 'تم حذف الصفحة';

  @override
  String get createNoteTask => 'إنشاء مهمة Doever';

  @override
  String get noteTaskCreated => 'تم إنشاء المهمة في المهام';

  @override
  String get noteRedo => 'إعادة';

  @override
  String get previousMatch => 'النتيجة السابقة';

  @override
  String get nextMatch => 'النتيجة التالية';

  @override
  String get noteUrl => 'عنوان الويب (http أو https)';

  @override
  String get noteInvalidUrl => 'أدخل عنوان http أو https صالحًا.';

  @override
  String get noteOpenLink => 'فتح الرابط';

  @override
  String get noteImage => 'اختيار صورة';

  @override
  String get noteImageError => 'الصورة غير متاحة';

  @override
  String get noteToggleBody => 'محتوى قابل للطي';

  @override
  String get noteIcon => 'رمز التنبيه (اختياري)';

  @override
  String get noteText => 'نص';

  @override
  String get noteH1 => 'عنوان 1';

  @override
  String get noteH2 => 'عنوان 2';

  @override
  String get noteH3 => 'عنوان 3';

  @override
  String get noteBullet => 'قائمة نقطية';

  @override
  String get noteNumbered => 'قائمة مرقمة';

  @override
  String get noteTodo => 'مهمة';

  @override
  String get noteQuote => 'اقتباس';

  @override
  String get noteDivider => 'فاصل';

  @override
  String get noteCode => 'شفرة';

  @override
  String get noteCallout => 'تنبيه';

  @override
  String get noteLink => 'رابط';

  @override
  String get noteToggle => 'كتلة قابلة للطي';

  @override
  String get noteChoosePage => 'اختر صفحة أو أنشئ صفحة جديدة.';

  @override
  String get themeStudio => 'استوديو السمات';

  @override
  String get themeStudioSubtitle => 'اجعل Doever يعكس أسلوبك';

  @override
  String get themeLayers => 'الخلفية والأسطح ولون التمييز';

  @override
  String get themeFoundation => 'الخلفية';

  @override
  String get themeSurface => 'الأسطح';

  @override
  String get themeAccent => 'لون التمييز';

  @override
  String get themeFoundationDescription => 'خلفية مساحة العمل وطابعها العام.';

  @override
  String get themeSurfaceDescription =>
      'البطاقات واللوحات وحقول الإدخال والمحتوى المرتفع.';

  @override
  String get themeAccentDescription =>
      'الإجراءات والتركيز والتحديد والطابع الشخصي.';

  @override
  String get themeApply => 'تطبيق';

  @override
  String get themeUnsaved => 'تغييرات غير محفوظة في السمة';

  @override
  String get themeLeavePrompt =>
      'هل تريد تطبيق التغييرات قبل مغادرة استوديو السمات؟';

  @override
  String get themeContinueEditing => 'متابعة التعديل';

  @override
  String get themeDiscard => 'تجاهل';

  @override
  String get themeNameInvalid => 'أدخل اسمًا للسمة يتكون من 1 إلى 200 حرف.';

  @override
  String get themeApplied => 'تم تطبيق السمة';

  @override
  String get themeApplyFailed =>
      'تعذر تطبيق السمة. ما زالت تغييراتك محفوظة هنا.';

  @override
  String get themeUntitled => 'سمة بلا عنوان';

  @override
  String get themeRename => 'إعادة تسمية السمة';

  @override
  String themeDeleteTitle(String name) {
    return 'هل تريد حذف «$name»؟';
  }

  @override
  String get themeDeleteMessage => 'ستُحذف هذه السمة المحفوظة نهائيًا.';

  @override
  String get themeFile => 'سمة Doever';

  @override
  String get themeFileTooLarge =>
      'ملف السمة كبير جدًا. اختر ملفًا أصغر من 64 كيلوبايت.';

  @override
  String get themeFileInvalid => 'هذا الملف ليس سمة Doever صالحة.';

  @override
  String get themeExportFailed => 'تعذر تصدير السمة.';

  @override
  String get themeSaveFailed => 'تعذر حفظ التغيير. حاول مرة أخرى.';

  @override
  String get themeBack => 'العودة إلى الإعدادات';

  @override
  String get themeRedo => 'إعادة';

  @override
  String get themeThemes => 'السمات';

  @override
  String get themeLivePreview => 'معاينة مباشرة';

  @override
  String get themePreviewHint => 'عاين التغييرات في Doever قبل تطبيقها';

  @override
  String get themePreviewInApp => 'معاينة في التطبيق';

  @override
  String get themeContrastGood => 'التباين · جيد';

  @override
  String get themeContrastProtected => 'التباين · وضوح القراءة محمي';

  @override
  String get themeName => 'اسم السمة';

  @override
  String get themeReset => 'إعادة ضبط السمة';

  @override
  String get themeMode => 'الوضع';

  @override
  String get themeAutoBalance => 'توازن تلقائي';

  @override
  String get themeAutoBalanceDescription =>
      'أبقِ الطبقات مميزة ومريحة للقراءة.';

  @override
  String get themeLowContrast => 'تباين منخفض في الألوان المختارة';

  @override
  String get themeBalanceContrast => 'موازنة التباين تلقائيًا';

  @override
  String get themeBalanced => 'تمت الموازنة تلقائيًا';

  @override
  String get themeFix => 'إصلاح تلقائي';

  @override
  String get themeKeep => 'الاحتفاظ على أي حال';

  @override
  String get themeGallery => 'معرض السمات';

  @override
  String get themeImport => 'استيراد سمة';

  @override
  String get themeExport => 'تصدير سمة';

  @override
  String get themeGalleryDescription => 'ابدأ بمظهر جاهز أو بسمة حفظتها.';

  @override
  String get themeBuiltIn => 'مدمجة';

  @override
  String get themeSaved => 'محفوظة';

  @override
  String get themeNew => 'سمة جديدة';

  @override
  String get themeEmpty => 'ستظهر سماتك المحفوظة هنا.';

  @override
  String get themeActive => 'مطبقة';

  @override
  String themeActions(String name) {
    return 'إجراءات $name';
  }

  @override
  String get themeResetLayer => 'إعادة ضبط الطبقة';

  @override
  String get themeSolid => 'لون موحد';

  @override
  String get themeGradient => 'تدرج';

  @override
  String get themeColors => 'الألوان';

  @override
  String get themeAddStop => 'إضافة نقطة لون';

  @override
  String get themeRemoveStop => 'إزالة نقطة لون';

  @override
  String themeColorStop(int number) {
    return 'نقطة اللون $number';
  }

  @override
  String get themeDirection => 'الاتجاه';

  @override
  String get themeTopBottom => 'من الأعلى إلى الأسفل';

  @override
  String get themeBottomTop => 'من الأسفل إلى الأعلى';

  @override
  String get themeLeftRight => 'من اليسار إلى اليمين';

  @override
  String get themeRightLeft => 'من اليمين إلى اليسار';

  @override
  String get themeTopLeftBottomRight => 'من أعلى اليسار إلى أسفل اليمين';

  @override
  String get themeTopRightBottomLeft => 'من أعلى اليمين إلى أسفل اليسار';

  @override
  String get themeBottomLeftTopRight => 'من أسفل اليسار إلى أعلى اليمين';

  @override
  String get themeBottomRightTopLeft => 'من أسفل اليمين إلى أعلى اليسار';

  @override
  String get themeAdvanced => 'متقدم';

  @override
  String get themeAdvancedDescription => 'درجة اللون وكثافته وقوة التدرج';

  @override
  String get themeTone => 'درجة اللون';

  @override
  String get themeIntensity => 'الكثافة';

  @override
  String get themeGradientStrength => 'قوة التدرج';

  @override
  String themePercent(String label, int value) {
    return '$label $value بالمئة';
  }

  @override
  String get themeHexInvalid => 'استخدم #RRGGBB';

  @override
  String get themeSaturationBrightness => 'التشبع والسطوع';

  @override
  String get themeHue => 'تدرج اللون';

  @override
  String themeHueDegrees(int value) {
    return 'تدرج اللون $value درجة';
  }

  @override
  String get themeRecentColors => 'الألوان الأخيرة';

  @override
  String get themePreviewSemantics =>
      'معاينة السمة: التنقل والمهام والنص والإدخال والإجراء';

  @override
  String get themePersonalSpace => 'مساحتك الشخصية';

  @override
  String get themeRoom => 'مساحة لما يهم.';

  @override
  String get themeSampleDone => 'خطط ليومك';

  @override
  String get themeSampleTask => 'راجع ملاحظات المشروع';

  @override
  String get themeLocal => 'تبقى جميع التغييرات محلية';

  @override
  String get themeCreate => 'إنشاء';

  @override
  String get themeHierarchyBalanced =>
      'تمت موازنة الخلفية والأسطح لإظهار الطبقات بوضوح.';

  @override
  String get themeHierarchyLow => 'التمييز البصري بين الخلفية والأسطح منخفض.';

  @override
  String get themeAccentAdjusted => 'عُدّل لون التمييز للحفاظ على وضوح النص.';

  @override
  String get themeGradientMissing => 'يحتاج التدرج إلى لونين على الأقل.';

  @override
  String get themeLightAdjusted =>
      'عُدلت درجات الطبقات لضمان القراءة في الوضع الفاتح.';

  @override
  String get themeDarkAdjusted =>
      'عُدلت درجات الطبقات لضمان القراءة في الوضع الداكن.';

  @override
  String themeCopyName(String name) {
    return 'نسخة من $name';
  }

  @override
  String get themePresetMidnight => 'منتصف الليل';

  @override
  String get themePresetGraphite => 'الجرافيت';

  @override
  String get themePresetOcean => 'المحيط';

  @override
  String get themePresetAurora => 'الشفق';

  @override
  String get themePresetEmber => 'الجمر';

  @override
  String get themePresetForest => 'الغابة';

  @override
  String get themePresetSand => 'الرمال';
}
