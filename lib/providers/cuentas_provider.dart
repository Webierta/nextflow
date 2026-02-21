import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cuenta_nextcloud.dart';

final cuentasProvider =
    NotifierProvider<CuentasNotifier, List<CuentaNextcloud>>(
      CuentasNotifier.new,
    );

class CuentasNotifier extends Notifier<List<CuentaNextcloud>> {
  @override
  List<CuentaNextcloud> build() {
    return [];
  }

  void add(CuentaNextcloud cuenta) {
    final newCuenta = CuentaNextcloud(
      server: cuenta.server,
      userName: cuenta.userName,
      password: cuenta.password,
      statusAuth: cuenta.statusAuth,
    );
    state = [...state, newCuenta];
  }

  void remove(CuentaNextcloud cuenta) =>
      state = state.where((c) => c.name != cuenta.name).toList();

  void edit(
    CuentaNextcloud cuenta, {
    String? newServer,
    String? newUser,
    String? newPassword,
    StatusAuth? newStatusAuth,
    Uint8List? newAvatar,
  }) {
    final newCuenta = CuentaNextcloud(
      server: newServer ?? cuenta.server,
      userName: newUser ?? cuenta.userName,
      password: newPassword ?? cuenta.password,
      statusAuth: newStatusAuth ?? cuenta.statusAuth,
    );
    newCuenta.avatar = newAvatar ?? newCuenta.avatar;
    if (state.contains(cuenta)) {
      state[state.indexOf(cuenta)] = newCuenta;
    }
  }

  void desconectar(CuentaNextcloud cuenta) {
    state = state.map((c) {
      if (c.name == cuenta.name) {
        return c.copyWith(statusAuth: StatusAuth.logout);
      } else {
        return c;
      }
    }).toList();

    /*for (int i = 0; i < state.length; i++) {
      if(state[i].name == cuenta.name){
        state[i].copyWith(statusAuth: StatusAuth.logout);
      }
    }*/
  }

  void clear() {
    state = [];
  }
}
