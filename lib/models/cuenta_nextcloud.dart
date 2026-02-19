import 'dart:convert';
import 'dart:typed_data';

enum StatusAuth { login, logout, loading, denied }

class CuentaNextcloud {
  final String server;
  final String userName;
  final String password;
  final StatusAuth statusAuth;
  String? userId;
  Uint8List? avatar;

  CuentaNextcloud({
    required this.server,
    required this.userName,
    required this.password,
    this.statusAuth = StatusAuth.logout,
  });

  String get name {
    var serverSinHttp = server.substring(server.indexOf('/') + 2);
    return '$userName@$serverSinHttp';
  }

  factory CuentaNextcloud.fromJson(Map<String, dynamic> jsonData) {
    var statusAuth = switch (jsonData['statusAuth']) {
      'login' => StatusAuth.login,
      'logout' => StatusAuth.logout,
      'loading' => StatusAuth.loading,
      'denied' => StatusAuth.denied,
      _ => StatusAuth.logout,
    };
    return CuentaNextcloud(
      server: jsonData['server'],
      userName: jsonData['userName'],
      password: jsonData['password'],
      statusAuth: statusAuth,
    );
  }

  static Map<String, dynamic> toMap(CuentaNextcloud cuenta) =>
      <String, dynamic>{
        'server': cuenta.server,
        'userName': cuenta.userName,
        'password': cuenta.password,
        'statusAuth': cuenta.statusAuth.name,
      };

  static String serialize(CuentaNextcloud cuenta) =>
      json.encode(CuentaNextcloud.toMap(cuenta));

  static CuentaNextcloud deserialize(String json) =>
      CuentaNextcloud.fromJson(jsonDecode(json));

  // Create a copyWith method for immutability
  CuentaNextcloud copyWith({
    String? server,
    String? userName,
    String? password,
    StatusAuth? statusAuth,
    String? userId,
    Uint8List? avatar,
  }) {
    CuentaNextcloud cuenta = CuentaNextcloud(
      server: server ?? this.server,
      userName: userName ?? this.userName,
      password: password ?? this.password,
      statusAuth: statusAuth ?? this.statusAuth,
    );
    cuenta.userId = userId ?? this.userId;
    cuenta.avatar = avatar ?? this.avatar;
    return cuenta;
  }
}
