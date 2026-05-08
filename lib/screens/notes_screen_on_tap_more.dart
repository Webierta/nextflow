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
                      downloadNote(note);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.link),
                    title: Text('Share link'),
                    onTap: () {
                      Navigator.pop(contextBottomSheet);
                      sharedNote(note);
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.drive_file_rename_outline),
                    title: Text('Rename'),
                    subtitle: Text('Solo formatos .md y .txt'),
                    onTap: () {
                      Navigator.pop(contextBottomSheet);
                      renameNote(note);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.category),
                    title: Text('Change Category'),
                    onTap: () {
                      Navigator.pop(contextBottomSheet);
                      changeCategory(note);
                      //renameFile(item.pathFile(currentPath));
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                    onTap: () {
                      Navigator.pop(contextBottomSheet);
                      deleteNote(note);
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

  Future<void> downloadNote(Note note) async {
    String pathNote = note.internalPath;
    String nameNote = note.getName();
    //print(nameNote);
    //print(pathNote);
    bool download = await nextcloudApi.downloadFile(pathNote, nameNote);
    if (download == true) {
      initNotes();
    }
    if (mounted) {
      SnackbarManager.show(
        context: context,
        msg: download == true
            ? 'Note downloaded to downloads directory'
            : 'Error de descarga',
        error: !download,
      );
    }
  }

  Future<void> sharedNote(Note note) async {
    (bool, String) shareNote = await nextcloudApi.shrareFile(note.internalPath);
    if (shareNote.$1 == true) {
      await Clipboard.setData(ClipboardData(text: shareNote.$2));
      initNotes();
    }
    if (!mounted) return;
    SnackbarManager.show(
      context: context,
      msg: shareNote.$1 == true
          ? 'Shared link copied to clipboard'
          : 'Error de shared',
      error: !shareNote.$1,
    );
  }

  Future<void> renameNote(Note note) async {
    //var oldName = note.getName();
    var pathNote = note.internalPath;
    var oldName = path_dart.basename(pathNote);
    renameController.text = oldName;
    //var pathNote = note.internalPath;
    var basePath = path_dart.dirname(pathNote);
    var newName = await OpenDialog.inputName(
      context: context,
      title: 'Input new name',
      icon: Icons.edit,
      controller: renameController,
    );
    if (newName == null) return;
    var newPath = '$basePath/$newName';
    var noteRename = await nextcloudApi.reMoveFile(
      oldPath: pathNote,
      newPath: newPath,
    );
    if (noteRename == true && mounted) {
      initNotes();
      SnackbarManager.show(context: context, msg: 'Note renamed successfully!');
    } else if (noteRename == false && mounted) {
      SnackbarManager.show(
        context: context,
        msg: 'Failed to rename note',
        error: true,
      );
    }
  }

  Future<void> changeCategory(Note note) async {
    var newName = await OpenDialog.inputName(
      context: context,
      title: 'Input Category Name',
      icon: Icons.edit,
      controller: renameController,
    );
    if (newName == null) return;
    final update = await nextcloudApi.updateNote(
      id: note.id,
      category: newName,
    );
    if (update == true && mounted) {
      initNotes();
      SnackbarManager.show(
        context: context,
        msg: 'Category changed successfully!',
      );
    } else if (update == false && mounted) {
      SnackbarManager.show(
        context: context,
        msg: 'Failed to changed category',
        error: true,
      );
    }
  }

  Future<void> deleteNote(Note note) async {
    final confirmation = await OpenDialog.confirm(
      context: context,
      title: 'Confirmación requerida',
      content: Text('Elimina esta nota:\n${note.getName()}'),
    );
    if (confirmation == true) {
      var deleteNote = await nextcloudApi.deleteFile(note.internalPath);
      if (deleteNote == true && mounted) {
        initNotes();
        SnackbarManager.show(context: context, msg: 'Note deleted');
      } else if (deleteNote != true && mounted) {
        SnackbarManager.show(context: context, msg: 'Error');
      }
    }
  }
}
