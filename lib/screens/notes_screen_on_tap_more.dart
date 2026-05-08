part of 'notes_screen.dart';

extension _OnTapMore on _NotesScreenState {
  void onTapMore({
    required BuildContext context,
    required Note note,
    //required String path,
  }) {
    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: false,
      scrollControlDisabledMaxHeightRatio: 0.7,
      barrierColor: Colors.white70,
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      context: context,
      constraints: BoxConstraints(maxWidth: double.infinity),
      builder: (BuildContext contextBottomSheet) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: ListView(
            children: [
              Center(child: Text(note.title, style: TextStyle(fontSize: 22))),
              Divider(),
              Column(
                mainAxisSize: .min,
                children: [
                  ListTile(
                    leading: Icon(Icons.download),
                    title: Text('Download'),
                    onTap: () {
                      Navigator.pop(contextBottomSheet);
                      //downloadFile(item);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.link),
                    title: Text('Share link'),
                    onTap: () {
                      Navigator.pop(contextBottomSheet);
                      //sharedFile(item);
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.drive_file_rename_outline),
                    title: Text('Rename'),
                    onTap: () {
                      Navigator.pop(contextBottomSheet);
                      //renameFile(item.pathFile(currentPath));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.category),
                    title: Text('Category'),
                    onTap: () {
                      Navigator.pop(contextBottomSheet);
                      //renameFile(item.pathFile(currentPath));
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                    onTap: () {
                      Navigator.pop(contextBottomSheet);
                      //deleteFile(item.pathFile(currentPath));
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
