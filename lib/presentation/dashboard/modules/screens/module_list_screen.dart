// presentation/dashboard/modules/screens/module_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/navigations/app_navigator.dart';
import '../models/module_model.dart';
import '../providers/module_provider.dart';
import '../widgets/module_card.dart';

class ModuleListScreen extends StatefulWidget {
  const ModuleListScreen({Key? key}) : super(key: key);

  @override
  State<ModuleListScreen> createState() => _ModuleListScreenState();
}

class _ModuleListScreenState extends State<ModuleListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Initialize modules
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ModuleProvider>(context, listen: false).loadModules();
    });

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near bottom
      Provider.of<ModuleProvider>(context, listen: false).loadMoreModules();
    }
  }

  void _onSearchChanged(String value) {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == value) {
        Provider.of<ModuleProvider>(
          context,
          listen: false,
        ).searchModules(value);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    Provider.of<ModuleProvider>(context, listen: false).clearSearch();
  }

  Future<void> _refreshModules() async {
    await Provider.of<ModuleProvider>(
      context,
      listen: false,
    ).loadModules(refresh: true);
  }

  void _onModuleTap(Module module) {
    // Navigate to module detail
    AppNavigator.push('/module/detail', arguments: module);
  }

  void _onDownloadModule(Module module) async {
    final provider = Provider.of<ModuleProvider>(context, listen: false);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Downloading...'),
              ],
            ),
          ),
    );

    final String? result = await provider.downloadModuleAttachment(module);
    final bool success = result != null;

    // Close loading dialog
    if (mounted) Navigator.of(context).pop();

    // Show result
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Module downloaded successfully' : 'Download failed',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // appBar: AppBar(
      //   title: const Text(
      //     'Learning Modules',
      //     style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      //   ),
      //   backgroundColor: AppColors.primary,
      //   elevation: 0,
      //   iconTheme: const IconThemeData(color: Colors.white),
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  // Page Title
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Learning Modules',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search modules...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      suffixIcon: Consumer<ModuleProvider>(
                        builder: (context, provider, child) {
                          return provider.searchQuery.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                color: Colors.grey[400],
                                onPressed: _clearSearch,
                              )
                              : const SizedBox.shrink();
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Search Section
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: AppColors.primary,
            //     borderRadius: const BorderRadius.only(
            //       bottomLeft: Radius.circular(20),
            //       bottomRight: Radius.circular(20),
            //     ),
            //   ),
            //   child: TextField(
            //     controller: _searchController,
            //     onChanged: _onSearchChanged,
            //     decoration: InputDecoration(
            //       hintText: 'Search modules...',
            //       hintStyle: TextStyle(color: Colors.grey[400]),
            //       prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            //       suffixIcon: Consumer<ModuleProvider>(
            //         builder: (context, provider, child) {
            //           return provider.searchQuery.isNotEmpty
            //               ? IconButton(
            //                 icon: const Icon(Icons.clear),
            //                 color: Colors.grey[400],
            //                 onPressed: _clearSearch,
            //               )
            //               : const SizedBox.shrink();
            //         },
            //       ),
            //       filled: true,
            //       fillColor: Colors.white,
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(12),
            //         borderSide: BorderSide.none,
            //       ),
            //       contentPadding: const EdgeInsets.symmetric(
            //         horizontal: 16,
            //         vertical: 12,
            //       ),
            //     ),
            //   ),
            // ),

            // Modules List
            Expanded(
              child: Consumer<ModuleProvider>(
                builder: (context, provider, child) {
                  // Error State
                  if (provider.errorMessage != null && !provider.hasData) {
                    return _buildErrorState(provider);
                  }

                  // Loading State (initial)
                  if (provider.isLoading && !provider.hasData) {
                    return _buildLoadingState();
                  }

                  // Empty State
                  if (!provider.hasData && !provider.isLoading) {
                    return _buildEmptyState(provider);
                  }

                  // Content State
                  return _buildContentState(provider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ModuleProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Unknown error occurred',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                provider.clearError();
                provider.loadModules(refresh: true);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Loading modules...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ModuleProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              provider.searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.library_books_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              provider.searchQuery.isNotEmpty
                  ? 'No modules found'
                  : 'No modules available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.searchQuery.isNotEmpty
                  ? 'Try different search terms'
                  : 'Check back later for new learning modules',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (provider.searchQuery.isNotEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _clearSearch,
                icon: const Icon(Icons.clear),
                label: const Text('Clear Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContentState(ModuleProvider provider) {
    return RefreshIndicator(
      onRefresh: _refreshModules,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: provider.modules.length + (provider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading more indicator
          if (index == provider.modules.length) {
            return _buildLoadMoreIndicator();
          }

          final module = provider.modules[index];
          return ModuleCard(
            module: module,
            onTap: () => _onModuleTap(module),
            onDownload:
                module.attachment != null
                    ? () => _onDownloadModule(module)
                    : null,
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: AppColors.primary),
    );
  }
}
