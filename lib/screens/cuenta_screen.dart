import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cuenta_nextcloud.dart';
import '../models/destino.dart';
import '../providers/cuentas_provider.dart';
import '../services/nextcloud_api/nextcloud_api.dart';
import '../styles/styles_app.dart';
import '../widgets/cuenta_avatar.dart';
import '../widgets/drawer_app.dart';
import '../widgets/open_dialog.dart';
import '../widgets/snackbar_manager.dart';
import 'add_cuenta_screen.dart';
import 'files_screen.dart';

class CuentaScreen extends ConsumerStatefulWidget {
  final CuentaNextcloud? cuentaSelect;

  const CuentaScreen({super.key, this.cuentaSelect});

  @override
  ConsumerState createState() => _CuentaScreenState();
}

class _CuentaScreenState extends ConsumerState<CuentaScreen> {
  CuentaNextcloud? cuentaSelect;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    loadCuenta();
    super.initState();
  }

  void loadCuenta() {
    if (widget.cuentaSelect != null) {
      setState(() {
        cuentaSelect = widget.cuentaSelect;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> selectCuenta(List<CuentaNextcloud> cuentas) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Seleciona una cuenta'),
          content: Column(
            mainAxisSize: .min,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<CuentaNextcloud>(
                  hint: cuentaSelect == null
                      ? Text('Selecciona una cuenta')
                      : RowAvatar(cuenta: cuentaSelect!),
                  //value: cuentaSelect,
                  //elevation: 16,
                  onChanged: (CuentaNextcloud? cuenta) async {
                    Navigator.of(context).pop();
                    if (cuenta != null) {
                      setState(() => cuentaSelect = cuenta);
                      await conectarCuenta();
                    }
                  },
                  items: cuentas
                      .map<DropdownMenuItem<CuentaNextcloud>>(
                        (CuentaNextcloud cuenta) =>
                            DropdownMenuItem<CuentaNextcloud>(
                              value: cuenta,
                              child: RowAvatar(cuenta: cuenta),
                            ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> conectarCuenta() async {
    if (cuentaSelect == null) {
      SnackbarManager.show(
        context: context,
        msg: 'Ninguna cuenta seleccionada',
        error: true,
      );
      return;
    }
    // autenticar cuenta
    SnackbarManager.show(
      context: context,
      msg: 'Conectando a ${cuentaSelect!.name}...',
    );
    var nextcloudApi = NextcloudApi(cuenta: cuentaSelect!);
    bool authenticate = await nextcloudApi.authenticate();
    if (authenticate == true) {
      ref
          .read(cuentasProvider.notifier)
          .edit(cuentaSelect!, newStatusAuth: StatusAuth.login);
      setState(() {
        cuentaSelect = cuentaSelect!.copyWith(statusAuth: StatusAuth.login);
      });
      //getAvatar();
    } else {
      setState(() {
        cuentaSelect = cuentaSelect!.copyWith(statusAuth: StatusAuth.denied);
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

  Future<void> searchGlobal() async {
    final search = await OpenDialog.inputName(
      context: context,
      title: 'Search Global',
      icon: Icons.search,
      controller: searchController,
    );
    searchController.clear();
    if (search != null && search.trim().isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) =>
              FilesScreen(cuenta: cuentaSelect!, inputSearch: search),
        ),
      );
    }
  }

  void onTapDestino({
    required BuildContext context,
    Destino? destino,
    bool? isSearch = false,
  }) {
    if (cuentaSelect != null && cuentaSelect!.statusAuth == StatusAuth.login) {
      if (destino != null) {
        //return destino.onPageRoute(context: context, cuenta: cuentaSelect!);
        var onPage = destino.onPageRoute(
          context: context,
          cuenta: cuentaSelect!,
        );
        onPage.call();
      } else if (isSearch == true) {
        searchGlobal();
      }
    } else {
      String msg = 'Ninguna cuenta seleccionada';
      if (cuentaSelect != null &&
          cuentaSelect!.statusAuth != StatusAuth.login) {
        msg = 'Acceso a la cuenta denegado';
      }
      SnackbarManager.show(context: context, msg: msg, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cuentas = ref.watch(cuentasProvider);
    if (cuentas.isEmpty) {
      return Container(
        decoration: StylesApp.backgroundScreen(context),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
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
          ),
        ),
      );
    }
    return Container(
      decoration: StylesApp.backgroundScreen(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: const DrawerApp(),
        appBar: AppBar(
          leadingWidth: 30,
          title: cuentaSelect == null
              ? Text('Ninguna cuenta seleccionada')
              : Text(cuentaSelect!.userName),
          actions: [
            if (cuentaSelect != null)
              CuentaAvatar(cuenta: cuentaSelect!, size: 30),
            IconButton(
              onPressed: () => selectCuenta(cuentas),
              icon: Icon(Icons.arrow_drop_down),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            double childAspectRatio =
                constraints.maxWidth / constraints.maxHeight;
            double sizeIcon = childAspectRatio * 150;
            double sizeFont = childAspectRatio * 30;
            return Stack(
              children: [
                GridView.count(
                  childAspectRatio: childAspectRatio,
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  physics: NeverScrollableScrollPhysics(),
                  children: List.generate(Destino.values.length, (index) {
                    var destino = Destino.values[index];
                    var color = destino.color.withAlpha(130);
                    return Container(
                      padding: const EdgeInsets.all(20),
                      color: color,
                      child: InkWell(
                        onTap: () =>
                            onTapDestino(context: context, destino: destino),
                        //onTap: onTapDestino(context: context, destino: destino),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            children: [
                              Icon(destino.icon, size: sizeIcon),
                              Text(
                                destino.name,
                                style: TextStyle(fontSize: sizeFont),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                Center(
                  child: Container(
                    padding: .all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: IconButton(
                      onPressed: () =>
                          onTapDestino(context: context, isSearch: true),
                      icon: Icon(
                        Icons.search,
                        size: sizeIcon / 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class RowAvatar extends StatelessWidget {
  final CuentaNextcloud cuenta;

  const RowAvatar({super.key, required this.cuenta});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CuentaAvatar(cuenta: cuenta, size: 30, onlyAvatar: true),
        const SizedBox(width: 20),
        Text(cuenta.name, style: TextStyle(fontSize: 18)),
      ],
    );
  }
}
