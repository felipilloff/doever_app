import 'package:doever/features/focus/application/focus_player.dart';
import 'package:doever/features/focus/application/focus_session_controller.dart';
import 'package:doever/features/focus/data/drift_focus_repository.dart';
import 'package:doever/features/focus/data/focus_session_repository.dart';
import 'package:doever/features/focus/domain/focus_session.dart';
import 'package:doever/features/focus/domain/soundscape.dart';
import 'package:doever/features/focus/presentation/session_setup.dart';
import 'package:doever/features/focus/presentation/session_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fake_focus_audio.dart';

void main() {
  testWidgets(
    'task setup, soundscape, route survival, controls, history and Quick Focus',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final h = AppHarness();
      await h.initialize();
      await h.preferences.setString(
        'focus.session.soundscape',
        'deleted-custom-mix',
      );
      final id = await h.repository.createTask('Implement authentication');
      final audio = FakeFocusAudio();
      final player = FocusPlayer(
        DriftFocusRepository(h.database),
        audio,
        FocusPreferences(),
      );
      var elapsed = Duration.zero;
      final controller = FocusSessionController(
        FocusSessionRepository(h.database),
        h.repository,
        player: player,
        scheduleTicks: false,
        monotonic: () => elapsed,
        now: () => DateTime.utc(2026).add(elapsed),
      );
      await tester.pumpWidget(
        h.app(focusPlayer: player, focusSession: controller),
      );
      h.router.go('/task/$id');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start Focus'));
      await tester.pumpAndSettle();
      expect(find.byType(SessionSetup), findsOneWidget);
      await tester.tap(find.text('45 min'));
      await tester.tap(find.byType(DropdownButtonFormField<String>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rainy café').last);
      await tester.pumpAndSettle();
      expect(audio.calls, isEmpty);
      await tester.ensureVisible(find.text('Start'));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      expect(controller.session!.linkedTaskId, id);
      expect(controller.session!.plannedDuration, const Duration(minutes: 45));
      expect(audio.playing, true);
      final sessionId = controller.session!.id;
      elapsed += const Duration(seconds: 7);
      await controller.tick();
      for (final route in [
        '/notes',
        '/',
        '/settings',
        '/focus',
        '/focus/session',
      ]) {
        h.router.go(route);
        await tester.pumpAndSettle();
        expect(controller.session!.id, sessionId);
        expect(controller.elapsed, const Duration(seconds: 7));
        expect(find.textContaining('44:53'), findsWidgets);
      }
      expect(find.byType(SessionScreen), findsOneWidget);
      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();
      expect(controller.session!.completionState, SessionState.paused);
      expect(audio.playing, true);
      await tester.tap(find.text('Resume'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finish Session'));
      await tester.pumpAndSettle();
      expect(controller.session!.completionState, SessionState.completed);
      expect(find.text('Local history'), findsOneWidget);
      await tester.tap(find.text('Complete Task'));
      await tester.pumpAndSettle();
      expect((await h.repository.getTask(id))!.isCompleted, true);
      h.router.go('/');
      await tester.pumpAndSettle();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.byType(SessionSetup), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SessionSetup),
          matching: find.text('Rainy café'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Pomodoro'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Start'));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finish Session'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start Short break'));
      await tester.pumpAndSettle();
      expect(controller.session!.sessionType, SessionType.shortBreak);
      expect(find.text('Short break · running'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await controller.shutdown();
      await player.shutdown();
      await h.dispose();
    },
    variant: TargetPlatformVariant({
      TargetPlatform.linux,
      TargetPlatform.windows,
    }),
  );
}
