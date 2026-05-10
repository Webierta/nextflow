import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path_dart;
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

import '../../models/cloud_file.dart';
import '../../models/cuenta_nextcloud.dart';
import '../../models/note.dart';
import '../../models/shared_file.dart';

part 'nextcloud_api_avatar.dart';
part 'nextcloud_api_copy.dart';
part 'nextcloud_api_get_files.dart';
part 'nextcloud_api_loader.dart';
part 'nextcloud_api_move_delete.dart';
part 'nextcloud_api_new_folders.dart';
part 'nextcloud_api_notes.dart';
part 'nextcloud_api_preview.dart';
part 'nextcloud_api_shared.dart';

class NextcloudApi {
  final CuentaNextcloud cuenta;

  NextcloudApi({required this.cuenta});

  final dio = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: 50),
      receiveTimeout: Duration(seconds: 50),
    ),
  );

  String get auth =>
      base64Encode(utf8.encode('${cuenta.userName}:${cuenta.password}'));

  Future<bool> authenticate() async {
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
      );
      if (response.statusCode == 200) {
        if (response.data['ocs']['data'] != null) {
          return true;
        } else {
          return false;
        }
      } else {
        throw Exception('Error al conectar cuenta: ${response.statusCode}');
      }
    } on DioException catch (_) {
      return false;
    }
  }

  void desconectar() => dio.close();
}
