import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_dart;

import '../models/cloud_file.dart';
import '../models/cuenta_nextcloud.dart';
import '../services/nextcloud_api/nextcloud_api.dart';
import '../styles/styles_app.dart';
import '../utils/format_bytes.dart';
import '../utils/format_dates.dart';
import '../widgets/open_dialog.dart';
import '../widgets/snackbar_manager.dart';
import '../widgets/title_appbar.dart';
import '../widgets/type_icon.dart';
import 'gallery_screen.dart';
import 'open_file_screen.dart';

part 'files_screen_on_tap_item.dart';
part 'files_screen_on_tap_more.dart';

class FilesScreen extends StatefulWidget {
  final CuentaNextcloud cuenta;

  //final String pathFiles;
  final String? inputSearch;

  const FilesScreen({
    super.key,
    required this.cuenta,
    this.inputSearch,
    //this.pathFiles = '/',
  });

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  late NextcloudApi nextcloudApi;
  String currentPath = '/';
  List<String> paths = [];
  bool isLoading = false;
  bool isGridView = false;
  double progress = 0;
  TextEditingController renameController = TextEditingController();

  //List<CloudFile> directorios = [];
  String folderPathSelect = '/';
  TextEditingController folderController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  List<CloudFile> allFiles = [];
  String depth = '1';

  @override
  void initState() {
    nextcloudApi = NextcloudApi(cuenta: widget.cuenta);
    //resetFolderPathSelect();
    //currentPath = widget.pathFiles;
    if (widget.inputSearch != null) {
      depth = 'infinity';
      searchController.text = widget.inputSearch!;
    }
    initFiles(true);
    super.initState();
  }

  Future<void> initFiles([bool isInit = false]) async {
    setState(() {
      isLoading = true;
      if (isInit == false) {
        depth = '1';
        searchController.clear();
      }
    });
    allFiles = await nextcloudApi.getFiles(currentPath, depth: depth) ?? [];
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    renameController.dispose();
    folderController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _onUploadProgress(double pro) {
    setState(() {
      progress = pro / 100;
      if (pro >= 100) {
        progress = 0;
      }
    });
  }

  Future<void> uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    File file = File(result.files.single.path!);
    bool responseUpload = await nextcloudApi.uploadFile(
      file: file,
      remotePath: currentPath,
      onUploadProgress: _onUploadProgress,
    );
    if (responseUpload == true) {
      if (mounted) {
        SnackbarManager.show(
          context: context,
          msg: 'File uploaded successfully!',
        );
      }
      initFiles();
    } else {
      if (mounted) {
        SnackbarManager.show(
          context: context,
          msg: 'Upload failed',
          error: true,
        );
      }
    }
  }

