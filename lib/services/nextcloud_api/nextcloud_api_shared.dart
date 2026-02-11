part of 'nextcloud_api.dart';

extension Shared on NextcloudApi {
  Future<List<SharedFile>?>? getShared() async {
    final url = '${cuenta.server}/ocs/v2.php/apps/files_sharing/api/v1/shares';
    Map<String, String> headers = {
      'Authorization': 'Basic $auth}',
      'OCS-APIRequest': 'true',
      'Accept': 'application/json',
    };
    try {
      final response = await dio.get(
        url,
        options: Options(headers: headers, responseType: ResponseType.json),
      );
      if (response.statusCode == 200) {
        var listData = response.data['ocs']['data'] as List;
        List<SharedFile> sharedFiles = listData
            .map((item) => SharedFile.fromJson(item))
            .toList();
        sharedFiles.sort(
          (a, b) =>
              a.sharedPath.toLowerCase().compareTo(b.sharedPath.toLowerCase()),
        );
        return sharedFiles;
      } else {
        throw Exception('Error al obtener Shared: ${response.statusCode}');
      }
    } catch (e) {
      return null;
    }
  }
}
