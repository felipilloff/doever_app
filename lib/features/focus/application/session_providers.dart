import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/focus_session.dart';
import 'focus_session_controller.dart';

final focusSessionProvider = Provider<FocusSessionController?>((ref) => null);
final focusHistoryProvider = StreamProvider<List<FocusSession>>(
  (ref) =>
      ref.watch(focusSessionProvider)?.repository.watchHistory() ??
      Stream.value([]),
);
