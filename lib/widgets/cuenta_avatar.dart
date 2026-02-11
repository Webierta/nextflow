import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/cuenta_nextcloud.dart';
import '../services/nextcloud_api/nextcloud_api.dart';

class CuentaAvatar extends StatefulWidget {
  final CuentaNextcloud cuenta;
  final double? size;

  const CuentaAvatar({super.key, required this.cuenta, this.size = 48});

  @override
  State<CuentaAvatar> createState() => _CuentaAvatarState();
}

class _CuentaAvatarState extends State<CuentaAvatar> {
  late NextcloudApi nextcloudApi;
  double size = 48;

  @override
  void initState() {
    nextcloudApi = NextcloudApi(cuenta: widget.cuenta);
    super.initState();
  }

  Future<Uint8List?>? getAvatar() async {
    var responseUserId = widget.cuenta.userId ?? await nextcloudApi.getUserId();
    if (responseUserId == null || responseUserId.isEmpty) return null;
    var responseAvatar = await nextcloudApi.getAvatar(responseUserId);
    widget.cuenta.avatar = responseAvatar;
    if (responseAvatar == null) return null;
    return responseAvatar;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cuenta.avatar != null &&
        widget.cuenta.statusAuth == StatusAuth.login) {
      return Badge(
        label: Text('✔'),
        backgroundColor: Colors.green,
        alignment: AlignmentGeometry.bottomRight,
        offset: Offset(0, -10),
        child: Image.memory(widget.cuenta.avatar!, height: widget.size),
      );
    }

    if (widget.cuenta.statusAuth != StatusAuth.login) {
      return Badge(
        label: Text('✖'),
        alignment: AlignmentGeometry.bottomRight,
        offset: Offset(0, -10),
        child: Icon(Icons.person_off, size: widget.size, color: Colors.grey),
      );
    }

    return FutureBuilder(
      future: getAvatar(),
      builder: (context, snapshot) {
        if (snapshot.hasData && widget.cuenta.statusAuth == StatusAuth.login) {
          return Badge(
            label: Text('✔'),
            backgroundColor: Colors.green,
            alignment: AlignmentGeometry.bottomRight,
            offset: Offset(0, -10),
            child: Image.memory(snapshot.data!, height: widget.size),
          );
        }
        return Badge(
          label: Text('✖'),
          alignment: AlignmentGeometry.bottomRight,
          offset: Offset(0, -10),
          child: Icon(Icons.person_off, size: widget.size, color: Colors.grey),
        );
      },
    );
  }
}
