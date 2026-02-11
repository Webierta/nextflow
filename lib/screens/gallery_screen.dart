import 'dart:async';

import 'package:flutter/material.dart';

import '../models/cloud_file.dart';
import '../models/cuenta_nextcloud.dart';
import '../services/nextcloud_api/nextcloud_api.dart';
import '../styles/styles_app.dart';
import '../utils/format_dates.dart';
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

  @override
  void initState() {
    nextcloudApi = NextcloudApi(cuenta: widget.cuenta);
    initGallery();
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    searchController.dispose();
    super.dispose();
  }

  void reset() {
    subscription.cancel();
    setState(() {
      isLoading = false;
      imagesPreview = [];
    });
  }

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
            //backgroundColor: Colors.blue[900],
            title: Text('Gallery'),
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
          //backgroundColor: Colors.blue[900],
          leading: IconButton(
            onPressed: () {
              reset();
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back),
          ),
          title: Text('Gallery'),
          actions: [
            SizedBox(
              width: 200,
              child: TextField(
                controller: searchController,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => searchController.clear());
                    },
                    icon: Icon(Icons.clear),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  imagesPreview.sort((a, b) => a.name.compareTo(b.name));
                });
              },
              icon: Icon(Icons.sort_by_alpha, color: Colors.white),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  imagesPreview.sort((a, b) {
                    final aDate = FormatDates.toDate(a.lastModified!);
                    final bDate = FormatDates.toDate(b.lastModified!);
                    return bDate.compareTo(aDate);
                  });
                });
              },
              icon: Icon(Icons.date_range, color: Colors.white),
            ),
            const SizedBox(width: 10),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(20),
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const .only(left: 70, bottom: 6),
                child: Text(
                  '${imagesPreview.length} images in ${widget.pathGallery}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
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
                      int columns = (constraints.maxWidth / 150).floor();
                      List<CloudFile> searchImages = imagesPreview;
                      if (searchController.text.isNotEmpty) {
                        searchImages = imagesPreview
                            .where(
                              (file) => file.name.toLowerCase().contains(
                                searchController.text.toLowerCase(),
                              ),
                            )
                            .toList();
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
