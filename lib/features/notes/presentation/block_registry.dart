import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/note.dart';

extension BlockDefinition on NoteBlockType {
  String label(AppLocalizations s) => switch (this) {
    NoteBlockType.text => s.noteText,
    NoteBlockType.heading1 => s.noteH1,
    NoteBlockType.heading2 => s.noteH2,
    NoteBlockType.heading3 => s.noteH3,
    NoteBlockType.bullet => s.noteBullet,
    NoteBlockType.numbered => s.noteNumbered,
    NoteBlockType.todo => s.noteTodo,
    NoteBlockType.quote => s.noteQuote,
    NoteBlockType.divider => s.noteDivider,
    NoteBlockType.code => s.noteCode,
    NoteBlockType.callout => s.noteCallout,
    NoteBlockType.image => s.noteImage,
    NoteBlockType.link => s.noteLink,
    NoteBlockType.toggle => s.noteToggle,
  };
  IconData get icon => switch (this) {
    NoteBlockType.text => Icons.notes,
    NoteBlockType.heading1 => Icons.title,
    NoteBlockType.heading2 => Icons.title,
    NoteBlockType.heading3 => Icons.title,
    NoteBlockType.bullet => Icons.format_list_bulleted,
    NoteBlockType.numbered => Icons.format_list_numbered,
    NoteBlockType.todo => Icons.check_box_outlined,
    NoteBlockType.quote => Icons.format_quote,
    NoteBlockType.divider => Icons.horizontal_rule,
    NoteBlockType.code => Icons.code,
    NoteBlockType.callout => Icons.info_outline,
    NoteBlockType.image => Icons.image_outlined,
    NoteBlockType.link => Icons.link,
    NoteBlockType.toggle => Icons.expand_more,
  };
  bool matches(String query, AppLocalizations s) =>
      '$name ${label(s)} ${switch (this) {
            NoteBlockType.heading1 || NoteBlockType.heading2 || NoteBlockType.heading3 => 'heading header',
            NoteBlockType.bullet => 'unordered list',
            NoteBlockType.numbered => 'ordered list',
            NoteBlockType.todo => 'checkbox task',
            _ => '',
          }}'
          .toLowerCase()
          .contains(query.toLowerCase());
}
