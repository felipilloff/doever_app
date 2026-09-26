import 'note.dart';

abstract interface class NoteRepository {
  Stream<List<NotePage>> watchPages({String search = ''});
  Stream<List<NoteBlock>> watchBlocks(String pageId);
  Future<NoteDocument> load(String pageId);
  Future<NotePage> createPage();
  Future<void> deletePage(String id);
  Future<void> restorePage(String id);
  Future<void> movePage(String id, int target);

  /// Atomically persists changed rows and tombstones removed blocks.
  Future<void> save(String pageId, String title, List<NoteBlock> blocks);
}
