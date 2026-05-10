import 'open_file.dart';

class Note extends OpenFile {
  final int id;
  final String title; // luz
  final String content;
  final String? category;
  final bool favorite;
  final String internalPath; // /Notes/luz.txt

  final int modified; // 1625138132
  final bool isShared;

  // Add other fields as needed
  // "readonly":true,
  // "shareTypes":[],
  // "etag":d8573cb63b7db12e68afec8efc58dd78

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.favorite,
    required this.internalPath,
    this.category,

    required this.modified,
    required this.isShared,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      favorite: json['favorite'],
      internalPath: json['internalPath'],
      category: json['category'],
      modified: json['modified'],
      isShared: json['isShared'],
    );
  }

  // @override
  // ObjectOpenFile getType() => ObjectOpenFile.note;

  @override
  String getName() => title;

  @override
  String? getPath(String userName) => internalPath;

  @override
  Map<String, String> showInfo(String userName) {
    Map<String, String> detalles = {};
    detalles['Favorite'] = favorite.toString();
    if (category != null) {
      detalles['Category'] = category!;
    }
    return detalles;
  }
}
