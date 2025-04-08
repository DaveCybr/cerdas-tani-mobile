import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/presentation/user/provider/theme_provider.dart';

class ProfileSettings extends StatelessWidget {
  const ProfileSettings({super.key});

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.card
              : Colors.white,
          title: const Text("Tema Aplikasi"),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRadioTile(context, "Sistem"),
              _buildRadioTile(context, "Terang"),
              _buildRadioTile(context, "Gelap"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRadioTile(BuildContext context, String theme) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return RadioListTile<String>(
      title: Text(theme),
      value: theme,
      groupValue: themeProvider.themeMode,
      onChanged: (value) {
        themeProvider.setTheme(value!);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('Settings', style: Theme.of(context).textTheme.bodyLarge),
          contentPadding: EdgeInsets.all(0),
        ),
        ListTile(
          onTap: () => _showThemeDialog(context),
          leading:
              const Icon(Icons.nightlight_round, color: AppColors.disabled),
          title: Text(
            'Night Mode',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.disabled,
                ),
          ),
          contentPadding: EdgeInsets.all(0),
        ),
        Divider(color: Colors.grey[300])
      ],
    );
  }
}
