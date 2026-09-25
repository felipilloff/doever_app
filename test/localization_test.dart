import 'package:doever/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  testWidgets('switches all five languages and restores the saved choice', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.localesTestValue = [const Locale('ja')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    final harness = AppHarness();
    await tester.runAsync(harness.initialize);
    await tester.pumpWidget(harness.app());
    harness.router.go('/settings');
    await tester.pumpAndSettle();
    expect(
      Localizations.localeOf(tester.element(find.byType(SettingsScreen))),
      const Locale('en'),
    );

    for (final (code, name, heading) in const [
      ('es', 'Español', 'Configuración'),
      ('zh', '中文', '设置'),
      ('hi', 'हिन्दी', 'सेटिंग'),
      ('ar', 'العربية', 'الإعدادات'),
      ('en', 'English', 'Settings'),
    ]) {
      await tester.scrollUntilVisible(
        find.text(name),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
      expect(find.text(heading), findsOneWidget);
      expect(harness.preferences.getString('language'), code);
      expect(
        Localizations.localeOf(tester.element(find.byType(SettingsScreen)))
            .languageCode,
        code,
      );
      if (code == 'ar') {
        expect(
          Directionality.of(tester.element(find.byType(SettingsScreen))),
          TextDirection.rtl,
        );
      }
    }

    await tester.scrollUntilVisible(
      find.text('العربية'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pumpWidget(harness.app());
    await tester.pumpAndSettle();
    expect(find.text('الإعدادات'), findsOneWidget);
    expect(
      Localizations.localeOf(tester.element(find.byType(SettingsScreen)))
          .languageCode,
      'ar',
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await harness.dispose();
  });
}
