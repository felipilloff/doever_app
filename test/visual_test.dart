import 'package:doever/features/tasks/domain/calendar_date.dart';
import 'package:doever/features/tasks/domain/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  for (final theme in ['light', 'dark']) {
    for (final phone in [false, true]) {
      testWidgets('visual $theme ${phone ? 'phone' : 'desktop'}', (
        tester,
      ) async {
        tester.view.physicalSize = phone
            ? const Size(390, 844)
            : const Size(1440, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final h = AppHarness();
        await tester.runAsync(() => h.initialize(theme: theme));
        await h.repository.createList('Personal');
        await h.repository.createList('Studio');
        final id = await h.repository.createTask(
          'Shape the week ahead',
          patch: TaskPatch(
            myDayDate: Change(CalendarDate(2026, 9, 25)),
            isImportant: true,
            notes: 'Leave room for the unexpected.',
            dueDate: Change(CalendarDate(2026, 9, 28)),
          ),
        );
        await h.repository.addStep(id, 'Review open projects');
        await h.repository.addStep(id, 'Choose three priorities');
        await h.repository.createTask(
          'Take a walk without your phone',
          patch: TaskPatch(myDayDate: Change(CalendarDate(2026, 9, 25))),
        );
        await h.repository.createTask(
          'Finish the first chapter',
          patch: TaskPatch(myDayDate: Change(CalendarDate(2026, 9, 25))),
        );
        await tester.pumpWidget(
          RepaintBoundary(
            key: const ValueKey('capture'),
            child: h.app(today: CalendarDate(2026, 9, 25)),
          ),
        );
        await tester.pumpAndSettle();
        if (!phone) {
          await tester.tap(find.text('Shape the week ahead'));
          await tester.pumpAndSettle();
        }
        await expectLater(
          find.byKey(const ValueKey('capture')),
          matchesGoldenFile(
            'goldens/${theme}_${phone ? 'phone' : 'desktop'}.png',
          ),
        );
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        await h.dispose();
      });
    }
  }
}
