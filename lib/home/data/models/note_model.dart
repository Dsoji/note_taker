class NoteModel {
  int id;
  String title;
  String content;
  DateTime modifiedTime;
  // Color color;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    DateTime? modifiedTime,
    // required this.color,
  }) : modifiedTime = modifiedTime ?? DateTime.now();
  // Map<String, dynamic> toMap() {
  //   return {
  //     "id": id,
  //     "title": title,
  //     "content": content,
  //     "modified_time": modified_time,
  //   };
  // }
}
