import 'custom_theme.dart';

abstract interface class ThemeRepository {
  Stream<ThemeLibrary> watchLibrary();
  Future<ThemeLibrary> load();
  Future<void> save(CustomTheme theme, {bool apply = false});
  Future<void> select(String id);
  Future<CustomTheme> duplicate(CustomTheme theme, {String? name});
  Future<void> delete(String id);
  Future<void> rememberColors(List<int> colors);
}
