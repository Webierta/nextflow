import 'package:flutter/material.dart';

import '../models/cuenta_nextcloud.dart';
import '../models/destino.dart';
import '../screens/cuenta_screen.dart';

class BottomBarApp extends StatelessWidget {
  final CuentaNextcloud cuenta;

  const BottomBarApp({super.key, required this.cuenta});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              tooltip: 'Home',
              icon: const Icon(Icons.home, size: 32),
              onPressed: () {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => CuentaScreen(cuentaSelect: cuenta),
                  ),
                );
              },
            ),
          ),
          for (var destino in Destino.values)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: IconButton(
                tooltip: destino.name,
                icon: Icon(destino.icon, size: 32),
                onPressed: destino.onPageRoute(
                  context: context,
                  cuenta: cuenta,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
