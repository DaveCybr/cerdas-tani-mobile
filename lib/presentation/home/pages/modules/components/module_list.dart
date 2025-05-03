// components/download_module_list.dart
import 'dart:math';

import 'package:fertilizer_calculator/presentation/home/pages/modules/components/downloadFile.dart';
import 'package:fertilizer_calculator/presentation/home/pages/modules/components/module_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../provider/module_provider.dart';

class ModuleList extends StatelessWidget {
  const ModuleList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ModuleProvider>(
      builder: (context, provider, _) {
        final modules = provider.modules;
        print("Modules: ${modules.length} modules found");

        return ListView.builder(
          shrinkWrap: true, // Ini penting!
          physics:
              NeverScrollableScrollPhysics(), // Supaya tidak konflik scroll
          itemCount: min(modules.length, 3), // Ambil 3 item pertama
          itemBuilder: (context, index) {
            return ModuleCard(
              title: modules[index].name,
              onTap: () async {
                final url =
                    "http://sirangga.satelliteorbit.cloud/public/storage/${modules[index].attachment}";
                downloadFile(context, url, modules[index].name);
                print("URL: $url");
                // if (!await launchUrl(Uri.parse(url))) {
                //   throw 'Could not launch $url';
                // }
              },
            );
          },
        );
      },
    );
  }
}
