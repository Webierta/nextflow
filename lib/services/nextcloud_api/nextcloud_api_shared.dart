part of 'nextcloud_api.dart';

extension Shared on NextcloudApi {
  Future<List<SharedFile>?>? getShared() async {
    final url = '${cuenta.server}/ocs/v2.php/apps/files_sharing/api/v1/shares';
    Map<String, String> headers = {
      'Authorization': 'Basic $auth}',
      'OCS-APIRequest': 'true',
      'Accept': 'application/json',
    };
    dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));

    try {
      final response = await dio.get(
        url,
        options: Options(headers: headers, responseType: ResponseType.json),
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200) {
        var listData = response.data['ocs']['data'] as List;
        //print(listData);
        List<SharedFile> sharedFiles = listData
            .map((item) => SharedFile.fromJson(item))
            .toList();
        /*sharedFiles.sort(
          (a, b) =>
              a.sharedPath.toLowerCase().compareTo(b.sharedPath.toLowerCase()),
        );*/
        //return sharedFiles;
        final shareDir = sharedFiles
            .where((item) => item.itemType == 'folder')
            .toList();
        shareDir.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        final shareFiles = sharedFiles
            .where((item) => item.itemType != 'folder')
            .toList();
        shareFiles.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        return shareDir + shareFiles;
      } else {
        throw Exception('Error al obtener Shared: ${response.statusCode}');
      }
    } catch (e) {
      return null;
    }
  }

  Future<(bool, String)> shrareFile(
    String path, {
    int permissions = 1, // 1 = solo lectura, 3 = lectura y escritura
    int expireDays = 7, // Opcional: días hasta que el enlace expire
    String? password, // Opcional: contraseña para el enlace
  }) async {
    final url = '${cuenta.server}/ocs/v2.php/apps/files_sharing/api/v1/shares';
    Map<String, String> headers = {
      'Authorization': 'Basic $auth}',
      'OCS-APIRequest': 'true',
      'Accept': 'application/json',
    };
    try {
      final response = await dio.post(
        url,
        data: {
          'path': path,
          'shareType': 3, // 3 = enlace público
          'permissions': permissions,
          'password': ?password,
          if (expireDays > 0)
            'expireDate': DateTime.now()
                .add(Duration(days: expireDays))
                .toIso8601String(),
        },
        options: Options(headers: headers, responseType: ResponseType.json),
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        var sharedUrl = response.data['ocs']['data']['url'] as String?;
        if (sharedUrl != null) {
          return (true, sharedUrl);
        } else {
          throw Exception('Error al compartir archivo: NO LINK');
        }
      } else {
        throw Exception('Error al compartir archivo: ${response.statusCode}');
      }
    } catch (e) {
      //print('Error al compartir archivo: $e');
      return (false, '');
    }
  }

  Future<bool> unshareFile(int shareId, {int shareType = 3}) async {
    final url =
        '${cuenta.server}/ocs/v2.php/apps/files_sharing/api/v1/shares/$shareId';
    Map<String, String> headers = {
      'Authorization': 'Basic $auth}',
      'OCS-APIRequest': 'true',
    };
    try {
      final response = await dio.delete(
        url,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200) {
        //print('Compartición eliminada con éxito');
        return true;
      } else {
        //print('Error: ${response.data}');
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
