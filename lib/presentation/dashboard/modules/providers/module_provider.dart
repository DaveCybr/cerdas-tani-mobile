// presentation/dashboard/modules/providers/module_provider.dart
import 'package:flutter/material.dart';
import '../models/module_model.dart';
import '../services/module_service.dart';

class ModuleProvider extends ChangeNotifier {
  final ModuleService _moduleService = ModuleService();

  // State variables
  List<Module> _modules = [];
  Module? _selectedModule;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Pagination
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalModules = 0;
  bool _hasMoreData = true;

  // Download state
  bool _isDownloading = false;
  String? _downloadProgress;

  // Getters
  List<Module> get modules => _modules;
  Module? get selectedModule => _selectedModule;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get totalModules => _totalModules;
  bool get hasMoreData => _hasMoreData;
  bool get hasData => _modules.isNotEmpty;
  bool get isDownloading => _isDownloading;
  String? get downloadProgress => _downloadProgress;

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load initial modules
  Future<void> loadModules({bool refresh = false}) async {
    if (refresh) {
      _modules.clear();
      _currentPage = 1;
      _hasMoreData = true;
      _searchQuery = '';
    }

    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _moduleService.getModules(
        page: _currentPage,
        perPage: 10,
      );

      _modules = response.data;
      _lastPage = response.lastPage;
      _totalModules = response.total;
      _hasMoreData = _currentPage < _lastPage;

      print('Loaded ${_modules.length} modules.');

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error loading modules: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more modules for pagination
  Future<void> loadMoreModules() async {
    if (_isLoadingMore || !_hasMoreData || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;

      ModuleResponse response;
      if (_searchQuery.isNotEmpty) {
        response = await _moduleService.searchModules(
          query: _searchQuery,
          page: nextPage,
          perPage: 10,
        );
      } else {
        response = await _moduleService.getModules(page: nextPage, perPage: 10);
      }

      _modules.addAll(response.data);
      _currentPage = nextPage;
      _lastPage = response.lastPage;
      _totalModules = response.total;
      _hasMoreData = _currentPage < _lastPage;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error loading more modules: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Search modules
  Future<void> searchModules(String query) async {
    if (_isLoading) return;

    _searchQuery = query.trim();
    _modules.clear();
    _currentPage = 1;
    _hasMoreData = true;

    if (_searchQuery.isEmpty) {
      await loadModules();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _moduleService.searchModules(
        query: _searchQuery,
        page: 1,
        perPage: 10,
      );

      _modules = response.data;
      _lastPage = response.lastPage;
      _totalModules = response.total;
      _hasMoreData = _currentPage < _lastPage;

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error searching modules: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    loadModules(refresh: true);
  }

  // Get module by ID
  Future<void> getModuleById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedModule = null;
    notifyListeners();

    try {
      final module = await _moduleService.getModuleById(id);
      _selectedModule = module;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error getting module by ID: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear selected module
  void clearSelectedModule() {
    _selectedModule = null;
    notifyListeners();
  }

  // Download module attachment with improved handling
  Future<String?> downloadModuleAttachment(Module module) async {
    if (module.attachment == null) {
      _errorMessage = 'No attachment available for this module';
      notifyListeners();
      return null;
    }

    _isDownloading = true;
    _downloadProgress = 'Preparing download...';
    _errorMessage = null;
    notifyListeners();

    try {
      _downloadProgress = 'Checking file availability...';
      notifyListeners();

      // First check if file exists
      final exists = await _moduleService.checkAttachmentExists(
        module.attachment!,
      );
      if (!exists) {
        throw Exception('File not found on server. Please contact support.');
      }

      _downloadProgress = 'Downloading file...';
      notifyListeners();

      // Download the file
      final filePath = await _moduleService.downloadModuleAttachment(module);

      _downloadProgress = 'Download completed!';
      notifyListeners();

      debugPrint('Module downloaded successfully: ${module.name} to $filePath');

      // Clear progress after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        _downloadProgress = null;
        notifyListeners();
      });

      return filePath;
    } catch (e) {
      _errorMessage = e.toString();
      _downloadProgress = null;
      debugPrint('Error downloading module: $e');
      notifyListeners();
      return null;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  // Check if module attachment exists
  Future<bool> checkModuleAttachment(Module module) async {
    if (module.attachment == null) return false;

    try {
      return await _moduleService.checkAttachmentExists(module.attachment!);
    } catch (e) {
      debugPrint('Error checking module attachment: $e');
      return false;
    }
  }

  // Get correct download URL for a module
  Future<String?> getModuleDownloadUrl(Module module) async {
    if (module.attachment == null) return null;

    try {
      return await _moduleService.getCorrectDownloadUrl(module.attachment!);
    } catch (e) {
      debugPrint('Error getting download URL: $e');
      return null;
    }
  }

  // Get filtered modules by status
  List<Module> getActiveModules() {
    return _modules.where((module) => module.isActive).toList();
  }

  // Get modules count
  int get activeModulesCount {
    return _modules.where((module) => module.isActive).length;
  }

  // Clear download state
  void clearDownloadState() {
    _isDownloading = false;
    _downloadProgress = null;
    notifyListeners();
  }
}
