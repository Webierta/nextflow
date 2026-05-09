part of 'nextcloud_api.dart';

extension Notes on NextcloudApi {
  Future<List<Note>?>? getNotes() async {
    final url = '${cuenta.server}/index.php/apps/notes/api/v1/notes';
    Map<String, String> headers = {
      'Authorization': 'Basic $auth}',
      'OCS-APIRequest': 'true',
      'Accept': 'application/json',
    };
    try {
      final responseNotes = await dio.get(
        url,
        options: Options(headers: headers, responseType: ResponseType.json),
      );
      if (responseNotes.statusCode == 200) {
        var listData = responseNotes.data as List;
        //print(listData);
        return listData.map((json) => Note.fromJson(json)).toList();
        /*if (category != null) {
          notes = notes.where((note) => note.category == category).toList();
        }*/
        //return notes;
      } else {
        throw Exception('Error al obtener Notes: ${responseNotes.statusCode}');
      }
    } on DioException catch (_) {
      //throw Exception('Failed to load notes: ${e.message}');
      return null;
    }
  }

  Future<bool> updateNote({
    required int id,
    String? title,
    String? content,
    String? category,
    bool? favorite,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (content != null) data['content'] = content;
    if (category != null) data['category'] = category;
    if (favorite != null) data['favorite'] = favorite;

    final url = '${cuenta.server}/index.php/apps/notes/api/v1/notes';
    Map<String, String> headers = {
      'Authorization': 'Basic $auth}',
      'OCS-APIRequest': 'true',
      'Accept': 'application/json',
    };

    try {
      final responseUpdate = await dio.put(
        '$url/$id',
        options: Options(headers: headers),
        data: data,
      );
      if (responseUpdate.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error update Note: ${responseUpdate.statusCode}');
      }
    } on DioException catch (_) {
      return false;
    }
  }
}
