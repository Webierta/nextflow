part of 'nextcloud_api.dart';

class CopyJob {
  final String source;
  final String destination;

  CopyJob(this.source, this.destination);
}

extension Copy on NextcloudApi {
  Future<bool> copyFile({
    required String pathSource,
    required String pathDestino,
  }) async {
    final baseUrl = '${cuenta.server}/remote.php/dav/files/${cuenta.userName}';
    var url = '$baseUrl$pathSource';
    if (url.contains(' ')) {
      url = Uri.encodeFull(url);
    }
    var destination = '$baseUrl$pathDestino';
    if (destination.contains(' ')) {
      destination = Uri.encodeFull(destination);
    }
    Map<String, String> headers = {
      'Authorization': 'Basic $auth},',
      'Destination': destination,
      'Overwrite': 'T', // F / T
    };
    try {
      final response = await dio.request(
        url,
        options: Options(method: 'COPY', headers: headers),
      );
      if (response.statusCode == 201 || response.statusCode == 204) {
        return true;
      } else {
        //print(response.statusCode);
        return false;
      }
    } on DioException catch (_) {
      return false;
    }
  }

  Future<void> copyFolder({
    required List<CopyJob> copyJobs,
    void Function(int done, int total)? onProgress,
  }) async {
    final baseUrl = '${cuenta.server}/remote.php/dav/files/${cuenta.userName}';
    Map<String, String> headers = {
      'Authorization': 'Basic $auth},',
      //'Destination': destination,
      'Overwrite': 'T', // F / T
    };
    int done = 0;
    for (final job in copyJobs) {
      final sourceUrl = '$baseUrl/${Uri.encodeFull(job.source)}';
      final destination = '$baseUrl/${Uri.encodeFull(job.destination)}';
      //headers['Destination'] = destination;
      headers.addAll({'Destination': destination});
      try {
        final response = await dio.request(
          sourceUrl,
          options: Options(method: 'COPY', headers: headers),
        );
        if (response.statusCode == 201 || response.statusCode == 204) {
          done++;
          onProgress?.call(done, copyJobs.length);
        } else {
          throw Exception('Error al crear carpeta: ${response.statusCode}');
        }
      } on DioException catch (_) {
        //debugPrint('❌ Error copiando ${job.source}: $e');
      }
    }
  }
}
