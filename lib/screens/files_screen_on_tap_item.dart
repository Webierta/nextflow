part of 'files_screen.dart';

extension _OnTapItem on _FilesScreenState {
  void onTapItem(CloudFile item) {
    if (item.isDirectory) {
      setState(() {
        paths.add(currentPath);
        currentPath = '$currentPath/${item.name}';
        paths.add(currentPath);
        //initFiles();
      });
      initFiles();
    } else {
      if (item.typeFile != null && item.typeFile!.startsWith('image/')) {
        previewImage(item);
      }
      if (item.typeFile != null &&
          item.typeFile!.startsWith('application/pdf')) {
        previewPdf(item);
      }
      if (item.typeFile != null && item.typeFile!.startsWith('text/plain')) {
        previewTxt(item);
      }
      if (item.typeFile != null && item.typeFile!.startsWith('text/markdown')) {
        previewMd(item);
      }
    }
  }

  Future<void> previewImage(CloudFile file) async {
    Uint8List? preview = file.preview ?? await getPreview(file);
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

  Future<void> previewTxt(CloudFile fileTxt) async {
    final pathFile = fileTxt.filePath(widget.cuenta.userName);
    if (pathFile == null) return;
    final txt = await nextcloudApi.readFile(pathFile);
    if (txt == null) return;
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => OpenFileScreen(
            file: fileTxt,
            cuenta: widget.cuenta,
            type: TypeOpenFile.txt,
            content: txt,
          ),
        ),
      );
    }
  }

  Future<void> previewMd(CloudFile fileMd) async {
    final pathFile = fileMd.filePath(widget.cuenta.userName);
    if (pathFile == null) return;
    final md = await nextcloudApi.readFile(pathFile);
    if (md == null) return;
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => OpenFileScreen(
            file: fileMd,
            cuenta: widget.cuenta,
            type: TypeOpenFile.md,
            content: md,
          ),
        ),
      );
    }
  }

  Future<void> previewPdf(CloudFile filePdf) async {
    try {
      final pathFile = filePdf.filePath(widget.cuenta.userName);
      if (pathFile == null) throw Error();
      final bytes = await nextcloudApi.getPdf(pathFile);
      if (bytes == null) throw Error();
      filePdf.preview = bytes;
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => OpenFileScreen(
              file: filePdf,
              cuenta: widget.cuenta,
              type: TypeOpenFile.pdf,
              content: bytes,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
