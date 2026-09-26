import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:doever/app/app.dart';
import 'package:doever/app/providers.dart';
import 'package:doever/core/errors.dart';
import 'package:doever/features/settings/background/background_canvas.dart';
import 'package:doever/features/settings/background/background_preference.dart';
import 'package:doever/features/tasks/domain/calendar_date.dart';
import 'package:doever/features/tasks/domain/task.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/app_harness.dart';
import 'support/fake_reminders.dart';

Future<Uint8List> landscape({int width = 1600, int height = 900}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final bounds = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
  canvas.drawRect(
    bounds,
    Paint()
      ..shader = ui.Gradient.linear(Offset.zero, Offset(0, height.toDouble()), [
        const Color(0xffadc8be),
        const Color(0xffd7c9ab),
      ]),
  );
  for (var i = 0; i < 4; i++) {
    final y = height * (0.3 + i * 0.15);
    final path = Path()
      ..moveTo(0, y + height * .1)
      ..cubicTo(
        width * .25,
        y - height * .3,
        width * .6,
        y + height * .4,
        width.toDouble(),
        y,
      )
      ..lineTo(width.toDouble(), height.toDouble())
      ..lineTo(0, height.toDouble())
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = [
          const Color(0xff829c91),
          const Color(0xff597c70),
          const Color(0xff375b4f),
          const Color(0xff183e32),
        ][i],
    );
  }
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer
      .asUint8List();
  image.dispose();
  picture.dispose();
  return bytes;
}

