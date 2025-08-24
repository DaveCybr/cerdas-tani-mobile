// ========================================
// NUTRIENT FORM DIALOG
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/nutrient_model.dart';
import '../providers/nutrient_provider.dart';

class NutrientFormDialog extends StatefulWidget {
  final NutrientModel? nutrient;

  const NutrientFormDialog({Key? key, this.nutrient}) : super(key: key);

  @override
  State<NutrientFormDialog> createState() => _NutrientFormDialogState();
}

class _NutrientFormDialogState extends State<NutrientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _formulaController;
  late TextEditingController _priceController;
  late TextEditingController _nh4Controller;
  late TextEditingController _no3Controller;
  late TextEditingController _pController;
  late TextEditingController _kController;
  late TextEditingController _caController;
  late TextEditingController _mgController;
  late TextEditingController _sController;
  late TextEditingController _feController;
  late TextEditingController _mnController;
  late TextEditingController _znController;
  late TextEditingController _bController;
  late TextEditingController _cuController;
  late TextEditingController _moController;

  String _selectedType = 'A';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final nutrient = widget.nutrient;
    _nameController = TextEditingController(text: nutrient?.name ?? '');
    _formulaController = TextEditingController(text: nutrient?.formula ?? '');
    _priceController = TextEditingController(
      text: nutrient?.pricePerKg.toString() ?? '',
    );
    _nh4Controller = TextEditingController(
      text: nutrient?.nh4.toString() ?? '0',
    );
    _no3Controller = TextEditingController(
      text: nutrient?.no3.toString() ?? '0',
    );
    _pController = TextEditingController(text: nutrient?.p.toString() ?? '0');
    _kController = TextEditingController(text: nutrient?.k.toString() ?? '0');
    _caController = TextEditingController(text: nutrient?.ca.toString() ?? '0');
    _mgController = TextEditingController(text: nutrient?.mg.toString() ?? '0');
    _sController = TextEditingController(text: nutrient?.s.toString() ?? '0');
    _feController = TextEditingController(text: nutrient?.fe.toString() ?? '0');
    _mnController = TextEditingController(text: nutrient?.mn.toString() ?? '0');
    _znController = TextEditingController(text: nutrient?.zn.toString() ?? '0');
    _bController = TextEditingController(text: nutrient?.b.toString() ?? '0');
    _cuController = TextEditingController(text: nutrient?.cu.toString() ?? '0');
    _moController = TextEditingController(
      text: nutrient?.mo.toString() ?? '0 ',
    );
    _selectedType = nutrient?.type ?? 'A';
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.nutrient != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Nutrient' : 'Add Nutrient'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Basic Info
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _formulaController,
                  decoration: const InputDecoration(
                    labelText: 'Formula *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Formula is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Type *',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'A', child: Text('Type A')),
                          DropdownMenuItem(value: 'B', child: Text('Type B')),
                        ],
                        onChanged:
                            (value) => setState(() => _selectedType = value!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price/kg (\$) *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Price is required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Macronutrients Section
                Text(
                  'Macronutrients (%)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(child: _buildNumberField(_nh4Controller, 'NH₄-N')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildNumberField(_no3Controller, 'NO₃-N')),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(child: _buildNumberField(_pController, 'P')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildNumberField(_kController, 'K')),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(child: _buildNumberField(_caController, 'Ca')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildNumberField(_mgController, 'Mg')),
                  ],
                ),
                const SizedBox(height: 8),

                _buildNumberField(_sController, 'S'),
                const SizedBox(height: 16),
                Text(
                  'Micronutrients (%)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(child: _buildNumberField(_feController, 'Fe')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildNumberField(_mnController, 'Mn')),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(child: _buildNumberField(_znController, 'Zn')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildNumberField(_bController, 'B')),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(child: _buildNumberField(_cuController, 'Cu')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildNumberField(_moController, 'Mo')),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveNutrient,
          child:
              _isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text(isEdit ? 'Update' : 'Save'),
        ),
      ],
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (double.tryParse(value) == null) {
            return 'Invalid number';
          }
        }
        return null;
      },
    );
  }

  void _saveNutrient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final nutrient = NutrientModel(
        id: widget.nutrient?.id,
        name: _nameController.text.trim(),
        formula: _formulaController.text.trim(),
        type: _selectedType,
        pricePerKg: double.parse(_priceController.text),
        nh4: double.tryParse(_nh4Controller.text) ?? 0.0,
        no3: double.tryParse(_no3Controller.text) ?? 0.0,
        p: double.tryParse(_pController.text) ?? 0.0,
        k: double.tryParse(_kController.text) ?? 0.0,
        ca: double.tryParse(_caController.text) ?? 0.0,
        mg: double.tryParse(_mgController.text) ?? 0.0,
        s: double.tryParse(_sController.text) ?? 0.0,
        fe: double.tryParse(_feController.text) ?? 0.0,
        mn: double.tryParse(_mnController.text) ?? 0.0,
        zn: double.tryParse(_znController.text) ?? 0.0,
        b: double.tryParse(_bController.text) ?? 0.0,
        cu: double.tryParse(_cuController.text) ?? 0.0,
        mo: double.tryParse(_moController.text) ?? 0.0,
        createdAt: widget.nutrient?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // ✅ CARA YANG BENAR - pilih salah satu:

      // Opsi 1: Menggunakan context.read() (RECOMMENDED)
      final provider = context.read<NutrientProvider>();

      // Opsi 2: Menggunakan Provider.of dengan listen: false
      // final provider = Provider.of<NutrientProvider>(context, listen: false);

      final success =
          widget.nutrient != null
              ? await provider.updateNutrient(nutrient)
              : await provider.createNutrient(nutrient);

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.nutrient != null
                    ? 'Nutrient updated successfully'
                    : 'Nutrient created successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.errorMessage.isNotEmpty
                    ? provider.errorMessage
                    : 'Failed to save nutrient',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _formulaController.dispose();
    _priceController.dispose();
    _nh4Controller.dispose();
    _no3Controller.dispose();
    _pController.dispose();
    _kController.dispose();
    _caController.dispose();
    _mgController.dispose();
    _sController.dispose();
    _feController.dispose();
    _mnController.dispose();
    _znController.dispose();
    _bController.dispose();
    _cuController.dispose();
    _moController.dispose();
    super.dispose();
  }
}
