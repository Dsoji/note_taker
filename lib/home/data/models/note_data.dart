import 'package:flutter/material.dart';
import 'package:note_taker/core/data/db.dart';
import 'package:note_taker/home/data/models/note_model.dart';

class NoteData extends ChangeNotifier {
  // Color _currentColor = Colors.white;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Color get currentColor => _currentColor;
  //hive database
  final db = HiveDataBase();
  //list of notes
  List<NoteModel> allNotes = [
    NoteModel(
      id: 0,
      title: 'Like and Subscribe',
      content: 'Sample content',

      //   content:
      //       'A FREE way to support the channel is to give us a LIKE . It does not cost you but means a lot to us.\nIf you are new here please Subscribe',
    ),
    NoteModel(
      id: 1,
      title: 'Recipes to Try',
      content: 'Sample content',

      // content:
      //     '1. Chicken Alfredo\n2. Vegan chili\n3. Spaghetti carbonara\n4. Chocolate lava cake',
    ),
    NoteModel(
      id: 2,
      title: 'Books to Read',
      content: 'Sample content',

      // content:
      //     '1. To Kill a Mockingbird\n2. 1984\n3. The Great Gatsby\n4. The Catcher in the Rye',
    ),
  ];

  //initialise test
  void initializeNotes() {
    allNotes = db.loadNotes();
  }

  //get notes
  List<NoteModel> getAllNotes() {
    return allNotes;
  }

  //new notes
  void addNewNotes(NoteModel note) {
    allNotes.add(note);

    notifyListeners();
  }

  //update notes
  void updateNote(NoteModel note, String title, String content) {
    //scanning through list of notes
    for (int i = 0; i < allNotes.length; i++) {
      //find specific notes
      if (allNotes[i].id == note.id) {
        allNotes[i].title = title;
        allNotes[i].content = content;
      }
    }
    notifyListeners();
  }

  //delete notes
  void deleteNote(NoteModel note) {
    allNotes.remove(note);
    notifyListeners();
  }

  //color selection
}
