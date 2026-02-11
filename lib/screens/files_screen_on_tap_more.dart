part of 'files_screen.dart';

extension _OnTapMore on _FilesScreenState {
  void onTapMore({
    required BuildContext context,
    required CloudFile item,
    required String path,
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
            //shrinkWrap: true,
            children: [
              Center(child: Text(item.name, style: TextStyle(fontSize: 22))),
              Divider(),
              Column(
                mainAxisSize: .min,
                children: [
                  ListTile(
                    leading: Icon(Icons.download),
                    title: Text('Download'),
                    onTap: () {
                      Navigator.pop(contextBottomSheet);
                      downloadFile(item);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.drive_file_rename_outline),
                    title: Text('Rename'),
                    onTap: () {
                      Navigator.pop(contextBottomSheet);
                      renameFile(item.pathFile(currentPath));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.move_down),
                    title: Text('Move'),
                    onTap: () {
                      Navigator.pop(contextBottomSheet);
                      moveFile(item.pathFile(currentPath));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.copy),
                    title: Text('Copy'),
                    onTap: () {
                      Navigator.pop(contextBottomSheet);
                      //moveCopyFile(item.pathFile(currentPath), OnFile.copy);
                      if (item.isDirectory) {
                        copyFolder(pathSource: item.pathFile(currentPath));
                      } else {
                        copyFile(pathSource: item.pathFile(currentPath));
                      }
                    },
                  ),
                  if (item.isDirectory) ...[
                    ListTile(
                      leading:
                          //folderPathSelect == '${widget.cuenta.server}${item.href}'
                          folderPathSelect == item.pathFile(currentPath)
                          ? Icon(Icons.check_box)
                          : Icon(Icons.check_box_outline_blank),
                      title:
                          //folderPathSelect == '${widget.cuenta.server}${item.href}'
                          folderPathSelect == item.pathFile(currentPath)
                          ? Text('Unselect as the destination to move or copy')
                          : Text('Select as the destination to move or copy'),
                      onTap: () {
                        Navigator.pop(contextBottomSheet);
                        //final folderItem = '${widget.cuenta.server}${item.href}';
                        final folderItem = item.pathFile(currentPath);
                        if (folderPathSelect == folderItem) {
                          //resetFolderPathSelect();
                          setState(() => folderPathSelect = '/');
                        } else {
                          setState(() {
                            folderPathSelect = item.pathFile(currentPath);
                            //folderPathSelect = '${widget.cuenta.server}${item.href}';
                          });
                        }
                      },
                    ),
                  ],
                  if (item.isDirectory)
                    ListTile(
                      leading: Icon(Icons.sync),
                      title: Text('Synchronize'),
                      onTap: () {
                        Navigator.pop(contextBottomSheet);
                      },
                    ),
                  if (item.isDirectory)
                    ListTile(
                      leading: Icon(Icons.photo_library_outlined),
                      title: Text('View content in Gallery'),
                      onTap: () {
                        Navigator.pop(contextBottomSheet);
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => GalleryScreen(
                              cuenta: widget.cuenta,
                              pathGallery: item.pathFile(currentPath),
                            ),
                          ),
                        );
                      },
                    ),
                  ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                    onTap: () {
                      Navigator.pop(contextBottomSheet);
                      deleteFile(item.pathFile(currentPath));
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

  Future<void> downloadFile(CloudFile file) async {
    //var path = '${currentPath.substring(1)}/${item.name}';
    String path = '$currentPath/${file.name}';
    bool download = await nextcloudApi.downloadFile(path, file.name);
    if (download == true) {
      initFiles();
    }
    if (mounted) {
      SnackbarManager.show(
        context: context,
        msg: download == true ? 'File downloaded' : 'Error de descarga',
        error: !download,
      );
    }
  }

  Future<void> renameFile(String oldPath) async {
    var oldName = path_dart.basename(oldPath);
    renameController.text = oldName;
    var basePath = path_dart.dirname(oldPath);
    //decoration: InputDecoration(label: Text(oldName)),
    var newName = await OpenDialog.inputName(
      context: context,
      title: 'Input new name',
      icon: Icons.edit,
      controller: renameController,
    );
    if (newName == null) return;
    var newPath = '$basePath/$newName';
    var fileRename = await nextcloudApi.reMoveFile(
      oldPath: oldPath,
      newPath: newPath,
    );
    if (fileRename == true && mounted) {
      initFiles();
      SnackbarManager.show(context: context, msg: 'File renamed successfully!');
    } else if (fileRename == false && mounted) {
      SnackbarManager.show(
        context: context,
        msg: 'Failed to rename file',
        error: true,
      );
    }
  }

  Future<void> moveFile(String path) async {
    var fileName = path_dart.basename(path);
    //var basePath = path_dart.dirname(path);
    final confirmation = await OpenDialog.confirm(
      context: context,
      title: 'Mover Archivo',
      content: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text('Archivo: $fileName'),
          const SizedBox(height: 20),
          Text('Destino : $folderPathSelect/'),
        ],
      ),
    );
    if (confirmation == true) {
      var returnApi = await nextcloudApi.reMoveFile(
        oldPath: path,
        newPath: '$folderPathSelect/$fileName',
      );
      if (returnApi == true && mounted) {
        initFiles();
        SnackbarManager.show(context: context, msg: 'File moved');
      } else if (returnApi == false && mounted) {
        SnackbarManager.show(
          context: context,
          msg: 'Failed to move file',
          error: true,
        );
      }
    }
  }

  Future<void> copyFile({required String pathSource}) async {
    var fileName = path_dart.basename(pathSource);
    final confirmation = await OpenDialog.confirm(
      context: context,
      title: 'Copiar Archivo',
      content: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text('Archivo: $fileName'),
          const SizedBox(height: 20),
          Text('Destino : $folderPathSelect/'),
          const SizedBox(height: 20),
          Text(
            'Si en destino existe un archivo con el mismo nombre, '
            'se sobreescribirá.',
          ),
        ],
      ),
    );
    if (confirmation == true) {
      var returnApi = await nextcloudApi.copyFile(
        pathSource: Uri.decodeFull(pathSource),
        pathDestino: '$folderPathSelect/$fileName',
      );
      if (returnApi == true && mounted) {
        initFiles();
        SnackbarManager.show(context: context, msg: 'File copied');
      } else if (returnApi == false && mounted) {
        SnackbarManager.show(
          context: context,
          msg: 'Failed to copy file',
          error: true,
        );
      }
    }
  }

