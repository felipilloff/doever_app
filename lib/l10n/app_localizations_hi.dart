// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Doever';

  @override
  String get tagline => 'जो ज़रूरी है, वह करें।';

  @override
  String get myDay => 'मेरा दिन';

  @override
  String get important => 'महत्वपूर्ण';

  @override
  String get planned => 'नियोजित';

  @override
  String get tasks => 'कार्य';

  @override
  String get lists => 'आपकी सूचियाँ';

  @override
  String get newList => 'नई सूची';

  @override
  String get renameList => 'सूची का नाम बदलें';

  @override
  String get deleteList => 'सूची हटाएँ';

  @override
  String get deleteListMessage => 'इस सूची के कार्य कार्य सूची में चले जाएँगे।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get delete => 'हटाएँ';

  @override
  String get rename => 'नाम बदलें';

  @override
  String get settings => 'सेटिंग';

  @override
  String get search => 'कार्य खोजें';

  @override
  String get searchHint => 'शीर्षक और नोट में खोजें';

  @override
  String get addTask => 'कार्य जोड़ें';

  @override
  String get taskTitle => 'कार्य का शीर्षक';

  @override
  String get addStep => 'चरण जोड़ें';

  @override
  String get renameStep => 'चरण का नाम बदलें';

  @override
  String get notes => 'नोट्स';

  @override
  String get notesHint => 'नोट जोड़ें…';

  @override
  String get dueDate => 'नियत तारीख';

  @override
  String get reminder => 'रिमाइंडर';

  @override
  String get repeat => 'दोहराएँ';

  @override
  String get never => 'कभी नहीं';

  @override
  String get daily => 'हर दिन';

  @override
  String get weekdays => 'कार्यदिवस';

  @override
  String get weekly => 'हर सप्ताह';

  @override
  String get monthly => 'हर महीने';

  @override
  String get yearly => 'हर साल';

  @override
  String get moveTo => 'सूची में ले जाएँ';

  @override
  String get removeDate => 'नियत तारीख हटाएँ';

  @override
  String get removeReminder => 'रिमाइंडर हटाएँ';

  @override
  String get addToMyDay => 'मेरे दिन में जोड़ें';

  @override
  String get removeFromMyDay => 'मेरे दिन से हटाएँ';

  @override
  String get markImportant => 'महत्वपूर्ण चिह्नित करें';

  @override
  String get unmarkImportant => 'महत्वपूर्ण चिह्न हटाएँ';

  @override
  String get completeTask => 'कार्य पूरा करें';

  @override
  String get uncompleteTask => 'कार्य फिर खोलें';

  @override
  String get completeStep => 'चरण पूरा करें';

  @override
  String get uncompleteStep => 'चरण फिर खोलें';

  @override
  String get deleteStep => 'चरण हटाएँ';

  @override
  String get deleteTask => 'कार्य हटाएँ';

  @override
  String get taskDeleted => 'कार्य हटा दिया गया';

  @override
  String get undo => 'पूर्ववत करें';

  @override
  String get closeDetails => 'विवरण बंद करें';

  @override
  String get taskDetails => 'कार्य विवरण';

  @override
  String get emptyDay => 'आज के लिए कुछ तय नहीं है।';

  @override
  String get emptyDayHint => 'नीचे कार्य जोड़ें या दूसरी सूची से यहाँ लाएँ।';

  @override
  String get emptyImportant => 'कोई महत्वपूर्ण कार्य नहीं है।';

  @override
  String get emptyImportantHint =>
      'कार्य को स्टार लगाएँ ताकि वह आसानी से मिले।';

  @override
  String get emptyPlanned => 'कोई नियोजित कार्य नहीं है।';

  @override
  String get emptyPlannedHint => 'नियत तारीख वाले कार्य यहाँ दिखेंगे।';

  @override
  String get emptyTasks => 'शुरू करने के लिए जगह है।';

  @override
  String get emptyTasksHint => 'नीचे अपना पहला कार्य जोड़ें।';

  @override
  String get emptySearch => 'कोई कार्य नहीं मिला।';

  @override
  String get emptySearchHint => 'दूसरा शीर्षक या नोट का कोई शब्द आज़माएँ।';

  @override
  String get theme => 'दिखावट';

  @override
  String get systemTheme => 'सिस्टम';

  @override
  String get lightTheme => 'लाइट';

  @override
  String get darkTheme => 'डार्क';

  @override
  String get showCompleted => 'पूरे किए गए कार्य दिखाएँ';

  @override
  String get preferences => 'प्राथमिकताएँ';

  @override
  String get privacyTitle => 'स्थानीय रूप से सुरक्षित';

  @override
  String get privacyBody =>
      'आपके कार्य इसी डिवाइस पर रहते हैं। न खाता, न विश्लेषण, न विज्ञापन और न ट्रैकिंग।';

  @override
  String get validationError =>
      'जानकारी जाँचकर फिर कोशिश करें। शीर्षक खाली नहीं हो सकते और रिमाइंडर भविष्य के लिए होने चाहिए।';

  @override
  String get persistenceError =>
      'बदलाव सहेजे नहीं जा सके। उपलब्ध स्टोरेज जाँचकर फिर कोशिश करें।';

  @override
  String get notificationError =>
      'रिमाइंडर उपलब्ध नहीं हैं या नोटिफिकेशन की अनुमति नहीं मिली। सिस्टम की नोटिफिकेशन सेटिंग जाँचें।';

  @override
  String get unexpectedError => 'कुछ गलत हुआ। कृपया फिर कोशिश करें।';

  @override
  String get loadError => 'आपके कार्य लोड नहीं हो सके। कृपया फिर कोशिश करें।';

  @override
  String get retry => 'फिर कोशिश करें';

  @override
  String get reminderPending =>
      'रिमाइंडर में बदलाव लागू नहीं हो सका। Doever अपने आप फिर कोशिश करेगा।';

  @override
  String get remindersUnsupported =>
      'इस प्लेटफ़ॉर्म पर शेड्यूल किए गए रिमाइंडर उपलब्ध नहीं हैं।';

  @override
  String get moveUp => 'ऊपर ले जाएँ';

  @override
  String get moveDown => 'नीचे ले जाएँ';

  @override
  String get reorder => 'क्रम बदलें';

  @override
  String get openNavigation => 'नेविगेशन खोलें';

  @override
  String get quickAddHint => 'नया कार्य: Ctrl/Cmd+N';

  @override
  String get searchShortcutHint => 'खोजें: Ctrl/Cmd+F';

  @override
  String get completed => 'पूरा हुआ';

  @override
  String get taskUnavailable => 'यह कार्य अब उपलब्ध नहीं है।';

  @override
  String get startupError =>
      'Doever स्थानीय स्टोरेज नहीं खोल सका। उपलब्ध जगह जाँचकर फिर कोशिश करें।';

  @override
  String get saving => 'सहेजा जा रहा है…';

  @override
  String get saved => 'इस डिवाइस पर सहेजा गया';

  @override
  String get reminderTiming =>
      'बैटरी बचाने के लिए Android रिमाइंडर में देरी कर सकता है।';

  @override
  String get recurrenceHint =>
      'इसे पूरा करने पर अगला कार्य बनाया जाता है। हर बार के लिए रिमाइंडर अलग से सेट करें।';

  @override
  String get steps => 'चरण';

  @override
  String get back => 'वापस';

  @override
  String get clearSearch => 'खोज साफ़ करें';

  @override
  String get today => 'आज';

  @override
  String get allLocal => 'इस डिवाइस पर संग्रहित';

  @override
  String taskCount(int count) {
    return '$count कार्य';
  }

  @override
  String dueOn(String date) {
    return 'नियत तारीख: $date';
  }

  @override
  String remindOn(String date) {
    return 'याद दिलाएँ: $date';
  }

  @override
  String get titleRequired => 'कार्य का शीर्षक लिखें।';

  @override
  String get language => 'भाषा';
}
