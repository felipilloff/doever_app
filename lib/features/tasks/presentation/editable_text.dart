import 'package:flutter/material.dart';

import '../../../core/widgets/feedback.dart';
import '../../../core/logging.dart';
import '../../../l10n/app_localizations.dart';

/// Writes are serialized and begin on every valid edit. Leaving a route never
/// drops a pending debounce, and failures leave the editor text available.
class SavedTextField extends StatefulWidget {
  const SavedTextField({
    super.key,
    required this.value,
    required this.label,
    required this.onSave,
    this.multiline = false,
    this.maxLength = 500,
  });
  final String value, label;
  final Future<void> Function(String) onSave;
  final bool multiline;
  final int maxLength;
  @override
  State<SavedTextField> createState() => _SavedTextFieldState();
}

class _SavedTextFieldState extends State<SavedTextField> {
  late final _controller = TextEditingController(text: widget.value);
  final _focus = FocusNode();
  Future<void> _pending = Future<void>.value();
  int _revision = 0;
  bool _saving = false, _failed = false, _invalid = false;
  @override
  void didUpdateWidget(SavedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focus.hasFocus &&
        !_saving &&
        !_failed &&
        _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  void _save(String value) {
    if (!widget.multiline && value.trim().isEmpty) {
      _revision++;
      setState(() {
        _invalid = true;
        _saving = false;
      });
      return;
    }
    final revision = ++_revision;
    final save = widget.onSave;
    setState(() {
      _invalid = false;
      _saving = true;
      _failed = false;
    });
    _pending = _pending.then((_) async {
      bool ok;
      if (mounted) {
        ok = await perform(context, () => save(value));
      } else {
        try {
          await save(value);
          ok = true;
        } catch (error, stack) {
          logFailure('editor.save_after_close', error, stack);
          ok = false;
        }
      }
      if (mounted && revision == _revision) {
        setState(() {
          _saving = false;
          _failed = !ok;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return TextField(
      controller: _controller,
      focusNode: _focus,
      minLines: widget.multiline ? 4 : 1,
      maxLines: widget.multiline ? 10 : 3,
      maxLength: widget.maxLength,
      onChanged: _save,
      onSubmitted: _save,
      decoration: InputDecoration(
        labelText: widget.label,
        counterText: '',
        errorText: _invalid ? s.titleRequired : null,
        helperText: _saving
            ? s.saving
            : _failed
            ? s.persistenceError
            : null,
        suffixIcon: _failed
            ? IconButton(
                tooltip: s.retry,
                icon: const Icon(Icons.refresh),
                onPressed: () => _save(_controller.text),
              )
            : null,
      ),
    );
  }
}
