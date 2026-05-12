part of 'nextcloud_api.dart';

extension MoveDelete on NextcloudApi {
  Future<bool> reMoveFile({
    required String oldPath,
    required String newPath,
  }) async {
    final baseUrl = '${cuenta.server}/remote.php/dav/files/${cuenta.userName}';
    final url = '$baseUrl/$oldPath';
    final destination = '$baseUrl/$newPath';
    try {
      final response = await dio.request(
        url,
        options: Options(
          method: 'MOVE',
          headers: {
            'Authorization': 'Basic $auth}',
            'Destination': destination,
            'Overwrite': 'T',
          },
        ),
        cancelToken: cancelToken,
      );
      if (response.statusCode == 201 || response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } on DioException catch (_) {
      return false;
    }
  }

  Future<bool> deleteFile(String remotePath) async {
    final url =
        '${cuenta.server}/remote.php/dav/files/${cuenta.userName}/$remotePath';
    try {
      final response = await dio.delete(
        url,
        options: Options(headers: {'Authorization': 'Basic $auth}'}),
        cancelToken: cancelToken,
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } on DioException catch (_) {
      return false;
    }
  }
}
