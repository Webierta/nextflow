import 'package:path/path.dart' as path_dart;

import 'open_file.dart';

class SharedFile extends OpenFile {
  final String sharedPath;
  final String itemType;
  final String mimeType;
  final int itemSize;
  final String? sharedLink;

  final String? sharedId;
  final int time;

  // "stime":1769207733,
  // "path":"/Notes/Finanzas/Finanzas.md",
  // "file_target":"/Finanzas.md",

  SharedFile({
    required this.sharedPath,
    required this.itemType,
    required this.mimeType,
    required this.itemSize,
    this.sharedLink,
    this.sharedId,
    required this.time,
  });

  // @override
  // ObjectOpenFile getType() => ObjectOpenFile.shared;

  String get name {
    //var lastSeparator = sharedPath.lastIndexOf('/');
    //return sharedPath.substring(lastSeparator + 1);
    return path_dart.basename(sharedPath);
  }

  String get path {
    return sharedPath.replaceAll(name, '');
  }

  factory SharedFile.fromJson(Map<String, dynamic> jsonData) {
    return SharedFile(
      sharedPath: jsonData['path'],
      itemType: jsonData['item_type'],
      mimeType: jsonData['mimetype'],
      itemSize: jsonData['item_size'],
      sharedLink: jsonData['url'] ?? jsonData['share_with_link'],
      sharedId: jsonData['id'] ?? 0,
      time: jsonData['stime'],
    );
  }

  @override
  String getName() => name;

  @override
  String? getPath(String userName) => path;

  @override
  Map<String, String> showInfo(String userName) {
    Map<String, String> detalles = {};
    detalles['Path'] = sharedPath;
    detalles['Type'] = itemType;
    detalles['MimeType'] = mimeType;
    detalles['Size'] = itemSize.toString();
    //detalles['Id'] = sharedId.toString();
    return detalles;
  }
}
