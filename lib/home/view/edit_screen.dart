// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:note_taker/home/data/models/note_model.dart';
import 'package:note_taker/home/view/home_view.dart';

class EditNotePage extends ConsumerStatefulWidget {
  NoteModel note;
  bool isNewNote;

  EditNotePage({
    super.key,
    required this.note,
    required this.isNewNote,
  });

  @override
  ConsumerState<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends ConsumerState<EditNotePage> {
  late QuillController _titleController;
  late QuillController _contentController;

  @override
  void initState() {
    super.initState();
    _loadExistingNote();
  }

  void _loadExistingNote() {
    final titleDoc = Document()..insert(0, widget.note.title);
    final contentDoc = Document()..insert(0, widget.note.content);

    _titleController = QuillController(
      document: titleDoc,
      selection: const TextSelection.collapsed(offset: 0),
    );

    _contentController = QuillController(
      document: contentDoc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  bool _isDocEmpty(QuillController c) =>
      c.document.toPlainText().trim().isEmpty;

  // add new note
  void _addNewNote() {
    final notes = ref.read(noteDataProvider);
    final int id = notes.getAllNotes().length;

    final String title = _titleController.document.toPlainText().trim();
    final String content = _contentController.document.toPlainText().trim();

    notes.addNewNotes(
      NoteModel(
        id: id,
        title: title,
        content: content,
      ),
    );
  }

  // update existing note
  void _updateNote() {
    final String title = _titleController.document.toPlainText().trim();
    final String content = _contentController.document.toPlainText().trim();

    ref.read(noteDataProvider).updateNote(
          widget.note,
          title,
          content,
        );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            if (widget.isNewNote &&
                (!(_isDocEmpty(_titleController) &&
                    _isDocEmpty(_contentController)))) {
              _addNewNote();
            } else {
              _updateNote();
            }
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Title editor (single line feel)
            Container(
              height: 48,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: QuillEditor.basic(
                controller: _titleController,
                readOnly: false,
              ),
            ),

            const SizedBox(height: 8),

            // Content editor (expands)
            Expanded(
              child: QuillEditor.basic(
                controller: _contentController,
                readOnly: false,
              ),
            ),

            // Toolbar (attached to content controller)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black,
              ),
              child: QuillToolbar.basic(
                controller: _contentController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
