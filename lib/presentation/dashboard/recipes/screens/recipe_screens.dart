// ========================================
// Complete HydroBuddy-style Recipe Screen - recipe_screen.dart
// ========================================

import 'package:fertilizer_calculator_mobile_v2/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';
import '../services/database_service.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({Key? key}) : super(key: key);

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().loadRecipes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetDatabase() async {
    try {
      await DatabaseService.instance.resetDatabase();
      if (mounted) {
        context.read<RecipeProvider>().loadRecipes();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database reset with default HydroBuddy recipes'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset database: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Recipes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<RecipeProvider>().refresh(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset_db') {
                _resetDatabase();
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'reset_db',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Reset to Defaults'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<RecipeProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${provider.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        provider.clearError();
                        provider.loadRecipes();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                _buildSearchAndFilter(provider),
                Expanded(child: _buildRecipeList(provider)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRecipeDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ========================================
  // Fixed Recipe Screen Search & Filter Methods
  // ========================================

  Widget _buildSearchAndFilter(RecipeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search recipes or crops...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.clearSearch();
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              provider.searchRecipes(value);
              setState(() {}); // Update UI to show/hide clear button
            },
            style: TextStyle(color: AppColors.darkText),
          ),
          const SizedBox(height: 12),
          // Type Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  provider.getAvailableTypes().map((type) {
                    final isSelected = provider.selectedType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (_) => provider.filterByType(type),
                        backgroundColor: Colors.grey[200],
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList(RecipeProvider provider) {
    // Fixed: Check if filtered recipes are empty
    if (provider.allRecipes.isEmpty && !provider.isLoading) {
      // No recipes at all
      if (provider.searchQuery.isEmpty && provider.selectedType == 'ALL') {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.science, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No recipes found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Tap + to add your first recipe',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      } else {
        // No results for current search/filter
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                provider.searchQuery.isNotEmpty
                    ? 'No recipes match "${provider.searchQuery}"'
                    : 'No recipes found for ${provider.selectedType}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  provider.clearFilters();
                },
                child: const Text('Clear Filters'),
              ),
            ],
          ),
        );
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.allRecipes.length,
      itemBuilder: (context, index) {
        final recipe = provider.allRecipes[index];
        return _buildRecipeCard(recipe, provider);
      },
    );
  }

  Widget _buildRecipeCard(RecipeModel recipe, RecipeProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showRecipeDetails(recipe),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(children: [_buildTypeChip(recipe.type)]),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showRecipeDialog(context, recipe: recipe);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(recipe, provider);
                          break;
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Primary nutrients in HydroBuddy style
              _buildNutrientRow(
                'Primary',
                'N: ${recipe.totalNitrogen.toStringAsFixed(1)} | '
                    'P: ${recipe.phosphorus.toStringAsFixed(1)} | '
                    'K: ${recipe.potassium.toStringAsFixed(1)} | '
                    'Ca: ${recipe.calcium.toStringAsFixed(1)}',
              ),

              const SizedBox(height: 8),
              // Nitrogen ratio indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getNitrogenRatioColor(recipe.nitrateRatio),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'NO3:NH4 = ${recipe.nitrateRatio.toStringAsFixed(0)}:${recipe.ammoniumRatio.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    Color color;
    switch (type) {
      case 'VEGETATIVE':
        color = Colors.green;
        break;
      case 'GENERATIVE':
        color = Colors.orange;
        break;
      case 'BLOOM':
        color = Colors.purple;
        break;
      case 'BALANCED':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String label, String values) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            values,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }

  Color _getNitrogenRatioColor(double nitrateRatio) {
    if (nitrateRatio >= 90) return Colors.green; // High nitrate (vegetative)
    if (nitrateRatio >= 80) return Colors.lightGreen;
    if (nitrateRatio >= 70) return Colors.orange; // Balanced
    return Colors.red; // High ammonium (generative)
  }

  void _showRecipeDialog(BuildContext context, {RecipeModel? recipe}) {
    showDialog(
      context: context,
      builder: (context) => RecipeFormDialog(recipe: recipe),
    );
  }

  void _showRecipeDetails(RecipeModel recipe) {
    showDialog(
      context: context,
      builder: (context) => RecipeDetailsDialog(recipe: recipe),
    );
  }

  void _showDeleteConfirmation(RecipeModel recipe, RecipeProvider provider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Recipe'),
            content: Text('Are you sure you want to delete "${recipe.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await provider.deleteRecipe(recipe.id!);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${recipe.name} deleted'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to delete recipe: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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

// ========================================
// HydroBuddy-style Recipe Details Dialog
// ========================================

class RecipeDetailsDialog extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeDetailsDialog({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Primary Nutrients
                    _buildSection('🧪 Primary Nutrients (ppm)', [
                      'N (NO₃⁻): ${recipe.nitrateNitrogen.toStringAsFixed(1)}',
                      'N (NH₄⁺): ${recipe.ammoniumNitrogen.toStringAsFixed(1)}',
                      'Total N: ${recipe.totalNitrogen.toStringAsFixed(1)}',
                      'P: ${recipe.phosphorus.toStringAsFixed(1)}',
                      'K: ${recipe.potassium.toStringAsFixed(1)}',
                      'Ca: ${recipe.calcium.toStringAsFixed(1)}',
                      'Mg: ${recipe.magnesium.toStringAsFixed(1)}',
                      'S: ${recipe.sulfur.toStringAsFixed(1)}',
                    ]),
                    const SizedBox(height: 16),

                    // Micronutrients
                    _buildSection('⚛️ Micronutrients (ppm)', [
                      'Fe: ${recipe.iron.toStringAsFixed(2)}',
                      'Mn: ${recipe.manganese.toStringAsFixed(2)}',
                      'Zn: ${recipe.zinc.toStringAsFixed(2)}',
                      'B: ${recipe.boron.toStringAsFixed(2)}',
                      'Cu: ${recipe.copper.toStringAsFixed(2)}',
                      'Mo: ${recipe.molybdenum.toStringAsFixed(3)}',
                    ]),
                    const SizedBox(height: 16),

                    // Nitrogen Ratio Analysis
                    _buildSection('📊 Nitrogen Analysis', [
                      'NO₃⁻:NH₄⁺ ratio = ${recipe.nitrateRatio.toStringAsFixed(0)}:${recipe.ammoniumRatio.toStringAsFixed(0)}',
                      _getNitrogenAnalysis(recipe.nitrateRatio),
                    ]),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  String _getNitrogenAnalysis(double nitrateRatio) {
    if (nitrateRatio >= 90) {
      return 'High nitrate - Promotes vegetative growth (leaves, stems)';
    } else if (nitrateRatio >= 80) {
      return 'Balanced nitrogen - Good for general growth';
    } else if (nitrateRatio >= 70) {
      return 'Moderate ammonium - Transitioning to generative';
    } else {
      return 'High ammonium - Promotes generative growth (flowers, fruits)';
    }
  }
}

// ========================================
// Complete HydroBuddy-style Recipe Form Dialog
// ========================================

class RecipeFormDialog extends StatefulWidget {
  final RecipeModel? recipe;

  const RecipeFormDialog({Key? key, this.recipe}) : super(key: key);

  @override
  State<RecipeFormDialog> createState() => _RecipeFormDialogState();
}

class _RecipeFormDialogState extends State<RecipeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();

  // Primary nutrient controllers (HydroBuddy inputs)
  final _nitrateNitrogenController = TextEditingController();
  final _ammoniumNitrogenController = TextEditingController();
  final _calciumController = TextEditingController();
  final _sulfurController = TextEditingController();
  final _potassiumController = TextEditingController();
  final _phosphorusController = TextEditingController();
  final _magnesiumController = TextEditingController();

  // Micronutrient controllers
  final _ironController = TextEditingController();
  final _manganeseController = TextEditingController();
  final _zincController = TextEditingController();
  final _boronController = TextEditingController();
  final _copperController = TextEditingController();
  final _molybdenumController = TextEditingController();

  bool _isLoading = false;
  String _selectedType = 'VEGETATIVE';

  // Common plant types for dropdown
  final List<String> _plantTypes = [
    'VEGETATIVE',
    'GENERATIVE',
    'BLOOM',
    'BALANCED',
    'CUSTOM',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _populateFields(widget.recipe!);
    } else {
      // Set default micronutrient values for new recipes
      _setDefaultMicronutrients();
    }
  }

  void _populateFields(RecipeModel recipe) {
    _nameController.text = recipe.name;
    _selectedType = recipe.type;

    _nitrateNitrogenController.text = recipe.nitrateNitrogen.toString();
    _ammoniumNitrogenController.text = recipe.ammoniumNitrogen.toString();
    _calciumController.text = recipe.calcium.toString();
    _sulfurController.text = recipe.sulfur.toString();
    _potassiumController.text = recipe.potassium.toString();
    _phosphorusController.text = recipe.phosphorus.toString();
    _magnesiumController.text = recipe.magnesium.toString();

    _ironController.text = recipe.iron.toString();
    _manganeseController.text = recipe.manganese.toString();
    _zincController.text = recipe.zinc.toString();
    _boronController.text = recipe.boron.toString();
    _copperController.text = recipe.copper.toString();
    _molybdenumController.text = recipe.molybdenum.toString();
  }

  void _setDefaultMicronutrients() {
    // Set standard micronutrient values
    _ironController.text = '3.0';
    _manganeseController.text = '0.8';
    _zincController.text = '0.3';
    _boronController.text = '0.3';
    _copperController.text = '0.1';
    _molybdenumController.text = '0.05';
  }

  void _loadPreset(String presetType) {
    switch (presetType) {
      case 'lettuce':
        _loadLettucePreset();
        break;
      case 'tomato_veg':
        _loadTomatoVegPreset();
        break;
      case 'tomato_gen':
        _loadTomatoGenPreset();
        break;
      case 'cucumber':
        _loadCucumberPreset();
        break;
    }
    setState(() {}); // Refresh the form
  }

  void _loadLettucePreset() {
    _nitrateNitrogenController.text = '190';
    _ammoniumNitrogenController.text = '10';
    _calciumController.text = '170';
    _sulfurController.text = '30';
    _potassiumController.text = '210';
    _phosphorusController.text = '40';
    _magnesiumController.text = '40';

    _selectedType = 'VEGETATIVE';
  }

  void _loadTomatoVegPreset() {
    _nitrateNitrogenController.text = '180';
    _ammoniumNitrogenController.text = '20';
    _calciumController.text = '180';
    _sulfurController.text = '60';
    _potassiumController.text = '300';
    _phosphorusController.text = '50';
    _magnesiumController.text = '50';

    _selectedType = 'VEGETATIVE';
  }

  void _loadTomatoGenPreset() {
    _nitrateNitrogenController.text = '150';
    _ammoniumNitrogenController.text = '10';
    _calciumController.text = '200';
    _sulfurController.text = '70';
    _potassiumController.text = '380';
    _phosphorusController.text = '60';
    _magnesiumController.text = '60';

    _selectedType = 'GENERATIVE';
  }

  void _loadCucumberPreset() {
    _nitrateNitrogenController.text = '170';
    _ammoniumNitrogenController.text = '15';
    _calciumController.text = '160';
    _sulfurController.text = '50';
    _potassiumController.text = '280';
    _phosphorusController.text = '45';
    _magnesiumController.text = '45';

    _selectedType = 'BALANCED';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();

    _nitrateNitrogenController.dispose();
    _ammoniumNitrogenController.dispose();
    _calciumController.dispose();
    _sulfurController.dispose();
    _potassiumController.dispose();
    _phosphorusController.dispose();
    _magnesiumController.dispose();
    _ironController.dispose();
    _manganeseController.dispose();
    _zincController.dispose();
    _boronController.dispose();
    _copperController.dispose();
    _molybdenumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 800, maxWidth: 600),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.recipe != null ? 'Edit Recipe' : 'Add New Recipe',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Preset dropdown
                  if (widget.recipe == null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.science, color: Colors.white),
                      tooltip: 'Load Preset',
                      onSelected: _loadPreset,
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'lettuce',
                              child: Text('📗 Lettuce Preset'),
                            ),
                            const PopupMenuItem(
                              value: 'tomato_veg',
                              child: Text('🍅 Tomato (Veg)'),
                            ),
                            const PopupMenuItem(
                              value: 'tomato_gen',
                              child: Text('🍅 Tomato (Gen)'),
                            ),
                            const PopupMenuItem(
                              value: 'cucumber',
                              child: Text('🥒 Cucumber'),
                            ),
                          ],
                    ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      _buildTextField(
                        controller: _nameController,
                        label: 'Recipe Name',
                        required: true,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedType,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(fontSize: 10),
                              decoration: const InputDecoration(
                                labelText: 'Type',
                                border: OutlineInputBorder(),
                                fillColor: AppColors.background,
                              ),
                              items:
                                  _plantTypes.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Target Parameters
                      const SizedBox(height: 24),

                      // Primary Nutrients Section
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Macronutrients (PPM)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Nitrogen inputs with live calculation
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _nitrateNitrogenController,
                                    label: 'NO3',
                                    keyboardType: TextInputType.number,
                                    required: true,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _ammoniumNitrogenController,
                                    label: 'NH4',
                                    keyboardType: TextInputType.number,
                                    required: true,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Ca, S row
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _calciumController,
                                    label: 'Ca',
                                    keyboardType: TextInputType.number,
                                    required: true,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _sulfurController,
                                    label: 'S',
                                    keyboardType: TextInputType.number,
                                    required: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // K, P, Mg row
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _potassiumController,
                                    label: 'K',
                                    keyboardType: TextInputType.number,
                                    required: true,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _phosphorusController,
                                    label: 'P',
                                    keyboardType: TextInputType.number,
                                    required: true,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _magnesiumController,
                                    label: 'Mg',
                                    keyboardType: TextInputType.number,
                                    required: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Micronutrients Section
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Micronutrients (PPM)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Fe, Mn, Zn row
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _ironController,
                                    label: 'Fe',
                                    keyboardType: TextInputType.number,
                                    required: true,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _manganeseController,
                                    label: 'Mn',
                                    keyboardType: TextInputType.number,
                                    required: true,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _zincController,
                                    label: 'Zn',
                                    keyboardType: TextInputType.number,
                                    required: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // B, Cu, Mo row
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _boronController,
                                    label: 'B',
                                    keyboardType: TextInputType.number,
                                    required: true,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _copperController,
                                    label: 'Cu',
                                    keyboardType: TextInputType.number,
                                    required: true,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _molybdenumController,
                                    label: 'Mo',
                                    keyboardType: TextInputType.number,
                                    required: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            // Action Buttons
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveRecipe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                widget.recipe != null ? 'Update ' : 'Save ',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  color: AppColors.background,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyMedium, // 👉 Tambahkan ini
      decoration: InputDecoration(
        labelText: required ? '$label ' : label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      validator:
          required
              ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                if (keyboardType == TextInputType.number) {
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                }
                return null;
              }
              : null,
    );
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final recipe = RecipeModel(
        id: widget.recipe?.id,
        name: _nameController.text.trim(),
        type: _selectedType,
        nitrateNitrogen: double.parse(_nitrateNitrogenController.text),
        ammoniumNitrogen: double.parse(_ammoniumNitrogenController.text),
        calcium: double.parse(_calciumController.text),
        sulfur: double.parse(_sulfurController.text),
        potassium: double.parse(_potassiumController.text),
        phosphorus: double.parse(_phosphorusController.text),
        magnesium: double.parse(_magnesiumController.text),
        iron: double.parse(_ironController.text),
        manganese: double.parse(_manganeseController.text),
        zinc: double.parse(_zincController.text),
        boron: double.parse(_boronController.text),
        copper: double.parse(_copperController.text),
        molybdenum: double.parse(_molybdenumController.text),
        createdAt: widget.recipe?.createdAt,
        updatedAt: DateTime.now(),
      );

      if (widget.recipe != null) {
        await context.read<RecipeProvider>().updateRecipe(recipe);
      } else {
        await context.read<RecipeProvider>().createRecipe(recipe);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.recipe != null
                  ? 'Recipe updated successfully'
                  : 'Recipe added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save recipe: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
