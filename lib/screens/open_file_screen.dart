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

class OpenFileScreen extends StatefulWidget {
  final OpenFile file;
  final CuentaNextcloud cuenta;
  final dynamic content;
  final TypeOpenFile type;
  final String? category;
  final int? noteId;

  const OpenFileScreen({
    super.key,
    required this.file,
    required this.cuenta,
    required this.content,
    required this.type,
    this.category,
    this.noteId,
  });

  @override
  State<OpenFileScreen> createState() => _OpenFileScreenState();
}

class _OpenFileScreenState extends State<OpenFileScreen> {
  TextEditingController controllerNote = TextEditingController();

  bool editMd = false;

  @override
  void initState() {
    controllerNote.text = widget.content;
    super.initState();
  }

  @override
  void dispose() {
    controllerNote.dispose();
    super.dispose();
  }

  void showInfo(BuildContext context) {
    showModalBottomSheet<void>(
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      context: context,
      builder: (BuildContext context) {
        final Map<String, String> detalles = widget.file.showInfo(
          widget.cuenta.userName,
        );
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
                    widget.file.getName(),
                    style: TextStyle(fontSize: 22),
                  ),
                ),
                if (widget.category != null &&
                    widget.category!.trim().isNotEmpty)
                  ListTile(
                    title: Text(widget.category!),
                    subtitle: Text('Category'),
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

  StatelessWidget buildBody() {
    if (editMd == true) {
      return BodyTxt(
        content: widget.content,
        controller: controllerNote,
        noteId: widget.noteId,
      );
    }

    return switch (widget.type) {
      TypeOpenFile.txt => BodyTxt(
        content: widget.content,
        controller: controllerNote,
        noteId: widget.noteId,
        //controller: widget.noteId != null ? controllerNote : null,
      ),
      TypeOpenFile.pdf => BodyPdf(content: widget.content),
      TypeOpenFile.md => BodyMd(content: widget.content),
      TypeOpenFile.image => BodyImage(content: widget.content),
    };
  }

  @override
  Widget build(BuildContext context) {
    /*Widget body = switch (widget.type) {
      TypeOpenFile.txt => BodyTxt(
        content: widget.content,
        controller: controllerNote,
        noteId: widget.noteId,
        //controller: widget.noteId != null ? controllerNote : null,
      ),
      TypeOpenFile.pdf => BodyPdf(content: widget.content),
      TypeOpenFile.md => BodyMd(content: widget.content),
      TypeOpenFile.image => BodyImage(content: widget.content),
    };*/

    return Container(
      decoration: BoxDecoration(
        gradient: StylesApp.gradient(Theme.of(context).colorScheme),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.file.getName()),
          actions: [
            if ((widget.noteId != null && widget.type == TypeOpenFile.txt) ||
                editMd == true)
              IconButton(
                onPressed: () async {
                  final nextcloudApi = NextcloudApi(cuenta: widget.cuenta);
                  bool updateNote = await nextcloudApi.updateNote(
                    id: widget.noteId!,
                    content: controllerNote.text,
                  );
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  if (updateNote == true) {
                    //initNotes();
                    SnackbarManager.show(
                      context: context,
                      msg: 'Note changed successfully!',
                    );
                  } else if (updateNote == false) {
                    SnackbarManager.show(
                      context: context,
                      msg: 'Failed to update note',
                      error: true,
                    );
                  }
                },
                icon: Icon(Icons.save, color: Colors.white),
              ),
            if (widget.noteId != null &&
                widget.type == TypeOpenFile.md &&
                editMd == false)
              IconButton(
                onPressed: () {
                  setState(() {
                    editMd = true;
                    /*body = BodyTxt(
                      content: widget.content,
                      controller: controllerNote,
                      noteId: widget.noteId,
                    );*/
                  });
                },
                icon: Icon(Icons.edit, color: Colors.white),
              ),
          ],
        ),
        //body: body,
        body: buildBody(),
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
                onPressed: () => downloadFile(
                  context: context,
                  cuenta: widget.cuenta,
                  file: widget.file,
                ),
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
  final TextEditingController? controller;
  final int? noteId;

  const BodyTxt({
    super.key,
    required this.content,
    this.controller,
    this.noteId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: .all(40),
      //child: SelectableText(content),
      //child: NoteEdit(content: content),
      child: TextField(
        controller: controller,
        //enabled: noteId != null,
        readOnly: noteId == null,
        maxLines: null,
        decoration: InputDecoration.collapsed(
          hintText: '',
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class BodyMd extends StatelessWidget {
  final String content;

  const BodyMd({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return MarkdownWidget(
      //data: content,
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
