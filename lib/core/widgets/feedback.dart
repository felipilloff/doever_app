import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../errors.dart';
import '../logging.dart';

Future<bool> perform(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
    return true;
  } catch (error, stack) {
    logFailure('ui.action', error, stack);
    if (context.mounted) {
      final s = AppLocalizations.of(context);
      final message = switch (error) {
        AppFailure(kind: FailureKind.backgroundImage) => s.backgroundInvalid,
        AppFailure(kind: FailureKind.validation) => s.validationError,
        AppFailure(kind: FailureKind.notification) => s.notificationError,
        AppFailure(kind: FailureKind.persistence) => s.persistenceError,
        _ => s.unexpectedError,
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
    return false;
  }
}

Future<String?> askText(
  BuildContext context, {
  required String title,
  String initial = '',
  int maxLength = 200,
}) => showDialog<String>(
  context: context,
  builder: (_) =>
      _TextDialog(title: title, initial: initial, maxLength: maxLength),
);

class _TextDialog extends StatefulWidget {
  const _TextDialog({
    required this.title,
    required this.initial,
    required this.maxLength,
  });
  final String title, initial;
  final int maxLength;
  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  late final _controller = TextEditingController(text: widget.initial);
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_controller.text.trim().isNotEmpty) {
      Navigator.pop(context, _controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: widget.maxLength,
        decoration: InputDecoration(labelText: widget.title),
        onSubmitted: (_) => _confirm(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        FilledButton(onPressed: _confirm, child: Text(s.confirm)),
      ],
    );
  }
}
