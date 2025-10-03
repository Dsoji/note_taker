import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:note_taker/home/data/models/note_model.dart';
import 'package:note_taker/home/view/home_view.dart';
import 'package:super_editor/super_editor.dart';

class EditNotePage extends HookConsumerWidget {
  final NoteModel note;
  final bool isNewNote;

  const EditNotePage({
    super.key,
    required this.note,
    required this.isNewNote,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleDoc = useMemoized(
      () => MutableDocument(nodes: [
        ParagraphNode(id: 'title-1', text: AttributedText(note.title)),
      ]),
      [note.title],
    );
    final titleEditor =
        useMemoized(() => DocumentEditor(document: titleDoc), [titleDoc]);
    final titleComposer = useMemoized(() => DocumentComposer(), []);
    useListenable(titleDoc);

    final contentDoc = useMemoized(
      () => MutableDocument(nodes: [
        ParagraphNode(id: 'content-1', text: AttributedText(note.content)),
      ]),
      [note.content],
    );
    final contentEditor =
        useMemoized(() => DocumentEditor(document: contentDoc), [contentDoc]);
    final contentComposer = useMemoized(() => DocumentComposer(), []);
    useListenable(contentDoc);

    // Focus
    final titleFocusNode = useFocusNode();
    final contentFocusNode = useFocusNode();

    // Clean up
    useEffect(() {
      return () {
        titleComposer.dispose();
        contentComposer.dispose();
      };
    }, []);

    String readDoc(MutableDocument doc) {
      final buf = StringBuffer();
      for (var i = 0; i < doc.nodes.length; i++) {
        final node = doc.nodes[i];
        if (node is TextNode) buf.write(node.text.text);
        if (i < doc.nodes.length - 1) buf.writeln();
      }
      return buf.toString();
    }

    String titleText() => readDoc(titleDoc).trim();
    String contentText() => readDoc(contentDoc).trim();

    bool bothEmpty() => titleText().isEmpty && contentText().isEmpty;
    bool changedFromOriginal() =>
        titleText() != note.title.trim() ||
        contentText() != note.content.trim();

    void addNewNote() {
      if (bothEmpty()) return;
      final notes = ref.read(noteDataProvider);
      final nextId = notes.getAllNotes().isEmpty
          ? 0
          : (notes
                  .getAllNotes()
                  .map((n) => n.id)
                  .reduce((a, b) => a > b ? a : b) +
              1);

      notes.addNewNotes(
        NoteModel(
          id: nextId,
          title: titleText(),
          content: contentText(),
          modifiedTime: DateTime.now(),
        ),
      );
    }

    void updateNote() {
      if (!changedFromOriginal()) return;
      ref.read(noteDataProvider).updateNote(
            note,
            titleText(),
            contentText(),
          );
    }

    Future<bool> handlePop() async {
      if (isNewNote) {
        if (!bothEmpty()) addNewNote();
      } else {
        if (changedFromOriginal()) updateNote();
      }
      return true;
    }

    Widget placeholderOverlay({
      required bool show,
      required String text,
      required TextStyle style,
      Alignment alignment = Alignment.centerLeft,
      EdgeInsetsGeometry padding = EdgeInsets.zero,
    }) {
      if (!show) return const SizedBox.shrink();
      return IgnorePointer(
        child: Align(
          alignment: alignment,
          child: Padding(padding: padding, child: Text(text, style: style)),
        ),
      );
    }

    return WillPopScope(
      onWillPop: handlePop,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: theme.textTheme.titleLarge?.color),
            onPressed: () async {
              final canPop = await handlePop();
              if (canPop && context.mounted) Navigator.pop(context);
            },
          ),
          title: Text(isNewNote ? 'New Note' : 'Edit Note'),
          actions: [
            IconButton(
              icon:
                  Icon(Icons.delete, color: theme.textTheme.titleLarge?.color),
              onPressed: () {
                ref.read(noteDataProvider).deleteNote(note);

                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.check, color: theme.textTheme.titleLarge?.color),
              onPressed: () {
                if (isNewNote) {
                  addNewNote();
                } else {
                  updateNote();
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                child: SizedBox(
                  height: 56,
                  child: Stack(
                    children: [
                      SuperEditor(
                        editor: titleEditor,
                        composer: titleComposer,
                        focusNode: titleFocusNode,
                        inputSource: TextInputSource.ime,
                      ),
                      if (titleText().isEmpty && !titleFocusNode.hasFocus)
                        placeholderOverlay(
                          show: true,
                          text: 'Title',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ── Content editor
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                  ),
                  child: Stack(
                    children: [
                      SuperEditor(
                        editor: contentEditor,
                        composer: contentComposer,
                        focusNode: contentFocusNode,
                        inputSource: TextInputSource.ime,
                      ),
                      if (contentText().isEmpty && !contentFocusNode.hasFocus)
                        Positioned.fill(
                          child: placeholderOverlay(
                            show: true,
                            text: 'Start writing your note...',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 16),
                            padding: const EdgeInsets.only(top: 2),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _FabEditorToolbar(
          editor: contentEditor,
          composer: contentComposer,
        ),
      ),
    );
  }
}

/// Always-visible formatting toolbar sitting in the FAB slot.
/// Works with both selected ranges and a collapsed caret (typing style).
class _FabEditorToolbar extends StatelessWidget {
  final DocumentEditor editor;
  final DocumentComposer composer;

  const _FabEditorToolbar({
    required this.editor,
    required this.composer,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _pill(context, 'B', () => _toggleAttrib(boldAttribution)),
            _pill(context, 'I', () => _toggleAttrib(italicsAttribution)),
            _pill(context, 'U', () => _toggleAttrib(underlineAttribution)),
            // Uncomment to add more:
            // _divider(),
            // _pill(context, 'T', _toggleH1),
            // _pill(context, '≡L', () => _setAlign(TextAlign.left)),
            // _pill(context, '≡C', () => _setAlign(TextAlign.center)),
            // _pill(context, '≡R', () => _setAlign(TextAlign.right)),
          ],
        ),
      ),
    );
  }

  Widget _pill(BuildContext context, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(
          label,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 20, color: Colors.white24);

  void _toggleAttrib(Attribution attrib) {
    final selection = composer.selection;
    if (selection == null) return;

    editor.executeCommand(
      ToggleTextAttributionsCommand(
        documentSelection: selection,
        attributions: {attrib},
      ),
    );
  }

  // Optional header toggle (H1)
  // void _toggleH1() {
  //   final selection = composer.selection;
  //   if (selection == null) return;

  //   final nodeId = selection.extent.nodeId;
  //   final node = editor.document.getNodeById(nodeId);
  //   if (node is ParagraphNode) {
  //     final isH1 = node.metadata['blockType'] == header1Attribution;
  //     editor.executeCommand(
  //       ChangeParagraphBlockTypeCommand(
  //         nodeId: nodeId,
  //         blockType: isH1 ? paragraphAttribution : header1Attribution,
  //       ),
  //     );
  //   }
  // }

  // Optional alignment setters
  // void _setAlign(TextAlign align) {
  //   final selection = composer.selection;
  //   if (selection == null) return;

  //   final nodeId = selection.extent.nodeId;
  //   final node = editor.document.getNodeById(nodeId);
  //   if (node is! ParagraphNode) return;

  //   editor.executeCommand(
  //     SetParagraphMetadataCommand(
  //       paragraphNodeId: nodeId,
  //       metadata: {'textAlign': align},
  //     ),
  //   );
  // }
}
