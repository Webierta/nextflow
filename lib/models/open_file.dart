//enum ObjectOpenFile { cloudfile, shared, note }

abstract class OpenFile {
  String getName();

  String? getPath(String username);

  Map<String, String> showInfo(String username);

  //ObjectOpenFile getType();
}
