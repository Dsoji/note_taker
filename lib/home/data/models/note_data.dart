import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:note_taker/core/data/db.dart';
import 'package:note_taker/home/data/models/note_model.dart';

class NoteData extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _useSystemTheme = true;

  bool get isDarkMode => _isDarkMode;
  bool get useSystemTheme => _useSystemTheme;

  //hive database
  final db = HiveDataBase();

  NoteData() {
    _loadThemeSettings();
  }

  void _loadThemeSettings() {
    // Load theme settings from Hive
    final box = Hive.box('note_database');
    _isDarkMode = box.get('isDarkMode', defaultValue: false);
    _useSystemTheme = box.get('useSystemTheme', defaultValue: true);

    // If using system theme, check system brightness
    if (_useSystemTheme) {
      _isDarkMode =
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark;
    }
  }

  void _saveThemeSettings() {
    final box = Hive.box('note_database');
    box.put('isDarkMode', _isDarkMode);
    box.put('useSystemTheme', _useSystemTheme);
  }

  void toggleTheme() {
    _useSystemTheme = false;
    _isDarkMode = !_isDarkMode;
    _saveThemeSettings();
    notifyListeners();
  }

  void setSystemTheme() {
    _useSystemTheme = true;
    _isDarkMode =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    _saveThemeSettings();
    notifyListeners();
  }

  void setDarkMode(bool isDark) {
    _useSystemTheme = false;
    _isDarkMode = isDark;
    _saveThemeSettings();
    notifyListeners();
  }

  //list of notes
  List<NoteModel> allNotes = [
    NoteModel(
      id: 0,
      title: 'Like and Subscribe',
      content: 'Sample content',
      modifiedTime: DateTime.now(),
    ),
    NoteModel(
      id: 1,
      title: 'Recipes to Try',
      content: 'Sample content',
      modifiedTime: DateTime.now(),
    ),
    NoteModel(
      id: 2,
      title: 'Books to Read',
      content: 'Sample content',
      modifiedTime: DateTime.now(),
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
    db.savedNotes(allNotes);
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
        allNotes[i].modifiedTime = DateTime.now();
      }
    }
    db.savedNotes(allNotes);
    notifyListeners();
  }

  //delete notes
  void deleteNote(NoteModel note) {
    allNotes.remove(note);
    db.savedNotes(allNotes);
    notifyListeners();
  }
}
