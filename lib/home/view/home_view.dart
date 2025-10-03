// home_view.dart
// ignore_for_file: depend_on_referenced_packages

import 'dart:typed_data';

import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:note_taker/core/mixin/share_mixin.dart';
import 'package:note_taker/home/data/models/note_data.dart';
import 'package:note_taker/home/data/models/note_model.dart';
import 'package:note_taker/home/view/edit_screen.dart';
import 'package:note_taker/home/view/widgets/preview_card.dart';
import 'package:screenshot/screenshot.dart';

final noteDataProvider = ChangeNotifierProvider<NoteData>((ref) {
  final data = NoteData();
  return data;
});

class HomeView extends HookConsumerWidget with ShareMixin {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      final data = ref.read(noteDataProvider);
      data.initializeNotes();
      return null;
    }, []);

    final noteData = ref.watch(noteDataProvider);
    final query = useState('');

    // Screenshot controller for off-screen capture
    final screenshotController = useMemoized(() => ScreenshotController());

    void goToNotePage(NoteModel note, bool isNewNote) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditNotePage(
            isNewNote: isNewNote,
            note: note,
          ),
        ),
      );
    }

    // create new note
    void createNewNote() {
      final id = noteData.getAllNotes().length;
      final newNote = NoteModel(
        id: id,
        title: '',
        content: '',
        modifiedTime: DateTime.now(),
      );
      goToNotePage(newNote, true);
    }

    // delete note with confirmation
    void deleteNote(NoteModel note) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Note'),
            content: const Text('Are you sure you want to delete this note?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(noteDataProvider).deleteNote(note);
                  Navigator.of(context).pop();
                },
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );
    }

    Widget buildShareCard(NoteModel note) {
      return Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: 720, // share-friendly width
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.black),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          note.title.isEmpty ? 'Untitled Note' : note.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Date
                  Text(
                    'Created: ${DateFormat('MMM dd, yyyy - HH:mm').format(note.modifiedTime)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  Container(height: 1, color: Colors.grey[300]),
                  const SizedBox(height: 20),

                  // Content
                  Text(
                    note.content.isEmpty ? 'No content' : note.content,
                    style: const TextStyle(fontSize: 18, height: 1.6),
                    maxLines: 20,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Note Taker',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Note',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    /// Capture the share UI off-screen and hand the bytes to your mixin
    Future<void> shareNote(NoteModel note) async {
      try {
        final shareWidget = MediaQuery(
          data: const MediaQueryData(size: Size(1080, 1920)),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(useMaterial3: true),
            home: Scaffold(
              backgroundColor: Colors.transparent,
              body: buildShareCard(note),
            ),
          ),
        );

        // Render to PNG bytes
        final Uint8List pngBytes = await screenshotController.captureFromWidget(
          shareWidget,
          pixelRatio: 2.5,
          delay: const Duration(milliseconds: 20),
        );

        // ✅ Use your mixin to save & share
        await processAndSaveImage(pngBytes);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Couldn’t share note: $e')),
        );
      }
    }

    const List<Color> predefinedColors = [
      Color(0xFFC2DCFD),
      Color(0xFFFCFAD9),
      Color(0xFFFFD8F4),
      Color(0xFFF1DBF5),
      Color(0xFFFBF6AA),
      Color(0xFFD9E8FC),
      Color(0xFFB0E9CA),
      Color(0xFFFFDBE3),
    ];

    // search filtering
    final allNotes = noteData.getAllNotes();
    final q = query.value.trim().toLowerCase();
    final filteredNotes = q.isEmpty
        ? allNotes
        : allNotes.where((n) {
            final t = n.title.toLowerCase();
            final c = n.content.toLowerCase();
            return t.contains(q) || c.contains(q);
          }).toList();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          toolbarHeight: 100,
          flexibleSpace: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.only(top: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Gap(10),
                Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        text: '${DateFormat.y().format(DateTime.now())} ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Avenir',
                          color:
                              noteData.isDarkMode ? Colors.white : Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: DateFormat.MMMM().format(DateTime.now()),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Avenir',
                              color: noteData.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const Gap(10),
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: TextField(
                    onChanged: (value) => query.value = value,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(12),
                      hintText: 'Search for notes...',
                      hintStyle: const TextStyle(
                          color: Colors.grey, fontFamily: 'Avenir'),
                      fillColor: Colors.grey.shade300,
                      filled: true,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          splashColor: Colors.grey,
          backgroundColor: Colors.black,
          onPressed: createNewNote,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    child: DatePicker(
                      DateTime.now(),
                      height: 100,
                      width: 80,
                      initialSelectedDate: DateTime.now(),
                      selectionColor: Colors.black,
                      selectedTextColor: Colors.white,
                      dayTextStyle: TextStyle(
                        color:
                            noteData.isDarkMode ? Colors.white : Colors.black,
                        fontFamily: 'Avenir',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      monthTextStyle: TextStyle(
                        color:
                            noteData.isDarkMode ? Colors.white : Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Avenir',
                      ),
                      dateTextStyle: TextStyle(
                        color:
                            noteData.isDarkMode ? Colors.white : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Avenir',
                      ),
                    ),
                  ),
                  // notes grid
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: allNotes.isEmpty
                        ? const Center(child: Text("You have no notes yet"))
                        : filteredNotes.isEmpty
                            ? const Center(child: Text("No results"))
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredNotes.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                ),
                                itemBuilder: (context, index) {
                                  const predefinedColors = [
                                    Color(0xFFC2DCFD),
                                    Color(0xFFFCFAD9),
                                    Color(0xFFFFD8F4),
                                    Color(0xFFF1DBF5),
                                    Color(0xFFFBF6AA),
                                    Color(0xFFD9E8FC),
                                    Color(0xFFB0E9CA),
                                    Color(0xFFFFDBE3),
                                  ];
                                  final color = predefinedColors[
                                      index % predefinedColors.length];
                                  final note = filteredNotes[index];
                                  return PreviewCard(
                                    color: color,
                                    title: note.title,
                                    content: note.content,
                                    onTap: () => goToNotePage(note, false),
                                    onDelete: () => deleteNote(note),
                                    onShare: () => shareNote(note), // share
                                  );
                                },
                              ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
