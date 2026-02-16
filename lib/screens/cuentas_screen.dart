import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cuenta_nextcloud.dart';
import '../providers/cuentas_provider.dart';
import '../services/nextcloud_api/nextcloud_api.dart';
import '../styles/styles_app.dart';
import '../widgets/cuenta_avatar.dart';
import '../widgets/drawer_app.dart';
import '../widgets/snackbar_manager.dart';
import 'add_cuenta_screen.dart';
import 'cuenta_screen.dart';

enum PageRoute { files, shared, notes, gallery }

class CuentasScreen extends ConsumerStatefulWidget {
  const CuentasScreen({super.key});

  @override
  ConsumerState createState() => _CuentasScreenState();
}

class _CuentasScreenState extends ConsumerState<CuentasScreen> {
  @override
  Widget build(BuildContext context) {
    final cuentas = ref.watch(cuentasProvider);
    return SafeArea(
      child: Container(
        decoration: StylesApp.backgroundScreen(context),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          drawer: const DrawerApp(),
          appBar: AppBar(
            //automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            title: Text(
              'Nextflow',
              style: TextStyle(fontWeight: FontWeight.w200),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // ABRIR DIALOGO CON TEXTFIELD
                  // PARA BUSCAR EN TODAS LAS CUENTAS ??
                },
                icon: Icon(Icons.search),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const AddCuentaScreen(),
                ),
              );
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            tooltip: 'Add count Nextcloud',
            child: Icon(
              Icons.add,
              size: 42,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          body: cuentas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [
                      Text('The sky is clear. Add a cloud.'),
                      const SizedBox(height: 30),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const AddCuentaScreen(),
                            ),
                          );
                        },
                        child: Text('Add a Nextcloud account'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: ScrollPhysics(),
                  padding: .symmetric(horizontal: 20, vertical: 10),
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: cuentas.length,
                    itemBuilder: (context, index) {
                      var cuenta = cuentas[index];
                      var nextcloudApi = NextcloudApi(cuenta: cuenta);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20), //20
                        child: Card(
                          elevation: 10,
                          child: Padding(
                            padding: .all(4),
                            child: Stack(
                              children: [
                                ListTile(
                                  onTap: () {
                                    if (cuenta.statusAuth == StatusAuth.login) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).removeCurrentSnackBar();
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (context) =>
                                              CuentaScreen(cuenta: cuenta),
                                        ),
                                      );
                                    } else {
                                      SnackbarManager.show(
                                        context: context,
                                        msg: 'La cuenta está desconectada.',
                                        error: true,
                                      );
                                    }
                                  },
                                  titleAlignment: ListTileTitleAlignment.top,
                                  leading: CuentaAvatar(cuenta: cuenta),
                                  horizontalTitleGap: 20,
                                  title: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundColor:
                                            cuenta.statusAuth ==
                                                StatusAuth.login
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(cuenta.userName),
                                    ],
                                  ),
                                  subtitle: Text(cuenta.server),
                                  contentPadding: .only(left: 4),
                                ),
                                Positioned(
                                  right: 0,
                                  child: Switch(
                                    value:
                                        cuenta.statusAuth == StatusAuth.login,
                                    onChanged: (bool value) {
                                      if (value == true) {
                                        conectarCuenta(cuenta, nextcloudApi);
                                      } else {
                                        desconectarCuenta(cuenta, nextcloudApi);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> conectarCuenta(
    CuentaNextcloud cuenta,
    NextcloudApi nextcloudApi,
  ) async {
    // autenticar cuenta
    SnackbarManager.show(
      context: context,
      msg: 'Conectando a ${cuenta.name}...',
    );
    bool authenticate = await nextcloudApi.authenticate();
    if (authenticate == true) {
      ref
          .read(cuentasProvider.notifier)
          .edit(cuenta, newStatusAuth: StatusAuth.login);
      setState(() {
        cuenta = cuenta.copyWith(statusAuth: StatusAuth.login);
      });
      //getAvatar(nextcloudApi);
    } else {
      setState(() {
        cuenta = cuenta.copyWith(statusAuth: StatusAuth.denied);
      });
      if (mounted) {
        SnackbarManager.show(
          context: context,
          msg: 'Error de autenticación',
          error: true,
        );
      }
    }
  }

  void desconectarCuenta(CuentaNextcloud cuenta, NextcloudApi nextcloudApi) {
    // desconectar cuenta
    nextcloudApi.deconectar();
    ref
        .read(cuentasProvider.notifier)
        .edit(cuenta, newStatusAuth: StatusAuth.logout);
    setState(() {
      cuenta = cuenta.copyWith(statusAuth: StatusAuth.logout);
    });
    SnackbarManager.show(
      context: context,
      msg: 'Cuenta desconectada del servidor',
    );
  }
}
