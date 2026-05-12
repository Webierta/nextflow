part of 'nextcloud_api.dart';

extension Preview on NextcloudApi {
  Future<int?>? getFileId(String pathFile) async {
    final url =
        '${cuenta.server}/remote.php/dav/files/${cuenta.userName}/$pathFile';
    Map<String, String> headers = {
      'Authorization': 'Basic $auth}',
      'Depth': '0',
      'Content-Type': 'application/xml',
      //'Content-Type': 'application/xml; charset="utf-8"',
    };
    var data = XmlDocument.parse(
      '<?xml version="1.0"?><d:propfind xmlns:d="DAV:" xmlns:oc="http://owncloud.org/ns"><d:prop><oc:fileid/></d:prop></d:propfind>',
    );
    try {
      final response = await dio.request(
        url,
        options: Options(
          method: 'PROPFIND',
          headers: headers,
          responseType: ResponseType.plain,
        ),
        data: data,
        cancelToken: cancelToken,
      );
      if (response.statusCode == 207) {
        final document = XmlDocument.parse(response.data);
        final nodeFileId = document.findAllElements('oc:fileid');
        return int.tryParse(nodeFileId.first.innerText);
      } else {
        throw Exception('Error al obtener files: ${response.statusCode}');
      }
    } on DioException catch (_) {
      return null;
    }
  }

  Future<Uint8List?>? fetchPreview(
    int fileId, {
    int width = 512,
    int height = 512,
  }) async {
    final url =
        '${cuenta.server}/index.php/core/preview?fileId=$fileId&x=$width&y=$height&a=true';

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
        throw Exception('Error al obtener preview: ${response.statusCode}');
      }
    } on DioException catch (_) {
      return null;
    }
  }

  Future<String?>? readFile(String remotePath) async {
    final url =
        '${cuenta.server}/remote.php/dav/files/${cuenta.userName}/$remotePath';
    Map<String, String> headers = {
      'Authorization': 'Basic $auth}',
      //'Content-Type': 'application/xml; charset="utf-8"',
    };
    try {
      final response = await dio.get(
        url,
        options: Options(headers: headers, responseType: ResponseType.plain),
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return null;
      }
    } on DioException catch (_) {
      return null;
    }
  }

  Future<Uint8List?>? getPdf(String remotePath) async {
    final url =
        '${cuenta.server}/remote.php/dav/files/${cuenta.userName}/$remotePath';
    Map<String, String> headers = {'Authorization': 'Basic $auth}'};
    try {
      final response = await dio.get(
        url,
        options: Options(headers: headers, responseType: ResponseType.bytes),
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error al descargar PDF: ${response.statusCode}');
      }
    } on DioException catch (_) {
      return null;
    }
  }
}
