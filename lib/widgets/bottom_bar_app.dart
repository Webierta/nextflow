import 'package:flutter/material.dart';

import '../models/cuenta_nextcloud.dart';
import '../models/destino.dart';
import '../screens/cuenta_screen.dart';

class BottomBarApp extends StatelessWidget {
  final CuentaNextcloud cuenta;
  final Destino destino;

  const BottomBarApp({super.key, required this.cuenta, required this.destino});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton.filledTonal(
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
          for (var dest in Destino.values)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                tooltip: dest.name,
                icon: Icon(
                  dest.icon,
                  size: 32,
                  color: dest == destino ? Colors.blue : Colors.grey,
                ),
                onPressed: dest.onPageRoute(context: context, cuenta: cuenta),
              ),
            ),
        ],
      ),
    );
  }
}
