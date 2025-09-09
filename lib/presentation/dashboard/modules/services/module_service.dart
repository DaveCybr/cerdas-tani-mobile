// presentation/dashboard/modules/services/module_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/module_model.dart';

class ModuleService {
  static const String baseUrl = 'http://sirangga.satelliteorbit.cloud/api';

  // Get modules with pagination
  Future<ModuleResponse> getModules({int page = 1, int perPage = 10}) async {
    try {
      final url = Uri.parse('$baseUrl/modules?page=$page&per_page=$perPage');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ModuleResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load modules: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get module by ID
  Future<Module?> getModuleById(int id) async {
    try {
      final url = Uri.parse('$baseUrl/modules/$id');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Module.fromJson(jsonData['data']);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load module: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Search modules by name
  Future<ModuleResponse> searchModules({
    required String query,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/modules/search?q=$query&page=$page&per_page=$perPage',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ModuleResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to search modules: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Request proper storage permissions based on Android version
  Future<bool> _requestStoragePermissions() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      print('Android SDK: $sdkInt');

      if (sdkInt >= 33) {
        // Android 13+ (API 33+) - Use scoped storage permissions
        final List<Permission> permissions = [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ];

        Map<Permission, PermissionStatus> statuses =
            await permissions.request();
        bool allGranted = statuses.values.every((status) => status.isGranted);

        if (!allGranted) {
          print('Media permissions not granted');
          return false;
        }
        return true;
      } else if (sdkInt >= 30) {
        // Android 11-12 (API 30-32) - Use MANAGE_EXTERNAL_STORAGE for Downloads
        var status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.request();
        }

        if (!status.isGranted) {
          // Fallback to regular storage permission
          status = await Permission.storage.request();
        }

        return status.isGranted;
      } else {
        // Android 10 and below - Use regular storage permission
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        return status.isGranted;
      }
    }
    return true; // iOS doesn't need explicit permissions for app documents
  }

  // Get appropriate download directory based on platform and permissions
  Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      try {
        // Try to use Downloads directory first
        Directory? downloadDir = Directory('/storage/emulated/0/Download');
        if (await downloadDir.exists()) {
          return downloadDir;
        }

        // Fallback to external storage directory
        downloadDir = await getExternalStorageDirectory();
        if (downloadDir != null) {
          return downloadDir;
        }

        // Last fallback to application documents directory
        return await getApplicationDocumentsDirectory();
      } catch (e) {
        print('Error getting download directory: $e');
        return await getApplicationDocumentsDirectory();
      }
    } else {
      // iOS - use documents directory
      return await getApplicationDocumentsDirectory();
    }
  }

  // Download module attachment with improved permission handling
  Future<String> downloadModuleAttachment(Module module) async {
    if (module.attachment == null) {
      throw Exception('No attachment available for this module');
    }

    try {
      // Request storage permissions
      bool hasPermission = await _requestStoragePermissions();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Try different URL formats to find the correct one
      List<String> possibleUrls = [
        'http://sirangga.satelliteorbit.cloud/public/storage/${module.attachment}',
        module.fullAttachmentUrl ?? '',
      ];

      http.Response? response;
      String? workingUrl;

      // Try each URL until we find one that works
      for (String url in possibleUrls) {
        if (url.isEmpty) continue;

        try {
          print('Trying to download from: $url');
          response = await http.get(
            Uri.parse(url),
            headers: {'Accept': '*/*', 'User-Agent': 'Flutter App'},
          );

          if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
            workingUrl = url;
            print('Successfully found file at: $url');
            break;
          }
        } catch (e) {
          print('Failed to access $url: $e');
          continue;
        }
      }

      if (response == null ||
          response.statusCode != 200 ||
          workingUrl == null) {
        throw Exception('File not found on server. Please contact support.');
      }

      // Get download directory
      Directory? downloadDir = await _getDownloadDirectory();

      if (downloadDir == null) {
        throw Exception('Could not access download directory');
      }

      // Ensure directory exists
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // Create filename
      String filename = module.attachment!.split('/').last;
      if (!filename.contains('.')) {
        filename =
            '${module.slug}_module.pdf'; // Default to PDF if no extension
      }

      // Sanitize filename
      filename = filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

      final filePath = '${downloadDir.path}/$filename';
      final file = File(filePath);

      // Write file
      await file.writeAsBytes(response.bodyBytes);

      print('File downloaded successfully to: $filePath');
      return filePath;
    } catch (e) {
      print('Download error details: $e');
      if (e.toString().contains('Storage permission denied')) {
        throw Exception('Storage permission denied');
      }
      throw Exception('Download failed: ${e.toString()}');
    }
  }

  // Check if attachment exists with better URL checking
  Future<bool> checkAttachmentExists(String attachmentPath) async {
    List<String> possibleUrls = [
      'http://sirangga.satelliteorbit.cloud/public/storage/$attachmentPath',
    ];

    for (String url in possibleUrls) {
      try {
        final response = await http.head(Uri.parse(url));
        if (response.statusCode == 200) {
          print('File exists at: $url');
          return true;
        }
      } catch (e) {
        continue;
      }
    }

    print('File not found at any URL for: $attachmentPath');
    return false;
  }

  // Get the correct download URL for a module
  Future<String?> getCorrectDownloadUrl(String attachmentPath) async {
    List<String> possibleUrls = [
      'http://sirangga.satelliteorbit.cloud/public/storage/$attachmentPath',
    ];

    for (String url in possibleUrls) {
      try {
        final response = await http.head(Uri.parse(url));
        if (response.statusCode == 200) {
          return url;
        }
      } catch (e) {
        continue;
      }
    }

    return null;
  }
}
