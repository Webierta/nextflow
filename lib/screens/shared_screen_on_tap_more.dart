part of 'shared_screen.dart';

extension _OnTapMore on _SharedScreenState {
  void onTapMore({required BuildContext context, required SharedFile item}) {
    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: false,
      scrollControlDisabledMaxHeightRatio: 0.7,
      barrierColor: Colors.white70,
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      context: context,
      constraints: BoxConstraints(maxWidth: double.infinity),
      builder: (BuildContext contextBottomSheet) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: Text(item.name, style: TextStyle(fontSize: 22)),
                ),
              ),
              Divider(),
              Column(
                mainAxisSize: .min,
                children: [
                  ListTile(
                    leading: Icon(Icons.copy),
                    title: Text('Copiar link al portapapeles'),
                    subtitle: (item.sharedLink != null)
                        ? Text(
                            item.sharedLink!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    onTap: item.sharedLink == null
                        ? () {
                            Navigator.pop(contextBottomSheet);
                            if (!context.mounted) return;
                            SnackbarManager.show(
                              context: context,
                              msg: 'Error: Link no encontrado',
                              error: true,
                            );
                          }
                        : () async {
                            Navigator.pop(contextBottomSheet);
                            await Clipboard.setData(
                              ClipboardData(text: item.sharedLink!),
                            );
                            if (!context.mounted) return;
                            SnackbarManager.show(
                              context: context,
                              msg: 'Link copiado al portapapeles',
                            );
                          },
                  ),
                  ListTile(
                    leading: Icon(Icons.open_in_new),
                    title: Text('Abrir en el navegador'),
                    onTap: item.sharedLink == null
                        ? () {
                            Navigator.pop(contextBottomSheet);
                          }
                        : () async {
                            Navigator.pop(contextBottomSheet);
                            if (!await launchUrl(
                              Uri.parse(item.sharedLink!),
                              mode: LaunchMode.externalApplication,
                            )) {
                              //throw Exception('Could not launch ${item.sharedLink}',);
                              if (!context.mounted) return;
                              SnackbarManager.show(
                                context: context,
                                msg: 'Could not launch ${item.sharedLink}',
                                error: true,
                              );
                            }
                          },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.link_off),
                    title: Text('Dejar de compartir'),
                    onTap:
                        item.sharedId == null ||
                            int.tryParse(item.sharedId!) == null
                        ? () {
                            Navigator.pop(contextBottomSheet);
                            if (!context.mounted) return;
                            SnackbarManager.show(
                              context: context,
                              msg: 'Error: proceso abortado',
                              error: true,
                            );
                          }
                        : () async {
                            Navigator.pop(contextBottomSheet);
                            var noCompartir = await nextcloudApi.unshareFile(
                              int.parse(item.sharedId!),
                            );
                            if (!context.mounted) return;
                            if (noCompartir == true) {
                              setState(() {});
                              SnackbarManager.show(
                                context: context,
                                msg: 'El archivo ha dejado de ser compartido',
                              );
                            } else {
                              SnackbarManager.show(
                                context: context,
                                msg: 'Error al dejar de compartir',
                                error: true,
                              );
                            }
                          },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