class FakePicker extends FileSelectorPlatform {
  XFile? selection;
  int calls = 0;
  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    calls++;
    expect(
      acceptedTypeGroups!.single.extensions,
      containsAll(['png', 'jpg', 'jpeg', 'webp']),
    );
    return selection;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('imports, optimizes, persists, rejects invalid replacements and removes its own copy', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final directory = await Directory.systemTemp.createTemp('background-test-');
    addTearDown(() => directory.delete(recursive: true));
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    ProviderContainer scope() => ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(preferences),
        backgroundDirectoryProvider.overrideWithValue(
          () async => Directory('${directory.path}/managed'),
        ),
      ],
    );
    var container = scope();
    await container.read(backgroundProvider.future);
    final original = File('${directory.path}/original.png');
    final bytes = await landscape(width: 3200, height: 1800);
    await original.writeAsBytes(bytes);
    await container
        .read(backgroundProvider.notifier)
        .importImage(XFile(original.path));
    expect(await original.readAsBytes(), bytes);
    final copied = container.read(backgroundProvider).requireValue!;
    final codec = await ui.instantiateImageCodec(copied);
    final frame = await codec.getNextFrame();
    expect(frame.image.width, 2560);
    expect(frame.image.height, 1440);
    frame.image.dispose();
    codec.dispose();
    container.dispose();
    await original.delete();
    container = scope();
    addTearDown(container.dispose);
    expect(await container.read(backgroundProvider.future), isNotNull);
    final previousName = preferences.getString(
      BackgroundPreference.preferenceKey,
    );
    final controller = container.read(backgroundProvider.notifier);
    for (final bad in [
      Uint8List.fromList([1, 2, 3]),
      Uint8List(BackgroundPreference.maxFileBytes + 1),
    ]) {
      await expectLater(
        controller.importImage(XFile.fromData(bad, name: 'bad.png')),
        throwsA(
          isA<AppFailure>().having(
            (e) => e.kind,
            'kind',
            FailureKind.backgroundImage,
          ),
        ),
      );
      expect(
        preferences.getString(BackgroundPreference.preferenceKey),
        previousName,
      );
      expect(container.read(backgroundProvider).requireValue, isNotNull);
    }
    await controller.importImage(
      XFile.fromData(await landscape(), name: 'replacement.png'),
    );
    expect(await Directory('${directory.path}/managed').list().length, 1);
    await controller.remove();
    expect(container.read(backgroundProvider).requireValue, isNull);
    expect(
      preferences.containsKey(BackgroundPreference.preferenceKey),
      isFalse,
    );
    expect(await Directory('${directory.path}/managed').list().length, 0);
  });

  testWidgets(
    'desktop chooser cancellation, preview, readable themes and removal',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 960);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final originalPicker = FileSelectorPlatform.instance;
      final picker = FakePicker();
      FileSelectorPlatform.instance = picker;
      addTearDown(() => FileSelectorPlatform.instance = originalPicker);
      final harness = AppHarness();
      await tester.runAsync(harness.initialize);
      final directory = (await tester.runAsync(
        () => Directory.systemTemp.createTemp('background-ui-'),
      ))!;
      final today = CalendarDate.fromLocal(DateTime.now());
      await harness.repository.createTask(
        'Make room for what matters',
        patch: TaskPatch(myDayDate: Change(today), isImportant: true),
      );
      await harness.repository.createTask(
        'A quiet moment to plan the day',
        patch: TaskPatch(myDayDate: Change(today)),
      );
      final container = ProviderContainer(
        overrides: [
          preferencesProvider.overrideWithValue(harness.preferences),
          repositoryProvider.overrideWithValue(harness.repository),
          remindersProvider.overrideWithValue(FakeReminders()),
          backgroundDirectoryProvider.overrideWithValue(() async => directory),
        ],
      );
      await tester.pumpWidget(
        RepaintBoundary(
          key: const ValueKey('background-capture'),
          child: UncontrolledProviderScope(
            container: container,
            child: DoeverApp(router: harness.router),
          ),
        ),
      );
      harness.router.go('/settings');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose image'));
      await tester.pumpAndSettle();
      expect(picker.calls, 1);
      expect(
        harness.preferences.containsKey(BackgroundPreference.preferenceKey),
        isFalse,
      );
      picker.selection = XFile.fromData(
        (await tester.runAsync(landscape))!,
        name: 'landscape.png',
      );
      await tester.runAsync(() async {
        final applied = Completer<void>();
        final subscription = container.listen(backgroundProvider, (_, next) {
          if (next.asData?.value != null && !applied.isCompleted) {
            applied.complete();
          }
        });
        try {
          await tester.tap(find.text('Choose image'));
          await applied.future.timeout(const Duration(seconds: 10));
        } finally {
          subscription.close();
        }
      });
      await tester.pumpAndSettle();
      expect(find.text('Change image'), findsOneWidget);
      expect(find.text('Remove background'), findsOneWidget);

      Future<void> capture(String name) async {
        if (!const bool.fromEnvironment('backgroundScreenshots')) return;
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('background-capture')),
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File('build/background-$name.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      await capture('settings');
      harness.router.go('/');
      await tester.pumpAndSettle();
      expect(
        tester.widget<BackgroundCanvas>(find.byType(BackgroundCanvas)).image,
        isNotNull,
      );
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await container.read(themeProvider.notifier).set(mode);
        await tester.pumpAndSettle();
        expect(find.text('Make room for what matters'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await capture(mode.name);
      }
      harness.router.go('/settings');
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final removed = Completer<void>();
        final removal = container.listen(backgroundProvider, (_, next) {
          if (next is AsyncData<Uint8List?> &&
              next.value == null &&
              !removed.isCompleted) {
            removed.complete();
          }
        });
        try {
          await tester.tap(find.text('Remove background'));
          await removed.future.timeout(const Duration(seconds: 10));
        } finally {
          removal.close();
        }
      });
      await tester.pumpAndSettle();
      expect(find.text('Choose image'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.pumpAndSettle();
      await harness.dispose();
      await tester.runAsync(() => directory.delete(recursive: true));
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets('background controls are absent on mobile', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final harness = AppHarness();
    await tester.runAsync(harness.initialize);
    await tester.pumpWidget(harness.app());
    harness.router.go('/settings');
    await tester.pumpAndSettle();
    expect(find.text('Workspace background'), findsNothing);
    expect(find.text('Choose image'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await harness.dispose();
    debugDefaultTargetPlatformOverride = null;
  });
}