  Future<void> copyFolder({required String pathSource}) async {
    var fileName = path_dart.basename(pathSource);
    final confirmation = await OpenDialog.confirm(
      context: context,
      title: 'Copiar Directorio',
      content: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text('Carpeta: $fileName'),
          const SizedBox(height: 20),
          Text('Destino : $folderPathSelect/'),
          const SizedBox(height: 20),
          Text(
            'Si en destino existe un archivo con el mismo nombre, '
            'se sobreescribirá.',
          ),
        ],
      ),
    );
    if (confirmation == true) {
      final allFiles = await nextcloudApi.getFiles(
        pathSource,
        depth: 'infinity',
      );
      if (allFiles == null) return;
      var pathDestino = '$folderPathSelect/$fileName';
      //print('SOURCE: ' + pathSource);
      //print('DESTINO: ' + pathDestino);
      await nextcloudApi.createFolder(pathDestino);
      List<String> destinosFolder = [];
      List<CopyJob> copyJobs = [];
      for (var file in allFiles) {
        if (file.isDirectory) {
          var path = file.filePath(widget.cuenta.userName)!;
          path = Uri.decodeFull(path);
          var dir = path.substring(path.indexOf(fileName));
          var destino = '$folderPathSelect/$dir';
          destinosFolder.add(destino);
        } else {
          var path = file.filePath(widget.cuenta.userName)!;
          path = Uri.decodeFull(path);
          var dir = path.substring(path.indexOf(fileName));
          var destino = '$folderPathSelect/$dir';
          copyJobs.add(CopyJob(path, destino));
        }
      }

      bool createFolders = false;
      await nextcloudApi.createFolders(
        destinos: destinosFolder,
        onProgress: (nFolder, total) {
          if (nFolder == destinosFolder.length) {
            createFolders = true;
          }
        },
      );
      if (createFolders == false) return;
      bool copyFiles = false;
      await nextcloudApi.copyFolder(
        copyJobs: copyJobs,
        onProgress: (nJob, total) {
          if (nJob == copyJobs.length) {
            copyFiles = true;
          }
        },
      );
      if (copyFiles == true && mounted) {
        initFiles();
        SnackbarManager.show(context: context, msg: 'Files copied!');
      } else if (copyFiles == false && mounted) {
        SnackbarManager.show(
          context: context,
          msg: 'Error files copy!',
          error: true,
        );
      }
    }
  }

  Future<void> deleteFile(String remotePath) async {
    final confirmation = await OpenDialog.confirm(
      context: context,
      title: 'Confirmación requerida',
      content: Text('Elimina este archivo:\n$remotePath'),
    );
    if (confirmation == true) {
      var deleteFile = await nextcloudApi.deleteFile(remotePath);
      if (deleteFile == true && mounted) {
        initFiles();
        SnackbarManager.show(context: context, msg: 'File deleted');
      } else if (deleteFile != true && mounted) {
        SnackbarManager.show(context: context, msg: 'Error');
      }
    }
  }
}
