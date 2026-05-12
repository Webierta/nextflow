part of 'nextcloud_api.dart';

extension GetFiles on NextcloudApi {
  Future<CloudFile?>? getFile(String path) async {
    final url =
        '${cuenta.server}/remote.php/dav/files/${cuenta.userName}/$path';
    Map<String, String> headers = {
      'Authorization': 'Basic $auth}',
      'Content-Type': 'application/xml; charset="utf-8"',
    };
    try {
      final response = await dio.request(
        url,
        options: Options(
          method: 'PROPFIND',
          headers: headers,
          responseType: ResponseType.plain,
        ),
        cancelToken: cancelToken,
      );
      if (response.statusCode == 207) {
        final document = XmlDocument.parse(response.data);
        final href = document.findAllElements('d:href').first.innerText;
        final contentLength = document
            .findAllElements('d:getcontentlength')
            .first
            .innerText;
        /*final usedBytes = document
            .findAllElements('d:quota-used-bytes')
            .first
            .innerText;*/
        final typeFile = document
            .findAllElements('d:getcontenttype')
            .first
            .innerText;
        final lastModified = document
            .findAllElements('d:getlastmodified')
            .first
            .innerText;
        final name = Uri.decodeFull(
          href.split('/').where((e) => e.isNotEmpty).last,
        );
        return CloudFile(
          name: name,
          isDirectory: false,
          lastModified: lastModified,
          size: contentLength,
          typeFile: typeFile,
          href: href,
        );
      } else {
        throw Exception('Error al obtener file: ${response.statusCode}');
      }
    } on DioException catch (_) {
      return null;
    }
  }

  /*Future<List<CloudFile>?>? listFiles(
    String path, {
    bool onlyDir = false,
    bool onlyImg = false,
    String depth = '1',
  }) async {
    final server = '${cuenta.server}/remote.php/dav/files/${cuenta.userName}/';
    var client = dav.newClient(
      server,
      user: cuenta.userName,
      //password: cuenta.password,
    );
    Map<String, String> headers = {
      'Authorization': 'Basic $auth}',
      //'Depth': 'infinity',
      'Depth': depth,
      //'Content-Type': 'application/xml',
      'Content-Type': 'application/xml; charset="utf-8"',
      //'Accept-Encoding': 'gzip',
    };
    client.setHeaders(headers);

    try {
      //await client.ping();
      var files = await client.readDir(path, cancelToken);

      //files.forEach((f) {
      //print('${f.name} ${f.path} ${f.size} ${f.isDir} ${f.mimeType} ${f.mTime}');
      //});

      List<CloudFile> cloudFiles = files.map((f) {
        if (f.name == null || f.mTime == null) {
          throw Exception('Error al obtener files');
        }
        var lastModified = FormatDates.dateToString(f.mTime!);
        return CloudFile(
          name: f.name ?? 'No Name',
          isDirectory: f.isDir ?? false,
          lastModified: lastModified,
          // f.mTime?.toString(),
          size: f.size?.toString(),
          typeFile: f.mimeType,
          href: f.path,
        );
      }).toList();

      final listaDir = cloudFiles.where((item) => item.isDirectory).toList();
      listaDir.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      final listaFile = cloudFiles.where((item) => !item.isDirectory).toList();
      listaFile.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      if (onlyDir == true) return listaDir;
      if (onlyImg == true) {
        return listaFile
            .where(
              (file) =>
                  (file.typeFile != null &&
                  file.typeFile!.startsWith('image/')),
            )
            .toList();
      }
      return listaDir + listaFile;
    } catch (e) {
      print('Error al listar archivos: $e');
      return null;
    }
  }*/

