import 'package:flutter/material.dart';

import '../screens/add_cuenta_screen.dart';
import '../screens/info_screen.dart';
import '../screens/settings_screen.dart';
import '../styles/styles_app.dart';

class DrawerApp extends StatelessWidget {
  const DrawerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: double.infinity,
      child: Container(
        decoration: StylesApp.backgroundScreen(context),
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
                    ),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        FittedBox(
                          child: Row(
                            mainAxisAlignment: .start,
                            crossAxisAlignment: .end,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Nextflow',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/images/Nextcloud-logo-blue-small.png',
                                    height: 80,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: .start,
                                children: [
                                  Text(
                                    'Open source Nextcloud client',
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Cloud workflow',
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Up, down and share',
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                                Text('Shared', style: TextStyle(fontSize: 12)),
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
                                Text('Gallery', style: TextStyle(fontSize: 12)),
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
    );
  }
}
