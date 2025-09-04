// presentation/dashboard/modules/services/module_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
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

  // Download module attachment
  Future<http.Response> downloadModuleAttachment(String attachmentPath) async {
    try {
      final url = Uri.parse(
        'http://sirangga.satelliteorbit.cloud/$attachmentPath',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Download error: $e');
    }
  }

  // Check if attachment exists
  Future<bool> checkAttachmentExists(String attachmentPath) async {
    try {
      final url = Uri.parse(
        'http://sirangga.satelliteorbit.cloud/$attachmentPath',
      );

      final response = await http.head(url);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
