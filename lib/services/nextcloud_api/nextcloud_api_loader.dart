part of 'nextcloud_api.dart';

extension Loader on NextcloudApi {
  Future<bool> downloadFile(String path, String name) async {
    final url =
        '${cuenta.server}/remote.php/dav/files/${cuenta.userName}/$path';
    Map<String, String> headers = {
      'Authorization': 'Basic $auth}',
      'Depth': '1',
      'Content-Type': 'application/xml; charset="utf-8"',
    };
    try {
      final response = await dio.get(
        url,
        options: Options(
          method: 'PROPFIND',
          headers: headers,
          responseType: ResponseType.bytes,
        ),
      );
      if (response.statusCode == 200) {
        final Directory? downloadsDir = await getDownloadsDirectory();
        if (downloadsDir == null) {
          throw Exception('Error en carpeta de descargas');
        }
        final file = File('${downloadsDir.path}/$name');
        await file.writeAsBytes(response.data);
        return true;
      } else {
        throw Exception('Error al descargar archivo: ${response.statusCode}');
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> uploadFile({
    required File file,
    required String remotePath,
    Function(double)? onUploadProgress,
  }) async {
    String fileName = path_dart.basename(file.path);
    final url =
        '${cuenta.server}/remote.php/dav/files/${cuenta.userName}/$remotePath/$fileName';
    try {
      final bytes = await file.readAsBytes();
      Response response = await dio.put(
        url,
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: 'Basic $auth',
            HttpHeaders.contentLengthHeader: bytes.length,
            HttpHeaders.contentTypeHeader: ContentType.json.toString(),
          },
        ),
        data: Stream.fromIterable(bytes.map((e) => [e])),
        onSendProgress: (int sent, int total) {
          if (total > 0) {
            final double progress = (sent / total * 100);
            onUploadProgress?.call(progress);
          }
        },
      );
      if (response.statusCode == 201 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      return false;
    }
  }
}
