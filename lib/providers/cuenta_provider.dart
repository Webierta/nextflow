/*import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cuenta_nextcloud.dart';

final cuentaProvider = NotifierProvider<CuentaNotifier, CuentaNextcloud>(
  CuentaNotifier.new,
);

class CuentaNotifier extends Notifier<CuentaNextcloud> {
  final CuentaNextcloud defaultCuenta = CuentaNextcloud(
    server: '',
    userName: '',
    password: '',
    statusAuth: StatusAuth.logout,
  );

  @override
  CuentaNextcloud build() {
    return defaultCuenta;
  }

  void copyWith({
    String? newServer,
    String? newUser,
    String? newPassword,
    StatusAuth? newStatusAuth,
    String? newUserId,
    Uint8List? newAvatar,
  }) {
    state = CuentaNextcloud(
      server: newServer ?? state.server,
      userName: newUser ?? state.userName,
      password: newPassword ?? state.password,
      statusAuth: newStatusAuth ?? state.statusAuth,
    );
    state.userId = newUserId ?? state.userId;
    state.avatar = newAvatar ?? state.avatar;
  }
}*/
