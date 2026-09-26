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

  @override
  String get backgroundTitle => 'कार्यस्थान की पृष्ठभूमि';

  @override
  String get backgroundDescription =>
      'इस जगह को अपना बनाएँ। ऐसी तस्वीर चुनें जो ध्यान लगाने में मदद करे।';

  @override
  String get backgroundPreview => 'आपके कार्यस्थान का पूर्वावलोकन';

  @override
  String get backgroundApplying => 'पृष्ठभूमि तैयार की जा रही है…';

  @override
  String get backgroundChoose => 'तस्वीर चुनें';

  @override
  String get backgroundChange => 'तस्वीर बदलें';

  @override
  String get backgroundRemove => 'पृष्ठभूमि हटाएँ';

  @override
  String get backgroundLoadError =>
      'सहेजी गई तस्वीर नहीं खुल सकी। दूसरी तस्वीर चुनें या पृष्ठभूमि हटाएँ।';

  @override
  String get backgroundFormats =>
      'PNG, JPEG या WebP · अधिकतम 20 MB। क्षैतिज तस्वीरें सबसे अच्छी लगती हैं।';

  @override
  String get backgroundLocal =>
      'इस डिवाइस पर सहेजा गया। आपकी मूल तस्वीर नहीं बदलती।';

  @override
  String get backgroundInvalid =>
      'मान्य स्थिर PNG, JPEG या WebP तस्वीर चुनें (अधिकतम 20 MB और 40 मेगापिक्सेल)।';

  @override
  String get notesLabel => 'नोट्स';

  @override
  String get newPage => 'नया पृष्ठ';

  @override
  String get untitledPage => 'बिना शीर्षक';

  @override
  String get noNotes => 'अभी कोई नोट नहीं। लिखने के लिए पृष्ठ बनाएँ।';

  @override
  String get searchPages => 'पृष्ठ खोजें';

  @override
  String get searchPage => 'पृष्ठ में खोजें';

  @override
  String get noteSaved => 'स्थानीय रूप से सहेजा गया';

  @override
  String get noteSaving => 'सहेजा जा रहा है…';

  @override
  String get noteSaveFailed =>
      'बदलाव सहेजे नहीं गए। जाने से पहले पुनः प्रयास करें।';

  @override
  String get noteHint => 'लिखें या ब्लॉक के लिए / टाइप करें';

  @override
  String get blockActions => 'ब्लॉक विकल्प';

  @override
  String get addBlock => 'ब्लॉक जोड़ें';

  @override
  String get duplicateBlock => 'प्रतिलिपि बनाएँ';

  @override
  String get changeBlock => 'ब्लॉक का प्रकार बदलें';

  @override
  String get blockDeleted => 'ब्लॉक हटाया गया';

  @override
  String get pageDeleted => 'पृष्ठ हटाया गया';

  @override
  String get createNoteTask => 'Doever कार्य बनाएँ';

  @override
  String get noteTaskCreated => 'कार्य सूची में कार्य बनाया गया';

  @override
  String get noteRedo => 'फिर से करें';

  @override
  String get previousMatch => 'पिछला परिणाम';

  @override
  String get nextMatch => 'अगला परिणाम';

  @override
  String get noteUrl => 'वेब पता (http या https)';

  @override
  String get noteInvalidUrl => 'मान्य http या https पता दर्ज करें।';

  @override
  String get noteOpenLink => 'लिंक खोलें';

  @override
  String get noteImage => 'चित्र चुनें';

  @override
  String get noteImageError => 'चित्र उपलब्ध नहीं';

  @override
  String get noteToggleBody => 'संकुचित की जा सकने वाली सामग्री';

  @override
  String get noteIcon => 'सूचना चिह्न (वैकल्पिक)';

  @override
  String get noteText => 'पाठ';

  @override
  String get noteH1 => 'शीर्षक 1';

  @override
  String get noteH2 => 'शीर्षक 2';

  @override
  String get noteH3 => 'शीर्षक 3';

  @override
  String get noteBullet => 'बुलेट सूची';

  @override
  String get noteNumbered => 'क्रमांकित सूची';

  @override
  String get noteTodo => 'करने का कार्य';

  @override
  String get noteQuote => 'उद्धरण';

  @override
  String get noteDivider => 'विभाजक';

  @override
  String get noteCode => 'कोड';

  @override
  String get noteCallout => 'सूचना';

  @override
  String get noteLink => 'लिंक';

  @override
  String get noteToggle => 'टॉगल';

  @override
  String get noteChoosePage => 'कोई पृष्ठ चुनें या नया बनाएँ।';
}
