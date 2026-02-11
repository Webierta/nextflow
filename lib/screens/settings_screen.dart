import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cuentas_provider.dart';
import '../services/storage_service.dart';
import '../styles/styles_app.dart';
import '../widgets/open_dialog.dart';
import 'add_cuenta_screen.dart';
import 'cuentas_screen.dart';

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
    return Container(
      decoration: StylesApp.backgroundScreen(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const CuentasScreen(),
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
    );
  }
}

class ChildreenCuentas extends ConsumerStatefulWidget {
  const ChildreenCuentas({super.key});

  @override
  ConsumerState createState() => _ChildreenCuentasState();
}

class _ChildreenCuentasState extends ConsumerState<ChildreenCuentas> {
  @override
  Widget build(BuildContext context) {
    final cuentas = ref.watch(cuentasProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            for (var cuenta in cuentas)
              Padding(
                padding: const .symmetric(vertical: 10),
                child: ListTile(
                  leading: IconButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) =>
                            AddCuentaScreen(cuentaEdit: cuenta),
                      ),
                    ),
                    icon: CircleAvatar(child: Icon(Icons.edit)),
                  ),
                  title: Text(cuenta.name),
                  trailing: IconButton.outlined(
                    onPressed: () async {
                      final confirmation = await OpenDialog.confirm(
                        context: context,
                        title: 'Confirmación requerida',
                        content: Column(
                          mainAxisSize: .min,
                          crossAxisAlignment: .start,
                          children: [
                            Text('¿Eliminar esta cuenta?'),
                            Text(cuenta.name),
                          ],
                        ),
                      );
                      if (confirmation == true) {
                        await StorageService.deleteCuenta(cuenta.name);
                        ref.read(cuentasProvider.notifier).remove(cuenta);
                      }
                    },
                    icon: Icon(Icons.delete),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
