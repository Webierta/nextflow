import 'open_file.dart';

class Note extends OpenFile {
  final int id;
  final String title;
  final String content;
  final String? category;
  final bool favorite;
  final String internalPath;

  // Add other fields as needed

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.favorite,
    required this.internalPath,
    this.category,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      favorite: json['favorite'],
      internalPath: json['internalPath'],
      category: json['category'],
    );
  }

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