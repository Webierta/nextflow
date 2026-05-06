import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/cloud_file.dart';
import '../models/cuenta_nextcloud.dart';
import '../models/destino.dart';
import '../models/shared_file.dart';
import '../services/nextcloud_api/nextcloud_api.dart';
import '../styles/styles_app.dart';
import '../utils/format_bytes.dart';
import '../widgets/bottom_bar_app.dart';
import '../widgets/cuenta_avatar.dart';
import '../widgets/snackbar_manager.dart';
import '../widgets/type_icon.dart';
import 'open_file_screen.dart';

class SharedScreen extends StatefulWidget {
  final CuentaNextcloud cuenta;

  const SharedScreen({super.key, required this.cuenta});

  @override
  State<SharedScreen> createState() => _SharedScreenState();
}

class _SharedScreenState extends State<SharedScreen> {
  late NextcloudApi nextcloudApi;
  Map<SharedFile, CloudFile> mapFiles = {};

  //late Future<List<SharedFile>?>? futureShared;

  @override
  void initState() {
    nextcloudApi = NextcloudApi(cuenta: widget.cuenta);
    //futureShared = initShared();
    super.initState();
  }

  /*initFile(SharedFile shared) async {
    var fileShared = await nextcloudApi.getFile(shared.sharedPath);
  }*/

  /*Future<List<SharedFile>?>? initShared() async {
    return await nextcloudApi.getShared();
  }

  Future<void> refreshData() async {
    setState(() {
      futureShared = initShared();
    });
    await futureShared;
  }*/

  void onTapShared(SharedFile shared) async {
    //print(shared.showInfo(widget.cuenta.userName));
    //final nextcloudApi = NextcloudApi(cuenta: widget.cuenta);
    //var fileShared = await nextcloudApi.getFile(shared.sharedPath);
    var fileShared =
        mapFiles[shared] ?? await nextcloudApi.getFile(shared.sharedPath);
    if (fileShared == null) return;
    if (shared.itemType == 'folder') {
      //print('ABRIR CARPETA');
    } else {
      if (fileShared.typeFile != null &&
          fileShared.typeFile!.startsWith('text/plain')) {
        previewTxt(fileShared);
      } else if (fileShared.typeFile != null &&
          fileShared.typeFile!.startsWith('text/markdown')) {
        previewMd(fileShared);
      } else if (fileShared.typeFile != null &&
          fileShared.typeFile!.startsWith('image/')) {
        previewImage(shared, fileShared);
      }
    }
  }

