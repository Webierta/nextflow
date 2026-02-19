import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cuenta_nextcloud.dart';
import '../providers/cuentas_provider.dart';
import '../services/nextcloud_api/nextcloud_api.dart';
import '../services/storage_service.dart';
import '../styles/styles_app.dart';
import '../widgets/cuenta_avatar.dart';
import '../widgets/open_dialog.dart';
import '../widgets/snackbar_manager.dart';
import 'add_cuenta_screen.dart';
import 'cuenta_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> deleteAllCuentas() async {
    final confirmation = await OpenDialog.confirm(
      context: context,
      title: 'Confirmación requerida',
      content: Text('¿Eliminar todas las cuentas?'),
    );
    if (confirmation == true) {
      await StorageService.clearStorage();
      ref.read(cuentasProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cuentas = ref.watch(cuentasProvider);
    return SafeArea(
      child: Container(
        decoration: StylesApp.backgroundScreen(context),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const CuentaScreen(),
                  ),
                );
              },
              icon: Icon(Icons.arrow_back),
            ),
            title: Text('Settings'),
          ),
          body: SingleChildScrollView(
            padding: .all(20),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                if (cuentas.isNotEmpty)
                  ListTile(
                    title: Text('Account management'),
                    trailing: IconButton.filledTonal(
                      onPressed: deleteAllCuentas,
                      icon: Icon(Icons.delete_forever),
                    ),
                  ),
                if (cuentas.isNotEmpty)
                  ChildreenCuentas()
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const AddCuentaScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.add),
                        label: Text('Add Count'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChildreenCuentas extends ConsumerStatefulWidget {
  const ChildreenCuentas({super.key});

  @override
  ConsumerState createState() => _ChildreenCuentasState();
}

class _ChildreenCuentasState extends ConsumerState<ChildreenCuentas> {
  void onTapMoreCuenta(CuentaNextcloud cuenta) {
    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: false,
      //scrollControlDisabledMaxHeightRatio: 0.7,
      barrierColor: Colors.white70,
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      context: context,
      constraints: BoxConstraints(maxWidth: double.infinity),
      builder: (BuildContext contextBottomSheet) {
        return ListView(
          children: [
            Center(child: Text(cuenta.name, style: TextStyle(fontSize: 22))),
            Divider(),
            Column(
              mainAxisSize: .min,
              children: [
                ListTile(
                  onTap: () => conectarCuenta(cuenta),
                  leading: Icon(Icons.wifi, size: 42),
                  title: Text('Connection test'),
                ),
                const SizedBox(height: 20),
                ListTile(
                  onTap: () => editCuenta(cuenta),
                  leading: Icon(Icons.edit, size: 42),
                  title: Text('Edit'),
                ),
                const SizedBox(height: 20),
                ListTile(
                  onTap: () => deleteCuenta(cuenta),
                  leading: Icon(Icons.delete, size: 42),
                  title: Text('Delete'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> conectarCuenta(CuentaNextcloud cuenta) async {
    Navigator.of(context).pop();
    var nextcloudApi = NextcloudApi(cuenta: cuenta);
    SnackbarManager.show(
      context: context,
      msg: 'Conectando a ${cuenta.name}...',
    );
    bool authenticate = await nextcloudApi.authenticate();
    if (authenticate == true) {
      if (mounted) {
        SnackbarManager.show(
          context: context,
          msg: 'Cuenta conectada con éxito!',
        );
      }
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

  void editCuenta(CuentaNextcloud cuenta) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AddCuentaScreen(cuentaEdit: cuenta),
      ),
    );
  }

  Future<void> deleteCuenta(CuentaNextcloud cuenta) async {
    Navigator.of(context).pop();
    final confirmation = await OpenDialog.confirm(
      context: context,
      title: 'Confirmación requerida',
      content: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [Text('¿Eliminar esta cuenta?'), Text(cuenta.name)],
      ),
    );
    if (confirmation == true) {
      await StorageService.deleteCuenta(cuenta.name);
      ref.read(cuentasProvider.notifier).remove(cuenta);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cuentas = ref.watch(cuentasProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            for (var cuenta in cuentas)
              Padding(
                padding: const .symmetric(vertical: 10),
                child: ListTile(
                  //contentPadding: .zero,
                  leading: CuentaAvatar(cuenta: cuenta),
                  titleAlignment: ListTileTitleAlignment.top,
                  horizontalTitleGap: 20,
                  title: Text(cuenta.userName),
                  subtitle: Text(cuenta.server),
                  trailing: IconButton(
                    onPressed: () {
                      onTapMoreCuenta(cuenta);
                    },
                    icon: Icon(Icons.more_vert),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
