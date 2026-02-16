import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/cuenta_nextcloud.dart';
import '../services/nextcloud_api/nextcloud_api.dart';

class CuentaAvatar extends StatefulWidget {
  final CuentaNextcloud cuenta;
  final double? size;
  final bool? onlyAvatar;

  const CuentaAvatar({
    super.key,
    required this.cuenta,
    this.size = 48,
    this.onlyAvatar = false,
  });

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
      if (widget.onlyAvatar == true) {
        return Image.memory(widget.cuenta.avatar!, height: size, width: size);
      }
      return BadgeAvatar(
        bytes: widget.cuenta.avatar!,
        size: widget.size ?? size,
      );
    }

    if (widget.cuenta.statusAuth != StatusAuth.login) {
      if (widget.onlyAvatar == true) {
        return Icon(Icons.person_off, size: size, color: Colors.grey);
      }
      return BadgePerson(size: widget.size ?? size);
    }

    return FutureBuilder(
      future: getAvatar(),
      builder: (context, snapshot) {
        if (snapshot.hasData && widget.cuenta.statusAuth == StatusAuth.login) {
          if (widget.onlyAvatar == true) {
            return Image.memory(
              widget.cuenta.avatar!,
              height: size,
              width: size,
            );
          }
          return BadgeAvatar(bytes: snapshot.data!, size: widget.size ?? size);
        }
        if (widget.onlyAvatar == true) {
          return Icon(Icons.person_off, size: size, color: Colors.grey);
        }
        return BadgePerson(size: widget.size ?? size);
      },
    );
  }
}

class BadgeAvatar extends StatelessWidget {
  final Uint8List bytes;
  final double size;

  const BadgeAvatar({super.key, required this.bytes, required this.size});

  @override
  Widget build(BuildContext context) {
    return Badge(
      label: Text('✔'),
      backgroundColor: Colors.green,
      alignment: AlignmentGeometry.bottomRight,
      offset: Offset(0, -10),
      child: Image.memory(bytes, height: size, width: size),
    );
  }
}

class BadgePerson extends StatelessWidget {
  final double size;

  const BadgePerson({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Badge(
      label: Text('✖'),
      alignment: AlignmentGeometry.bottomRight,
      offset: Offset(0, -10),
      child: Icon(Icons.person_off, size: size, color: Colors.grey),
    );
  }
}
