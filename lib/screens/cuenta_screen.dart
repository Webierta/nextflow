import 'package:flutter/material.dart';

import '../models/cuenta_nextcloud.dart';
import '../models/destino.dart';
import '../styles/styles_app.dart';
import '../widgets/cuenta_avatar.dart';
import '../widgets/open_dialog.dart';
import 'files_screen.dart';

class CuentaScreen extends StatefulWidget {
  final CuentaNextcloud cuenta;

  const CuentaScreen({super.key, required this.cuenta});

  @override
  State<CuentaScreen> createState() => _CuentaScreenState();
}

class _CuentaScreenState extends State<CuentaScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: StylesApp.backgroundScreen(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leadingWidth: 30,
          title: FittedBox(
            child: Row(
              mainAxisAlignment: .start,
              children: [
                CuentaAvatar(cuenta: widget.cuenta, size: 30),
                const SizedBox(width: 20),
                Text(widget.cuenta.name, style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                final search = await OpenDialog.inputName(
                  context: context,
                  title: 'Search Global',
                  icon: Icons.search,
                  controller: searchController,
                );
                searchController.clear();
                if (search != null &&
                    search.trim().isNotEmpty &&
                    context.mounted) {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => FilesScreen(
                        cuenta: widget.cuenta,
                        inputSearch: search,
                      ),
                    ),
                  );
                }
              },
              icon: Icon(Icons.search, size: 30, color: Colors.white),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            double childAspectRatio =
                constraints.maxWidth / constraints.maxHeight;
            double sizeIcon = childAspectRatio * 150;
            double sizeFont = childAspectRatio * 30;
            return GridView.count(
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
                    onTap: destino.onPageRoute(
                      context: context,
                      cuenta: widget.cuenta,
                    ),
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
            );
          },
        ),
      ),
    );
  }
}
