// ========================================
// NUTRIENT LIST SCREEN - nutrient_list_screen.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/nutrient_model.dart';
import '../providers/nutrient_provider.dart';

import '../widgets/nutrient_form_dialog.dart';
import '../widgets/nutrient_overlay.dart';

class NutrientListScreen extends StatefulWidget {
  const NutrientListScreen({Key? key}) : super(key: key);

  @override
  State<NutrientListScreen> createState() => _NutrientListScreenState();
}

class _NutrientListScreenState extends State<NutrientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name'; // name, price, type, created
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    // Load data saat widget diinisialisasi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutrientProvider>().loadNutrients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<NutrientProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading nutrients...'),
                ],
              ),
            );
          }

          if (provider.hasError) {
            return _buildErrorWidget(provider);
          }

          if (!provider.hasNutrients) {
            return _buildEmptyWidget();
          }

          return _buildNutrientList(provider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNutrientDialog(),
        tooltip: 'Add Nutrient',
        child: const Icon(Icons.add),
      ),
      // drawer: _buildStatsDrawer(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Nutrients'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<NutrientProvider>().refresh(),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildErrorWidget(NutrientProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.science_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No Nutrients Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Start by adding your first nutrient',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddNutrientDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Nutrient'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientList(NutrientProvider provider) {
    final sortedNutrients = _getSortedNutrients(provider.filteredNutrients);

    return Column(
      children: [
        // Search and Filter Section
        _buildSearchAndFilterSection(provider),

        // Results Info
        _buildResultsInfo(provider),

        // Nutrient List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              itemCount: sortedNutrients.length,
              itemBuilder: (context, index) {
                final nutrient = sortedNutrients[index];
                return _buildNutrientCard(nutrient, provider);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterSection(NutrientProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: provider.setSearchQuery,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search by name, formula, or nutrients...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  provider.searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: provider.selectedType == 'All',
                  onSelected: (_) => provider.setTypeFilter('All'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Type A'),
                  selected: provider.selectedType == 'A',
                  onSelected: (_) => provider.setTypeFilter('A'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Type B'),
                  selected: provider.selectedType == 'B',
                  onSelected: (_) => provider.setTypeFilter('B'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsInfo(NutrientProvider provider) {
    if (provider.filteredNutrients.isEmpty && provider.searchQuery.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'No results found for "${provider.searchQuery}"',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${provider.filteredNutrients.length} of ${provider.nutrients.length} nutrients',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (provider.searchQuery.isNotEmpty || provider.selectedType != 'All')
            TextButton(
              onPressed: () => provider.clearFilters(),
              child: const Text('Clear Filters'),
            ),
        ],
      ),
    );
  }

  Widget _buildNutrientCard(NutrientModel nutrient, NutrientProvider provider) {
    final isSelected = provider.selectedNutrient?.id == nutrient.id;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isSelected ? 4 : 1,
      color:
          isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: nutrient.type == 'A' ? Colors.blue : Colors.green,
          child: Text(
            nutrient.type,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          nutrient.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Formula: ${nutrient.formula}'),
            const SizedBox(height: 2),
            Text('Nutrients: ${nutrient.nutrientProfile}'),
            const SizedBox(height: 2),
            Text(
              'Price: \Rp. ${nutrient.pricePerKg.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}/kg',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected:
              (value) => _handleNutrientAction(value, nutrient, provider),
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy),
                      SizedBox(width: 8),
                      Text('Duplicate'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
        ),
        onTap: () {
          provider.selectNutrient(isSelected ? null : nutrient);
          _showNutrientDetails(nutrient);
        },
        selected: isSelected,
      ),
    );
  }

  List<NutrientModel> _getSortedNutrients(List<NutrientModel> nutrients) {
    final sorted = List<NutrientModel>.from(nutrients);

    sorted.sort((a, b) {
      int comparison = 0;

      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'price':
          comparison = a.pricePerKg.compareTo(b.pricePerKg);
          break;
        case 'type':
          comparison = a.type.compareTo(b.type);
          break;
        case 'created':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sorted;
  }

  void _handleNutrientAction(
    String action,
    NutrientModel nutrient,
    NutrientProvider provider,
  ) {
    switch (action) {
      case 'view':
        _showNutrientDetails(nutrient);
        break;
      case 'edit':
        _showEditNutrientDialog(nutrient);
        break;
      case 'duplicate':
        _duplicateNutrient(nutrient);
        break;
      case 'delete':
        _showDeleteConfirmation(nutrient, provider);
        break;
    }
  }

  void _showAddNutrientDialog() {
    showDialog(context: context, builder: (context) => NutrientFormDialog());
  }

  void _showEditNutrientDialog(NutrientModel nutrient) {
    showDialog(
      context: context,
      builder: (context) => NutrientFormDialog(nutrient: nutrient),
    );
  }

  void _showNutrientDetails(NutrientModel nutrient) {
    showDialog(
      context: context,
      builder: (context) => NutrientDetailsDialog(nutrient: nutrient),
    );
  }

  void _duplicateNutrient(NutrientModel nutrient) {
    final duplicatedNutrient = nutrient.copyWith(
      id: null,
      name: '${nutrient.name} (Copy)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    showDialog(
      context: context,
      builder: (context) => NutrientFormDialog(nutrient: duplicatedNutrient),
    );
  }

  void _showDeleteConfirmation(
    NutrientModel nutrient,
    NutrientProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Nutrient'),
            content: Text(
              'Are you sure you want to delete "${nutrient.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final success = await provider.deleteNutrient(nutrient.id!);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Nutrient deleted successfully'
                              : 'Failed to delete nutrient',
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
