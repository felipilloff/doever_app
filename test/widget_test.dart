import 'package:doever/features/tasks/domain/calendar_date.dart';
import 'package:doever/features/tasks/domain/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  testWidgets('create, edit details, smart view, search, completion and undo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final h = AppHarness();
    await tester.runAsync(() => h.initialize());
    await tester.pumpWidget(h.app());
    await tester.pumpAndSettle();
    expect(find.text('Nothing planned for today.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('add-task')),
      'Buy coffee',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Buy coffee'), findsOneWidget);
    await tester.tap(find.text('Buy coffee'));
    await tester.pumpAndSettle();
    expect(find.text('Task details'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Task title'), '');
    await tester.pumpAndSettle();
    expect(find.text('Enter a task title.'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Task title'),
      'Buy good coffee',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Mark important').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close details'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Important').first);
    await tester.pumpAndSettle();
    expect(find.text('Buy good coffee'), findsOneWidget);
    await tester.tap(find.byTooltip('Complete task'));
    await tester.pumpAndSettle();
    expect(find.text('No important tasks.'), findsOneWidget);
    await tester.tap(find.text('Tasks').first);
    await tester.pumpAndSettle();
    expect(find.text('Buy good coffee'), findsOneWidget);
    await tester.tap(find.byTooltip('Reopen task'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buy good coffee'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Delete task'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Delete task'));
    await tester.pumpAndSettle();
    expect(find.text('Task deleted'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Buy good coffee'), findsOneWidget);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Search titles and notes'),
      'good',
    );
    await tester.pumpAndSettle();
    expect(find.text('Buy good coffee'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(TextField, 'Search titles and notes'),
      findsNothing,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await h.dispose();
  });
  testWidgets(
    'phone navigation creates a custom list and opens a dedicated detail route',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final h = AppHarness();
      await tester.runAsync(() => h.initialize());
      await tester.pumpWidget(h.app());
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Open navigation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New list'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Personal');
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle(const Duration(milliseconds: 400));
      expect(find.text('Personal'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('add-task')),
        'Read a chapter',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Read a chapter'));
      await tester.pumpAndSettle();
      expect(h.router.canPop(), isTrue);
      expect(find.text('Task details'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Add step'),
        'Find a book',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Find a book'), findsOneWidget);
      await tester.tap(find.byTooltip('Close details'));
      await tester.pumpAndSettle();
      expect(find.text('Personal'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await h.dispose();
    },
  );
  for (final size in [
    const Size(390, 844),
    const Size(900, 800),
    const Size(1440, 960),
  ]) {
    for (final theme in ['light', 'dark']) {
      testWidgets('layout ${size.width} $theme and text scaling', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final h = AppHarness();
        await tester.runAsync(() => h.initialize(theme: theme));
        await h.repository.createTask(
          'Make space for what matters',
          patch: TaskPatch(
            myDayDate: Change(CalendarDate.fromLocal(DateTime.now())),
          ),
        );
        await tester.pumpWidget(h.app());
        await tester.pumpAndSettle();
        expect(find.text('Make space for what matters'), findsOneWidget);
        final semantics = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        semantics.dispose();
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        tester.platformDispatcher.clearTextScaleFactorTestValue();
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        await h.dispose();
      });
    }
  }
}
