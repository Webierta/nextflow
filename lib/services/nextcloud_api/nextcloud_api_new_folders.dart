part of 'nextcloud_api.dart';

extension NewFolders on NextcloudApi {
  Future<bool> createFolder(String folderPath) async {
    final url =
        '${cuenta.server}/remote.php/dav/files/${cuenta.userName}/$folderPath';
    Map<String, String> headers = {
      'Authorization': 'Basic $auth}',
      'OCS-APIRequest': 'true',
    };
    try {
      final response = await dio.request(
        url,
        options: Options(method: 'MKCOL', headers: headers),
        cancelToken: cancelToken,
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Error al crear carpeta: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Ignoramos error 405 (ya existe), lanzamos el resto
      if (e.response?.statusCode != 405) rethrow;
      return false;
    }
  }

  Future<void> createFolders({
    required List<String> destinos,
    void Function(int done, int total)? onProgress,
  }) async {
    final url = '${cuenta.server}/remote.php/dav/files/${cuenta.userName}/';
    Map<String, String> headers = {
      'Authorization': 'Basic $auth}',
      'OCS-APIRequest': 'true',
    };
    int done = 0;
    for (final destino in destinos) {
      final destination = url + destino; // encodeFull ??
      try {
        final response = await dio.request(
          destination,
          options: Options(method: 'MKCOL', headers: headers),
          cancelToken: cancelToken,
        );
        if (response.statusCode == 201) {
          done++;
          onProgress?.call(done, destinos.length);
        } else {
          throw Exception('Error al crear carpeta: ${response.statusCode}');
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 405) {
          done++;
          onProgress?.call(done, destinos.length);
        } else {
          debugPrint('❌ Error creando $destino: $e');
        }
      }
    }
  }
}
