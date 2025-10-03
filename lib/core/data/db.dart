import 'package:hive_flutter/hive_flutter.dart';
import 'package:note_taker/home/data/models/note_model.dart';

class HiveDataBase {
  //reference hive box
  final _myBox = Hive.box('note_database');
  //load notes
  List<NoteModel> loadNotes() {
    List<NoteModel> savedNotesFormatted = [];

    //if notes exist return list else return empty list
    if (_myBox.get("ALL_NOTES") != null) {
      List<dynamic> savedNotes = _myBox.get("ALL_NOTES");
      for (int i = 0; i < savedNotes.length; i++) {
        //create individual note
        NoteModel individualNote = NoteModel(
          id: savedNotes[i][0],
          title: savedNotes[i][1],
          content: savedNotes[i][2],
          modifiedTime:
              savedNotes[i].length > 3 ? savedNotes[i][3] : DateTime.now(),
          // color: savedNotes[i][3],
        );
        //add to list
        savedNotesFormatted.add(individualNote);
      }
    } else {
      //default first note

      savedNotesFormatted.add(
        NoteModel(
          id: 0,
          title: 'Sample note',
          content: 'Sample content',
          modifiedTime: DateTime.now(),
          // color: Colors.pink,
          //   content:
          //       'A FREE way to support the channel is to give us a LIKE . It does not cost you but means a lot to us.\nIf you are new here please Subscribe',
        ),
      );
    }
    return savedNotesFormatted;
  }

  //save notes
  void savedNotes(List<NoteModel> allNotes) {
    List<List<dynamic>> allNotesFormatted = [
      /*
      [
        [0, "First Note"],
        [1, "Second Note"],
        [2, "Third Note"],
        ..
      ]
      */
    ];

    //each notes have an id and text
    for (var note in allNotes) {
      int id = note.id;
      String title = note.title;
      String content = note.content;
      DateTime modifiedTime = note.modifiedTime;
      allNotesFormatted.add([id, title, content, modifiedTime]);
    }
    //store in hive
    _myBox.put("ALL_NOTES", allNotesFormatted);
  }
}
