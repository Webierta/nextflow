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
import 'files_screen.dart';
import 'gallery_screen.dart';
import 'notes_screen.dart';
import 'shared_screen.dart';

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
    return Container(
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
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const AddCuentaScreen(),
              ),
            );
          },
          child: Icon(Icons.add),
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
                padding: .symmetric(horizontal: 40, vertical: 10),
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
                          padding: const EdgeInsets.all(10.0),
                          child: ListTile(
                            titleAlignment: ListTileTitleAlignment.top,
                            leading: CuentaAvatar(cuenta: cuenta),
                            title: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor:
                                        cuenta.statusAuth == StatusAuth.login
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(cuenta.name),
                                ],
                              ),
                            ),
                            subtitle: CuentaStage(cuenta: cuenta),
                            trailing: Switch(
                              value: cuenta.statusAuth == StatusAuth.login,
                              onChanged: (bool value) {
                                if (value == true) {
                                  switchTrue(cuenta, nextcloudApi);
                                } else {
                                  switchFalse(cuenta, nextcloudApi);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Future<void> switchTrue(
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

  void switchFalse(CuentaNextcloud cuenta, NextcloudApi nextcloudApi) {
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

class CuentaStage extends StatefulWidget {
  final CuentaNextcloud cuenta;

  const CuentaStage({super.key, required this.cuenta});

  @override
  State<CuentaStage> createState() => _CuentaStageState();
}

class _CuentaStageState extends State<CuentaStage> {
  TextEditingController controller = TextEditingController();
  bool ocultoSearch = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cuenta.statusAuth != StatusAuth.login) {
      return SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Wrap(
            //spacing: 0,
            runSpacing: 20,
            children: [
              SizedBox(
                width: 180,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onPageRoute(
                      pageRoute: PageRoute.files,
                      cuenta: widget.cuenta,
                    ),
                    label: Text('Files'),
                    icon: Icon(Icons.folder_open, size: 42),
                  ),
                ),
              ),
              SizedBox(
                width: 180,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onPageRoute(
                      pageRoute: PageRoute.shared,
                      cuenta: widget.cuenta,
                    ),
                    label: Text('Shared'),
                    icon: Icon(Icons.folder_shared_outlined, size: 42),
                  ),
                ),
              ),
              SizedBox(
                width: 180,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onPageRoute(
                      pageRoute: PageRoute.notes,
                      cuenta: widget.cuenta,
                    ),
                    label: Text('Notes'),
                    icon: Icon(Icons.article_outlined, size: 42),
                  ),
                ),
              ),
              SizedBox(
                width: 180,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onPageRoute(
                      pageRoute: PageRoute.gallery,
                      cuenta: widget.cuenta,
                    ),
                    label: Text('Gallery'),
                    icon: Icon(Icons.photo_library_outlined, size: 42),
                  ),
                ),
              ),
              SizedBox(
                width: 180,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      controller.clear();
                      setState(() {
                        ocultoSearch = !ocultoSearch;
                      });
                    },
                    label: Text('Search'),
                    icon: Icon(Icons.manage_search, size: 42),
                  ),
                ),
              ),
              Offstage(
                offstage: ocultoSearch,
                child: SizedBox(
                  width: 180,
                  child: TextField(
                    controller: controller,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      suffixIcon: IconButton(
                        onPressed: controller.text.trim().isEmpty
                            ? null
                            : onPageRoute(
                                pageRoute: PageRoute.files,
                                cuenta: widget.cuenta,
                                inputSearch: controller.text,
                              ),
                        icon: Icon(Icons.open_in_new),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Null Function()? onPageRoute({
    required PageRoute pageRoute,
    required CuentaNextcloud cuenta,
    String? inputSearch,
  }) {
    //if (cuenta.statusAuth != StatusAuth.login) return null;
    var page = switch (pageRoute) {
      //PageRoute.files => FilesScreen(cuenta: cuenta),
      PageRoute.files => FilesScreen(cuenta: cuenta, inputSearch: inputSearch),
      PageRoute.shared => SharedScreen(cuenta: cuenta),
      PageRoute.notes => NotesScreen(cuenta: cuenta),
      PageRoute.gallery => GalleryScreen(cuenta: cuenta),
      //PageRoute.gallery => GalleryScreen2(cuenta: cuenta),
    };
    //controller.clear();

    return () {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      controller.clear();
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (context) => page));
    };
  }
}
