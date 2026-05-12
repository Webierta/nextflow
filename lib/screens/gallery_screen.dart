import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/cloud_file.dart';
import '../models/cuenta_nextcloud.dart';
import '../models/destino.dart';
import '../services/nextcloud_api/nextcloud_api.dart';
import '../styles/styles_app.dart';
import '../utils/format_dates.dart';
import '../widgets/bottom_bar_app.dart';
import '../widgets/cuenta_avatar.dart';
import '../widgets/open_dialog.dart';
import '../widgets/snackbar_manager.dart';
import 'open_file_screen.dart';

class GalleryScreen extends StatefulWidget {
  final CuentaNextcloud cuenta;
  final String pathGallery;

  const GalleryScreen({
    super.key,
    required this.cuenta,
    this.pathGallery = '/',
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late NextcloudApi nextcloudApi;
  late StreamSubscription<CloudFile> subscription;
  List<CloudFile> imagesPreview = [];
  bool isLoading = false;
  bool sortByAlpha = false;
  bool sortByDate = true;
  TextEditingController searchController = TextEditingController();
  double progress = 0;

  @override
  void initState() {
    nextcloudApi = NextcloudApi(cuenta: widget.cuenta);
    initGallery();
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    nextcloudApi.cancelToken.cancel();
    searchController.dispose();
    super.dispose();
  }

  /*void reset() {
    subscription.cancel();
    setState(() {
      isLoading = false;
      imagesPreview = [];
    });
  }*/

  void initGallery() {
    setState(() => isLoading = true);
    subscription = getPreview(widget.pathGallery).listen(
      (onData) {
        if (mounted) {
          setState(() => imagesPreview.add(onData));
        }
      },
      onDone: () {
        if (mounted) {
          setState(() => isLoading = false);
        }
      },
    );
  }

  Stream<CloudFile> getPreview(String path) async* {
    try {
      var files = await nextcloudApi.getFiles(
        path,
        onlyImg: true,
        depth: 'infinity',
      );
      if (files == null || files.isEmpty) return;
      for (var file in files) {
        final pathFile = file.filePath(widget.cuenta.userName);
        if (pathFile == null) continue;
        final fileId = await nextcloudApi.getFileId(pathFile);
        //final fileId = await nextcloudApi.getFileId('$path/${file.name}');
        if (fileId != null) {
          file.fileId = fileId;
          final preview = await nextcloudApi.fetchPreview(fileId);
          if (preview != null) {
            file.preview = preview;
            yield file;
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<CloudFile> getSearchImages() {
    return imagesPreview
        .where(
          (file) => file.name.toLowerCase().contains(
            searchController.text.toLowerCase(),
          ),
        )
        .toList();
  }

  void _onUploadProgress(double pro) {
    setState(() {
      progress = pro / 100;
      if (pro >= 100) {
        progress = 0;
      }
    });
  }

  Future<void> uploadImage() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
    );
    if (result == null) return;
    File file = File(result.files.single.path!);
    bool responseUpload = await nextcloudApi.uploadFile(
      file: file,
      remotePath: '/Photos/',
      onUploadProgress: _onUploadProgress,
    );
    if (responseUpload == true) {
      if (mounted) {
        SnackbarManager.show(
          context: context,
          msg: 'File uploaded successfully!',
        );
      }
      //initFiles();
      initGallery();
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

  @override
  Widget build(BuildContext context) {
    if (isLoading == false && imagesPreview.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: StylesApp.gradient(Theme.of(context).colorScheme),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            //backgroundColor: Colors.blue[900],
            title: Text('Gallery'),
            //title: TitleAppbar(cuenta: widget.cuenta, title: 'Gallery'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Icon(Icons.image_not_supported_outlined, size: 84),
                const SizedBox(height: 42),
                Text('No se han encontrado imágenes en el servidor'),
              ],
            ),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        gradient: StylesApp.gradient(Theme.of(context).colorScheme),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leadingWidth: 40,
          leading: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: CuentaAvatar(
              cuenta: widget.cuenta,
              size: 30,
              onlyAvatar: true,
            ),
          ),
          title: Row(
            children: [
              Text('Gallery'),
              //const SizedBox(width: 4),
              /*CircleAvatar(
                child: Text(
                  searchController.text.isEmpty
                      ? '${imagesPreview.length}'
                      : '${getSearchImages().length}',
                ),
              ),*/
              //Text('${getSearchImages().length}'),
            ],
          ),
          //backgroundColor: Colors.blue[900],
          /*leading: IconButton(
            onPressed: () {
              reset();
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back),
          ),*/
          //title: Text('Gallery'),
          //title: TitleAppbar(cuenta: widget.cuenta, title: 'Gallery'),
          actions: [
            /*if (searchController.text.isNotEmpty)
              FittedBox(
                child: InputChip(
                  avatar: CircleAvatar(
                    child: Text('${getSearchImages().length}'),
                  ),
                  label: Text(searchController.text),
                  onDeleted: () {
                    setState(() {
                      searchController.clear();
                    });
                  },
                ),
              ),*/
            IconButton(
              tooltip: 'Search image by name',
              onPressed: () async {
                searchController.clear();
                final search = await OpenDialog.inputName(
                  context: context,
                  title: 'Search in this folder',
                  icon: Icons.search,
                  controller: searchController,
                );
                if (search != null &&
                    search.trim().isNotEmpty &&
                    context.mounted) {
                  setState(() {
                    searchController.text = search;
                  });
                }
              },
              icon: Icon(Icons.search, size: 32, color: Colors.white),
            ),
            IconButton(
              tooltip: 'Sort by name',
              onPressed: () {
                setState(() {
                  imagesPreview.sort((a, b) => a.name.compareTo(b.name));
                });
              },
              icon: Icon(Icons.sort_by_alpha, size: 32, color: Colors.white),
            ),
            IconButton(
              tooltip: 'Sort by date',
              onPressed: () {
                setState(() {
                  imagesPreview.sort((a, b) {
                    final aDate = FormatDates.toDate(a.lastModified!);
                    final bDate = FormatDates.toDate(b.lastModified!);
                    return bDate.compareTo(aDate);
                  });
                });
              },
              icon: Icon(Icons.date_range, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 10),
          ],
          bottom: PreferredSize(
            //preferredSize: Size.fromHeight(20),
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Align(
              alignment: Alignment.topLeft,
              /*child: Padding(
                padding: const .only(left: 10, bottom: 6),
                child: Text(
                  '${imagesPreview.length} images in ${widget.pathGallery}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),*/
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                /*child: Row(
                  children: [
                    Text(
                      '${imagesPreview.length} images in ${widget.pathGallery}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),*/
                child: Row(
                  //mainAxisAlignment: .spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            maxRadius: 16,
                            //backgroundColor: Colors.white,
                            //foregroundColor: Colors.blue,
                            child: Text('${imagesPreview.length}'),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.pathGallery == '/'
                                ? 'All'
                                : ''
                                      'Home/${widget.pathGallery.substring(1)}',
                          ),
                        ],
                      ),
                    ),
                    if (searchController.text.isNotEmpty)
                      FittedBox(
                        child: InputChip(
                          avatar: CircleAvatar(
                            child: Text('${getSearchImages().length}'),
                          ),
                          label: Text(searchController.text),
                          onDeleted: () {
                            setState(() {
                              searchController.clear();
                            });
                          },
                        ),
                      ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
        //floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: BottomBarApp(
          cuenta: widget.cuenta,
          destino: Destino.gallery,
          funcion: uploadImage,
          //cancelToken: nextcloudApi.cancelToken,
        ),
        body: (isLoading == true && imagesPreview.isEmpty)
            ? Center(
                child: Transform.scale(
                  scale: 3,
                  child: CircularProgressIndicator(),
                ),
              )
            : Stack(
                children: [
                  LayoutBuilder(
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
                                Text(
                                  '${(progress * 100).toStringAsFixed(1)} %',
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      int columns = (constraints.maxWidth / 150).floor();
                      List<CloudFile> searchImages = imagesPreview;
                      if (searchController.text.isNotEmpty) {
                        searchImages = getSearchImages();
                      }
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 8.0,
                          crossAxisSpacing: 8.0,
                        ),
                        padding: EdgeInsets.all(12.0),
                        itemCount: searchImages.length,
                        itemBuilder: (context, index) {
                          var image = searchImages[index];
                          return Card(
                            color: Colors.white,
                            elevation: 4.0,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) => OpenFileScreen(
                                      file: image,
                                      cuenta: widget.cuenta,
                                      type: TypeOpenFile.image,
                                      content: image.preview,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: MemoryImage(image.preview!),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    const Radius.circular(10.0),
                                  ),
                                  border: BoxBorder.all(
                                    width: 0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  if (isLoading == true)
                    Center(
                      child: Transform.scale(
                        scale: 3,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
