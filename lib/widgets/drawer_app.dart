import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../screens/add_cuenta_screen.dart';
import '../screens/info_screen.dart';
import '../screens/settings_screen.dart';
import '../styles/styles_app.dart';

class DrawerApp extends StatefulWidget {
  const DrawerApp({super.key});

  @override
  State<DrawerApp> createState() => _DrawerAppState();
}

class _DrawerAppState extends State<DrawerApp> {
  PackageInfo packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    initPackageInfo();
    super.initState();
  }

  Future<void> initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => packageInfo = info);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        width: double.infinity,
        child: Container(
          decoration: StylesApp.backgroundScreen(context),
          //padding: .only(top: 20),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 260,
                    child: DrawerHeader(
                      decoration: BoxDecoration(
                        border: BoxBorder.all(
                          color: Colors.transparent,
                          width: 0,
                        ),
                        color: .new(0x660082C9),
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/Nextcloud-logo-blue-small.png',
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Nextflow',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                          //Icon(Icons.cloud_done, size: 42),
                          Text(
                            'Nextcloud client',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Version ${packageInfo.version}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Cloud workflow: Up Down Share',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: .spaceEvenly,
                            children: [
                              Column(
                                mainAxisSize: .min,
                                children: [
                                  CircleAvatar(
                                    child: Icon(Icons.file_copy_outlined),
                                  ),
                                  Text('Files', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                              Column(
                                mainAxisSize: .min,
                                children: [
                                  CircleAvatar(
                                    child: Icon(Icons.folder_shared_outlined),
                                  ),
                                  Text(
                                    'Shared',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisSize: .min,
                                children: [
                                  CircleAvatar(
                                    child: Icon(Icons.article_outlined),
                                  ),
                                  Text('Notes', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                              Column(
                                mainAxisSize: .min,
                                children: [
                                  CircleAvatar(
                                    child: Icon(Icons.photo_library_outlined),
                                  ),
                                  Text(
                                    'Gallery',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton.filled(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close, color: Colors.black),
                    ),
                  ),
                ],
              ),
              ListTile(
                leading: Icon(Icons.account_circle_rounded),
                title: const Text('Add Count'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const AddCuentaScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              const Divider(color: Colors.white30, indent: 20, endIndent: 20),
              ListTile(
                leading: Icon(Icons.info_outline_rounded),
                title: const Text('Info'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const InfoScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.code),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
