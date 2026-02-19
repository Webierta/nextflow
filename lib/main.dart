import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/cuenta_nextcloud.dart';
import 'providers/cuentas_provider.dart';
import 'screens/cuenta_screen.dart';
import 'services/storage_service.dart';
import 'styles/theme_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  Future<void> getStorage() async {
    var storage = await StorageService.getStorage();
    List<String> cuentasName = [];
    storage.forEach((key, value) {
      cuentasName.add(key);
    });
    List<CuentaNextcloud> cuentasStorage = [];
    for (var name in cuentasName) {
      var cuenta = await StorageService.getCuenta(name);
      if (cuenta != null) {
        cuentasStorage.add(cuenta);
      }
    }
    for (var cuenta in cuentasStorage) {
      ref.read(cuentasProvider.notifier).add(cuenta);
    }
  }

  @override
  void initState() {
    getStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeApp.lightThemeData,
      darkTheme: ThemeApp.darkThemeData,
      //home: CuentasScreen(),
      home: CuentaScreen(),
    );
  }
}
