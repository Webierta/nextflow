import 'dart:typed_data';

import 'package:path/path.dart' as path_dart;

import '../utils/format_bytes.dart';
import '../utils/format_dates.dart';
import 'open_file.dart';

class CloudFile extends OpenFile {
  final String name;
  final bool isDirectory;
  final String? size;
  final String? lastModified;
  final String? typeFile;

  final String? href;
  int? fileId;
  Uint8List? preview;

  CloudFile({
    required this.name,
    required this.isDirectory,
    this.size,
    this.lastModified,
    this.typeFile,
    this.href,
    this.fileId,
    this.preview,
  });

  // @override
  // ObjectOpenFile getType() => ObjectOpenFile.cloudfile;

  String pathFile(String currentPath) {
    return '${currentPath.substring(1)}/$name';
    //return '$currentPath/$name';
  }

  //'/remote.php/dav/files/${cuenta.userName}';
  String? filePath(String userName) {
    if (href == null) return null;
    String base = '/remote.php/dav/files/$userName';
    return href!.replaceAll(base, '');
  }

  String? getDirName(String userName) {
    if (filePath(userName) == null) return null;
    var dirName = path_dart.dirname(filePath(userName)!);
    dirName = dirName.replaceFirst('/', 'Home/');
    dirName = dirName.replaceAll('//', '/');
    //final decoded = Uri.decodeComponent(dirName);
    //return decoded;
    try {
      return Uri.decodeComponent(dirName);
    } catch (_) {
      return dirName.replaceAll('%20', ' ');
    }
    //return dirName;
  }

  @override
  String getName() => name;

  @override
  String? getPath(String userName) => filePath(userName);

  @override
  Map<String, String> showInfo(String userName) {
    Map<String, String> detalles = {};
    if (typeFile != null) {
      detalles['Type File'] = typeFile!;
    }
    if (size != null) {
      detalles['Size'] = FormatBytes.show(int.parse(size!));
    }
    if (lastModified != null) {
      detalles['Last Modified'] = FormatDates.show(lastModified!);
      //detalles['Last Modified'] = lastModified!;
    }
    if (getDirName(userName) != null) {
      detalles['Path'] = getDirName(userName)!;
    }
    return detalles;
  }
}
