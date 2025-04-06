import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../widgets/snack_bar.dart';

class PermissionHelper {
  static Future<void> requestCameraPermission(BuildContext context) async {
    var status = await Permission.camera.status;

    if (status.isDenied || status.isRestricted) {
      status = await Permission.camera.request();
    }

    if (status.isPermanentlyDenied) {
      showCustomSnackBar(context, 'Camera permission permanently denied. Please enable it in settings.', false);
      openAppSettings();
    } else if (!status.isGranted) {
      showCustomSnackBar(context, 'Camera permission denied', false);
    }
  }

  static Future<void> requestStoragePermission(BuildContext context) async {
    var status = await Permission.photos.status;

    if (status.isDenied || status.isRestricted) {
      status = await Permission.photos.request();
    }

    if (status.isPermanentlyDenied) {
      showCustomSnackBar(context, 'Storage permission permanently denied. Please enable it in settings.', false);
      openAppSettings();
    } else if (!status.isGranted) {
      showCustomSnackBar(context, 'Storage permission denied', false);
    }
  }
}