  Future<void> previewImage(SharedFile shared, CloudFile file) async {
    //Uint8List? preview = file.preview ?? await getPreview(file);
    Uint8List? preview = mapFiles[shared]?.preview ?? await getPreview(file);
    if (preview == null) return;
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => OpenFileScreen(
            file: file,
            cuenta: widget.cuenta,
            type: TypeOpenFile.image,
            content: preview,
          ),
        ),
      );
    }
  }

  Future<Uint8List?>? getPreview(CloudFile fileImage) async {
    final pathFile = fileImage.filePath(widget.cuenta.userName);
    if (pathFile == null) return null;
    final fileId = await nextcloudApi.getFileId(pathFile);
    if (fileId == null) return null;
    fileImage.fileId = fileId;
    final preview = await nextcloudApi.fetchPreview(fileId);
    if (preview == null) return null;
    fileImage.preview = preview;
    return fileImage.preview;
  }

  Future<void> previewTxt(CloudFile shared) async {
    final pathFile = shared.filePath(widget.cuenta.userName);
    if (pathFile == null) return;
    //final nextcloudApi = NextcloudApi(cuenta: widget.cuenta);
    final txt = await nextcloudApi.readFile(pathFile);
    if (txt == null) return;
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => OpenFileScreen(
            file: shared,
            cuenta: widget.cuenta,
            type: TypeOpenFile.txt,
            content: txt,
          ),
        ),
      );
    }
  }

  Future<void> previewMd(CloudFile shared) async {
    final pathFile = shared.filePath(widget.cuenta.userName);
    if (pathFile == null) return;
    //final nextcloudApi = NextcloudApi(cuenta: widget.cuenta);
    final md = await nextcloudApi.readFile(pathFile);
    if (md == null) return;
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => OpenFileScreen(
            file: shared,
            cuenta: widget.cuenta,
            type: TypeOpenFile.md,
            content: md,
          ),
        ),
      );
    }
  }

  Future<Uint8List?>? getPreviewShared(SharedFile shared) async {
    var fileShared = await nextcloudApi.getFile(shared.sharedPath);
    if (fileShared == null) return null;
    final pathFile = fileShared.filePath(widget.cuenta.userName);
    if (pathFile == null) return null;
    final fileId = await nextcloudApi.getFileId(pathFile);
    if (fileId == null) return null;
    fileShared.fileId = fileId;
    //print(fileId);
    final preview = await nextcloudApi.fetchPreview(fileId);
    if (preview == null) return null;
    fileShared.preview = preview;
    // SET STATE ??
    mapFiles[shared] = fileShared;
    return fileShared.preview;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: StylesApp.backgroundScreen(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leadingWidth: 40,
          leading: Padding(
            padding: const EdgeInsets.all(4.0),
            child: CuentaAvatar(
              cuenta: widget.cuenta,
              size: 30,
              onlyAvatar: true,
            ),
          ),
          title: Text('Shared files'),
          //title: TitleAppbar(cuenta: widget.cuenta, title: 'Shared Files'),
        ),
        /*floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Theme.of(context).colorScheme.primary,
          tooltip: 'Upload shared file',
          child: Icon(
            Icons.upload,
            size: 42,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),*/
        bottomNavigationBar: BottomBarApp(
          cuenta: widget.cuenta,
          destino: Destino.shared,
          //funcion: null,
        ),
        //floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        body: FutureBuilder<List<SharedFile>?>(
          future: nextcloudApi.getShared(),
          //future: futureShared,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: const CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              final files = snapshot.data!;
              return SingleChildScrollView(
                //physics: ScrollPhysics(),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: .fromLTRB(20, 20, 20, 60),
                child: ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: files.length,
                  separatorBuilder: (context, index) {
                    return Divider(
                      color: Colors.white54,
                      thickness: 0.2,
                      indent: 20,
                      endIndent: 20,
                    );
                  },
                  itemBuilder: (context, index) {
                    var item = files[index];
                    getPreviewShared(item);
                    return ListTile(
                      onTap: () => onTapShared(item),
                      titleAlignment: ListTileTitleAlignment.top,
                      leading: (item.mimeType.startsWith('image/'))
                          ? FutureBuilder(
                              future: getPreviewShared(item),
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
                              isDirectory: item.itemType == 'folder',
                              fileType: item.mimeType,
                            ),
                      title: Text(
                        item.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text('in ${item.path == '/' ? 'Home' : item.path}'),
                          FittedBox(
                            child: Row(
                              children: [
                                Text(FormatBytes.show(item.itemSize)),
                                Text(' - '),
                                Text(item.mimeType),
                              ],
                            ),
                          ),
                          if (item.sharedLink != null)
                            Text(
                              item.sharedLink!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          //if (item.sharedId != null) Text(item.sharedId!),
                        ],
                      ),
                      trailing: Wrap(
                        //mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: item.sharedLink == null
                                ? null
                                : () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: item.sharedLink!),
                                    );
                                    if (!context.mounted) return;
                                    SnackbarManager.show(
                                      context: context,
                                      msg: 'Link copiado al portapapeles',
                                    );
                                  },
                            tooltip: 'Copiar link al portapapeles',
                            icon: Icon(Icons.copy),
                          ),
                          IconButton(
                            onPressed: item.sharedLink == null
                                ? null
                                : () async {
                                    if (!await launchUrl(
                                      Uri.parse(item.sharedLink!),
                                      mode: LaunchMode.externalApplication,
                                    )) {
                                      //throw Exception('Could not launch ${item.sharedLink}',);
                                      if (!context.mounted) return;
                                      SnackbarManager.show(
                                        context: context,
                                        msg:
                                            'Could not launch ${item.sharedLink}',
                                        error: true,
                                      );
                                    }
                                  },
                            tooltip: 'Abrir link en el navegador',
                            icon: Icon(Icons.open_in_new),
                          ),
                          IconButton(
                            onPressed:
                                item.sharedId == null ||
                                    int.tryParse(item.sharedId!) == null
                                ? null
                                : () async {
                                    var noCompartir = await nextcloudApi
                                        .unshareFile(int.parse(item.sharedId!));
                                    if (!context.mounted) return;
                                    if (noCompartir == true) {
                                      setState(() {});
                                      //await nextcloudApi.getShared();
                                      //if (!context.mounted) return;
                                      SnackbarManager.show(
                                        context: context,
                                        msg:
                                            'El archivo ha dejado de ser compartido',
                                      );
                                    } else {
                                      SnackbarManager.show(
                                        context: context,
                                        msg: 'Error al dejar de compartir',
                                        error: true,
                                      );
                                    }
                                  },
                            tooltip: 'Dejar de compartir',
                            icon: Icon(Icons.link_off),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              //print(snapshot.error.toString());
              return Center(child: const Icon(Icons.error, size: 48));
            }
            return Center(child: const CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
