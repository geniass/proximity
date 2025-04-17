import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request location permission and return whether it was granted
  static Future<bool> requestLocationPermission() async {
    // Check current permission status
    final status = await Permission.location.status;
    
    if (status.isGranted) {
      // Permission is already granted
      return true;
    }
    
    if (status.isPermanentlyDenied) {
      // Permission is permanently denied, can only be changed in app settings
      return false;
    }
    
    // Request the permission
    final result = await Permission.location.request();
    return result.isGranted;
  }
}