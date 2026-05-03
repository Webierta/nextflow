import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:printing/printing.dart';

import '../models/cuenta_nextcloud.dart';
import '../models/open_file.dart';
import '../services/nextcloud_api/nextcloud_api.dart';
import '../styles/styles_app.dart';
import '../widgets/snackbar_manager.dart';

enum TypeOpenFile { txt, pdf, md, image }

class OpenFileScreen extends StatelessWidget {
  final OpenFile file;
  final CuentaNextcloud cuenta;
  final dynamic content;
  final TypeOpenFile type;

  const OpenFileScreen({
    super.key,
    required this.file,
    required this.cuenta,
    required this.content,
    required this.type,
  });

  void showInfo(BuildContext context) {
    showModalBottomSheet<void>(
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      context: context,
      builder: (BuildContext context) {
        final Map<String, String> detalles = file.showInfo(cuenta.userName);
        return Container(
          padding: const EdgeInsets.all(20),
          //height: 200,
          width: double.infinity,
          child: SingleChildScrollView(
            padding: .only(bottom: 40),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: .start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    'Name: ${file.getName()}',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
                if (detalles.isNotEmpty)
                  for (String key in detalles.keys)
                    ListTile(title: Text(detalles[key]!), subtitle: Text(key)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> downloadFile({
    required BuildContext context,
    required OpenFile file,
    required CuentaNextcloud cuenta,
  }) async {
    String? path = file.getPath(cuenta.userName);
    if (path == null) return;
    final nextcloudApi = NextcloudApi(cuenta: cuenta);
    bool download = await nextcloudApi.downloadFile(path, file.getName());
    if (context.mounted) {
      SnackbarManager.show(
        context: context,
        msg: download == true ? 'File downloaded' : 'Error de descarga',
        error: !download,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body = switch (type) {
      TypeOpenFile.txt => BodyTxt(content: content),
      TypeOpenFile.pdf => BodyPdf(content: content),
      TypeOpenFile.md => BodyMd(content: content),
      TypeOpenFile.image => BodyImage(content: content),
    };

    return Container(
      decoration: BoxDecoration(
        gradient: StylesApp.gradient(Theme.of(context).colorScheme),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          /*leading: IconButton(
            onPressed: () {
              if (context.mounted) {
                Navigator.pop(context);
                */
          /*Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => FilesScreen(cuenta: cuenta),
                  ),
                );*/
          /*
              }
            },
            icon: Icon(Icons.arrow_back),
          ),*/
          title: Text(file.getName()),
        ),
        body: body,
        bottomNavigationBar: BottomAppBar(
          height: 45,
          color: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.only(left: 14),
          child: Row(
            children: [
              IconButton(
                onPressed: () => showInfo(context),
                icon: const Icon(Icons.info),
              ),
              IconButton(
                onPressed: () =>
                    downloadFile(context: context, cuenta: cuenta, file: file),
                icon: Icon(Icons.download),
              ),
              IconButton(
                onPressed: () {
                  //shareFile();
                },
                icon: Icon(Icons.share),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BodyTxt extends StatelessWidget {
  final String content;

  const BodyTxt({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: .all(40), child: Text(content));
  }
}

class BodyMd extends StatelessWidget {
  final String content;

  const BodyMd({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return MarkdownWidget(
      data: content,
      padding: .all(40),
      config: MarkdownConfig(
        configs: [
          PreConfig.darkConfig,
          LinkConfig(style: TextStyle(color: Colors.yellow)),
          CodeConfig(
            style: TextStyle(color: Colors.black, backgroundColor: Colors.grey),
          ),
          ListConfig(marginBottom: 0),
          BlockquoteConfig(textColor: Colors.white54),
        ],
      ),
    );
  }
}

class BodyPdf extends StatelessWidget {
  final Uint8List content;

  const BodyPdf({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return PdfPreview(
      allowPrinting: false,
      allowSharing: false,
      canChangePageFormat: false,
      canChangeOrientation: false,
      canDebug: false,
      build: (format) => content,
    );
  }
}

class BodyImage extends StatelessWidget {
  final Uint8List content;

  const BodyImage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Center(child: Image.memory(content));
  }
}
