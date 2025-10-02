import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:note_taker/home/data/models/note_data.dart';
import 'package:note_taker/home/data/models/note_model.dart';

// Riverpod provider for NoteData (ChangeNotifier)
final noteDataProvider = ChangeNotifierProvider<NoteData>((ref) {
  final data = NoteData();
  return data;
});

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // initialize notes once
    ref.listenManual<NoteData>(
      noteDataProvider,
      (_, __) {},
      fireImmediately: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = ref.read(noteDataProvider);
      if (data.getAllNotes().isEmpty) {
        // safe to call; will just load (your db impl decides)
        data.initializeNotes();
      }
    });

    final noteData = ref.watch(noteDataProvider);

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
      );
      goToNotePage(newNote, true);
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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 120,
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
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  IconButton(
                    icon: Icon(
                      noteData.isDarkMode
                          ? Icons.brightness_7
                          : Icons.brightness_4,
                      size: 24,
                    ),
                    onPressed: () {
                      ref.read(noteDataProvider).toggleTheme();
                    },
                  ),
                ],
              ),
              const Gap(10),
              SizedBox(
                height: 40,
                width: double.infinity,
                child: TextField(
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
                      color: noteData.isDarkMode ? Colors.white : Colors.black,
                      fontFamily: 'Avenir',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    monthTextStyle: TextStyle(
                      color: noteData.isDarkMode ? Colors.white : Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Avenir',
                    ),
                    dateTextStyle: TextStyle(
                      color: noteData.isDarkMode ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Avenir',
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: noteData.getAllNotes().isEmpty
                      ? const Center(
                          child: Text("You have no notes yet"),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: noteData.getAllNotes().length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            final color = predefinedColors[
                                index % predefinedColors.length];
                            final note = noteData.getAllNotes()[index];
                            return _PreviewCard(
                              color: color,
                              title: note.title,
                              content: note.content,
                              onTap: () => goToNotePage(note, false),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final Color color;
  final String title;
  final String content;
  final VoidCallback onTap;

  const _PreviewCard({
    required this.color,
    required this.title,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.isEmpty ? 'Untitled' : title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const Gap(8),
            Expanded(
              child: Text(
                content.isEmpty ? '...' : content,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditNotePage extends ConsumerStatefulWidget {
  final bool isNewNote;
  final NoteModel note;

  const EditNotePage({super.key, required this.isNewNote, required this.note});

  @override
  ConsumerState<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends ConsumerState<EditNotePage> {
  late final TextEditingController _title;
  late final TextEditingController _content;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.note.title);
    _content = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  void _save() {
    final data = ref.read(noteDataProvider);
    if (widget.isNewNote) {
      data.addNewNotes(
        NoteModel(
          id: widget.note.id,
          title: _title.text,
          content: _content.text,
        ),
      );
    } else {
      data.updateNote(widget.note, _title.text, _content.text);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNewNote ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: _content,
                decoration: const InputDecoration(
                  hintText: 'Start typing...',
                  border: InputBorder.none,
                ),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
