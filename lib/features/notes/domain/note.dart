import '../../../core/errors.dart';

enum NoteBlockType {
  text,
  heading1,
  heading2,
  heading3,
  bullet,
  numbered,
  todo,
  quote,
  divider,
  code,
  callout,
  image,
  link,
  toggle;

  bool get isList => this == bullet || this == numbered || this == todo;
  bool get canConvert =>
      this != image && this != divider && this != link && this != toggle;
}

final class NotePage {
  const NotePage({
    required this.id,
    required this.title,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  final String id, title;
  final double sortOrder;
  final DateTime createdAt, updatedAt;
  final DateTime? deletedAt;
}

/// Typed columns keep block metadata out of dynamic JSON maps.
final class NoteBlock {
  const NoteBlock({
    required this.id,
    required this.pageId,
    required this.type,
    this.content = '',
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.checked = false,
    this.url = '',
    this.imageName = '',
    this.detail = '',
    this.icon = '',
    this.expanded = true,
  });
  final String id, pageId, content, url, imageName, detail, icon;
  final NoteBlockType type;
  final double sortOrder;
  final DateTime createdAt, updatedAt;
  final DateTime? deletedAt;
  final bool checked, expanded;

  String get searchable => '$content\n$detail\n$url';
  NoteBlock copyWith({
    String? id,
    NoteBlockType? type,
    String? content,
    double? sortOrder,
    bool? checked,
    String? url,
    String? imageName,
    String? detail,
    String? icon,
    bool? expanded,
  }) => NoteBlock(
    id: id ?? this.id,
    pageId: pageId,
    type: type ?? this.type,
    content: content ?? this.content,
    sortOrder: sortOrder ?? this.sortOrder,
    checked: checked ?? this.checked,
    url: url ?? this.url,
    imageName: imageName ?? this.imageName,
    detail: detail ?? this.detail,
    icon: icon ?? this.icon,
    expanded: expanded ?? this.expanded,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );

  NoteBlock convert(NoteBlockType target) {
    if (target == type) return this;
    if (!type.canConvert || !target.canConvert) {
      throw const AppFailure(FailureKind.validation);
    }
    return copyWith(type: target);
  }

  bool sameContent(NoteBlock other) =>
      id == other.id &&
      pageId == other.pageId &&
      type == other.type &&
      content == other.content &&
      sortOrder == other.sortOrder &&
      checked == other.checked &&
      url == other.url &&
      imageName == other.imageName &&
      detail == other.detail &&
      icon == other.icon &&
      expanded == other.expanded;
}

final class NoteDocument {
  NoteDocument(this.page, Iterable<NoteBlock> blocks)
    : blocks = List.unmodifiable(blocks);
  final NotePage page;
  final List<NoteBlock> blocks;
}

bool validNoteUrl(String value) {
  final uri = Uri.tryParse(value);
  return uri != null &&
      (uri.scheme == 'https' || uri.scheme == 'http') &&
      uri.host.isNotEmpty &&
      uri.userInfo.isEmpty &&
      !RegExp(r'\s').hasMatch(value);
}

NoteBlockType? markdownBlock(String text) => switch (text) {
  '# ' => NoteBlockType.heading1,
  '## ' => NoteBlockType.heading2,
  '### ' => NoteBlockType.heading3,
  '- ' || '* ' => NoteBlockType.bullet,
  '1. ' => NoteBlockType.numbered,
  '[] ' || '[ ] ' || '- [ ] ' => NoteBlockType.todo,
  '> ' => NoteBlockType.quote,
  '``` ' => NoteBlockType.code,
  '--- ' => NoteBlockType.divider,
  _ => null,
};