  Future<void> addFolder() async {
    var folderName = await OpenDialog.inputName(
      context: context,
      title: 'Input folder name',
      icon: Icons.create_new_folder,
      controller: folderController,
    );
    if (folderName == null) return;
    folderController.clear();
    var newPath = '$currentPath/$folderName';
    var folderCreate = await nextcloudApi.createFolder(newPath);
    if (folderCreate == true && mounted) {
      initFiles();
      SnackbarManager.show(
        context: context,
        msg: 'Folder created successfully!',
      );
    } else if (folderCreate == false && mounted) {
      SnackbarManager.show(
        context: context,
        msg: 'Failed to create folder',
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: StylesApp.backgroundScreen(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: TitleAppbar(cuenta: widget.cuenta, title: 'Files'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 25, 10),
              child: depth == '1'
                  ? Row(
                      children: [
                        IconButton(
                          onPressed: currentPath == '/'
                              ? null
                              : () {
                                  setState(() {
                                    if (paths.isNotEmpty) {
                                      int indexCurrentPath = paths.indexOf(
                                        currentPath,
                                      );
                                      if (indexCurrentPath > 0) {
                                        currentPath =
                                            paths[indexCurrentPath - 1];
                                      }
                                      initFiles();
                                    }
                                  });
                                },
                          icon: Icon(
                            Icons.drive_folder_upload_rounded,
                            size: 32,
                          ),
                        ),
                        Text(
                          currentPath == '/'
                              ? 'Home'
                              : 'Home${currentPath.substring(1)}',
                          style: TextStyle(fontSize: 18),
                        ),
                        const Spacer(),
                        IconButton.filled(
                          onPressed: addFolder,
                          icon: Icon(Icons.create_new_folder),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const .only(left: 10),
                      child: Text(
                        'Searching: ${widget.inputSearch!}',
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
            ),
          ),
          actions: [
            if (depth == '1')
              SizedBox(
                width: 250,
                child: TextField(
                  controller: searchController,
                  onChanged: (value) => setState(() {
                    //depth = '1';
                  }),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hint: Text(
                      'Search in this folder',
                      maxLines: 1,
                      style: TextStyle(color: Colors.white30),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => searchController.clear());
                        //initFiles();
                      },
                      icon: Icon(Icons.clear),
                    ),
                  ),
                ),
              ),
            IconButton(
              onPressed: () async {},
              icon: Icon(isGridView ? Icons.grid_view : Icons.view_list),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                //onPressed: () => reset(),
                onPressed: () => initFiles(),
                icon: Icon(Icons.update),
              ),
            ),
          ],
        ),
        floatingActionButton: depth == '1'
            ? FloatingActionButton(
                onPressed: uploadFile,
                child: Icon(Icons.upload),
              )
            : null,
        body: (isLoading == true)
            ? Center(
                child: Transform.scale(
                  scale: 3,
                  child: CircularProgressIndicator(),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  if (progress > 0) {
                    return Center(
                      child: Padding(
                        padding: .symmetric(horizontal: 40),
                        child: Column(
                          mainAxisAlignment: .center,
                          children: [
                            Text('Progreso de subida de archivo'),
                            LinearProgressIndicator(value: progress),
                            Text('${(progress * 100).toStringAsFixed(1)} %'),
                          ],
                        ),
                      ),
                    );
                  }
                  List<CloudFile> searchFiles = allFiles;
                  if (searchController.text.isNotEmpty) {
                    searchFiles = allFiles
                        .where(
                          (file) => file.name.toLowerCase().contains(
                            searchController.text.toLowerCase(),
                          ),
                        )
                        .toList();
                  }
                  if (searchFiles.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: .center,
                        children: [
                          Icon(Icons.not_interested_rounded, size: 84),
                          const SizedBox(height: 42),
                          Text('No se han encontrado archivos en este lugar'),
                        ],
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    physics: ScrollPhysics(),
                    padding: .fromLTRB(20, 20, 20, 60),
                    child: ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: searchFiles.length,
                      separatorBuilder: (context, index) {
                        return Divider(
                          color: Colors.white54,
                          thickness: 0.2,
                          indent: 20,
                          endIndent: 20,
                        );
                      },
                      itemBuilder: (context, index) {
                        var item = searchFiles[index];
                        //_buildListTile();
                        return ListTile(
                          selected:
                              folderPathSelect == item.pathFile(currentPath),
                          selectedColor: Colors.blueAccent,
                          onTap: () => onTapItem(item),
                          leading:
                              (item.typeFile != null &&
                                  item.typeFile!.startsWith('image/'))
                              ? FutureBuilder(
                                  future: getPreview(item),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Image.memory(
                                        snapshot.data!,
                                        height: 48,
                                        width: 48,
                                        fit: BoxFit.fill,
                                      );
                                    }
                                    return Icon(Icons.image, size: 42);
                                  },
                                )
                              : TypeIcon(
                                  isDirectory: item.isDirectory,
                                  fileType: item.typeFile,
                                ),
                          title: Text(
                            item.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: .start,
                            children: [
                              /*if (searchController.text.isNotEmpty &&
                                  item.getDirName(widget.cuenta.userName) !=
                                      null)*/
                              if (depth == 'infinity' &&
                                  item.getDirName(widget.cuenta.userName) !=
                                      null)
                                Text(
                                  'in ${item.getDirName(widget.cuenta.userName)}',
                                ),
                              if (item.lastModified != null)
                                Text(FormatDates.show(item.lastModified!)),
                              if (item.size != null &&
                                  int.tryParse(item.size!) != null)
                                Text(FormatBytes.show(int.parse(item.size!))),
                              if (item.typeFile != null) Text(item.typeFile!),
                            ],
                          ),
                          trailing: IconButton(
                            onPressed: () => onTapMore(
                              context: context,
                              item: item,
                              path: currentPath,
                            ),
                            icon: Icon(Icons.more_vert),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