  Future<List<CloudFile>?>? getFiles(
    String path, {
    bool onlyDir = false,
    bool onlyImg = false,
    String depth = '1',
  }) async {
    final url =
        '${cuenta.server}/remote.php/dav/files/${cuenta.userName}/$path';
    Map<String, String> headers = {
      'Authorization': 'Basic $auth}',
      //'Depth': 'infinity',
      'Depth': depth,
      //'Content-Type': 'application/xml',
      'Content-Type': 'application/xml; charset="utf-8"',
      //'Accept-Encoding': 'gzip',
    };

    dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));

    try {
      final response = await dio.request(
        url,
        options: Options(
          method: 'PROPFIND',
          headers: headers,
          responseType: ResponseType.plain,
        ),
        cancelToken: cancelToken,
      );
      if (response.statusCode == 207) {
        final document = XmlDocument.parse(response.data);
        //print(document.toString());
        final responses = document.findAllElements('d:response');

        List<CloudFile> listaItems = [];
        for (var response in responses) {
          final href = response.findElements('d:href').first.innerText;
          final name = Uri.decodeComponent(
            href.split('/').lastWhere((e) => e.isNotEmpty, orElse: () => '/'),
          );
          final prop = response.findAllElements('d:prop').first;
          final lastModified = prop
              .findElements('d:getlastmodified')
              .firstOrNull
              ?.innerText;
          final size = prop
              .findElements('d:getcontentlength')
              .firstOrNull
              ?.innerText;
          final usedBytes = prop
              .findElements('d:quota-used-bytes')
              .firstOrNull
              ?.innerText;
          final typeFile = prop
              .findElements('d:getcontenttype')
              .firstOrNull
              ?.innerText;
          final esCarpeta = prop
              .findElements('d:resourcetype')
              .first
              .findElements('d:collection')
              .isNotEmpty;
          listaItems.add(
            CloudFile(
              name: name,
              isDirectory: esCarpeta,
              lastModified: lastModified,
              size: size ?? usedBytes,
              typeFile: typeFile,
              href: href,
            ),
          );
        }

        /*final List<CloudFile> listaItems = responses.skip(1).map((node) {
          final href = node.findElements('d:href').first.innerText;
          final isDir = node.findAllElements('d:collection').isNotEmpty;
          String? contentLength;
          if (node.findAllElements('d:getcontentlength').isNotEmpty) {
            contentLength = node
                .findAllElements('d:getcontentlength')
                .first
                .innerText;
          }
          String? usedBytes;
          if (node.findAllElements('d:quota-used-bytes').isNotEmpty) {
            usedBytes = node
                .findAllElements('d:quota-used-bytes')
                .first
                .innerText;
          }
          String? typeFile;
          if (node.findAllElements('d:getcontenttype').isNotEmpty) {
            typeFile = node.findAllElements('d:getcontenttype').first.innerText;
          }
          final lastModified = node
              .findAllElements('d:getlastmodified')
              .first
              .innerText;
          */ /*final name = Uri.decodeFull(
            href.split('/').where((e) => e.isNotEmpty).last,
          );*/ /*
          final name = Uri.decodeComponent(
            href
                .split('/')
                .lastWhere((e) => e.isNotEmpty, orElse: () => 'Raíz'),
          );
          return CloudFile(
            name: name,
            isDirectory: isDir,
            lastModified: lastModified,
            size: contentLength ?? usedBytes,
            typeFile: typeFile,
            href: href,
          );
        }).toList();*/
        final listaDir = listaItems.where((item) => item.isDirectory).toList();
        listaDir.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        final listaFile = listaItems
            .where((item) => !item.isDirectory)
            .toList();
        listaFile.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        if (onlyDir == true) return listaDir;
        if (onlyImg == true) {
          return listaFile
              .where(
                (file) =>
                    (file.typeFile != null &&
                    file.typeFile!.startsWith('image/')),
              )
              .toList();
        }
        return listaDir + listaFile;
      } else {
        throw Exception('Error al obtener files: ${response.statusCode}');
      }
    } on DioException catch (_) {
      // TODO: incluir mensaje de error DIO
      return null;
    }
  }
}
