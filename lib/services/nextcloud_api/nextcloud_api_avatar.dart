part of 'nextcloud_api.dart';

extension Avatar on NextcloudApi {
  Future<String?>? getUserId() async {
    String url = '${cuenta.server}/ocs/v2.php/cloud/user';
    Map<String, String> headers = {
      'Authorization': 'Basic $auth}',
      'OCS-APIRequest': 'true',
      'Accept': 'application/json',
    };
    try {
      final response = await dio.get(
        url,
        options: Options(headers: headers, responseType: ResponseType.json),
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200) {
        return response.data['ocs']['data']['id'];
      } else {
        throw Exception('Error al obtener userId: ${response.statusCode}');
      }
    } on DioException catch (_) {
      return null;
    }
  }

  Future<Uint8List?>? getAvatar(String userId, [int size = 64]) async {
    final url = '${cuenta.server}/index.php/avatar/$userId/$size';
    try {
      final response = await dio.get(
        url,
        options: Options(
          headers: {'Authorization': 'Basic $auth}', 'OCS-APIRequest': 'true'},
          responseType: ResponseType.bytes,
        ),
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      } else {
        throw Exception('Error al obtener avatar: ${response.statusCode}');
      }
    } on DioException catch (_) {
      return null;
    }
  }
}
