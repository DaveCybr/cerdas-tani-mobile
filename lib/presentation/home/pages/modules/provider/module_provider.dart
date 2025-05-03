// providers/download_module_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/module_model.dart';

class ModuleProvider extends ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(
    contentType: 'application/json',
  ));
  List<Module> _modules = [];

  List<Module> get modules => _modules;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = 'Terjadi kesalahan';
  String get errorMessage => _errorMessage;

  Future<void> fetchModules() async {
    try {
      final response = await _dio.get(
        'http://sirangga.satelliteorbit.cloud/api/modules',
      );
      print("Response Data: ${response.data}");

      if (response.statusCode == 200) {
        final modulesResponse = ModuleModel.fromMap(response.data);
        _modules = modulesResponse.data;
        _isLoading = false;
        print("Parsed Module: ${_modules.length} module ditemukan");
        notifyListeners();
      } else {
        _errorMessage = response.statusMessage ?? 'Terdapat kesalahan';
        _isLoading = false;
        print("Else Condition: $_errorMessage");
        notifyListeners();
      }
    } catch (e, stacktrace) {
      _errorMessage = 'Gagal mengambil data: ${e.toString()}';
      _isLoading = false;
      print('Error: $e');
      print('Stacktrace: $stacktrace'); // Debugging Stacktrace
      notifyListeners();
    } catch (e, stacktrace) {
      print('Error: $e');
      print('Stacktrace: $stacktrace'); // Debugging Stacktrace
    }
  }
}
