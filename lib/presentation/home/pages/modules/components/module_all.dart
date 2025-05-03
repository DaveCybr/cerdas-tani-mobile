import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/core/extensions/build_context_ext.dart';
import 'package:fertilizer_calculator/core/helpers/navigation.dart';
import 'package:fertilizer_calculator/presentation/home/pages/modules/components/downloadFile.dart';
import 'package:fertilizer_calculator/presentation/home/pages/modules/components/module_card.dart';
import 'package:fertilizer_calculator/presentation/home/pages/modules/provider/module_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllModuleScreen extends StatefulWidget {
  const AllModuleScreen({super.key});

  @override
  _AllModuleScreenState createState() => _AllModuleScreenState();
}

class _AllModuleScreenState extends State<AllModuleScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol kembali & Judul
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(52, 31, 204, 120),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.primary),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  // const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 20),

              // Input Pencarian
              Text(
                "Module",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari Module...',
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.primary.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 20),

              // Daftar Artikel
              Expanded(
                child: Consumer<ModuleProvider>(
                  builder: (context, moduleProvider, child) {
                    if (moduleProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final filteredModules =
                        moduleProvider.modules.where((module) {
                      return module.name.toLowerCase().contains(_searchQuery);
                    }).toList();

                    if (filteredModules.isEmpty) {
                      return const Center(
                          child: Text("Tidak ada modul tersedia"));
                    }

                    return ListView.builder(
                      itemCount: filteredModules.length,
                      itemBuilder: (context, index) {
                        final module = filteredModules[index];

                        return ModuleCard(
                          title: module.name,
                          onTap: () async {
                            final url =
                                "http://sirangga.satelliteorbit.cloud/public/storage/${module.attachment}";
                            downloadFile(context, url, module.name);
                            print("URL: $url");
                            // if (!await launchUrl(Uri.parse(url))) {
                            //   throw 'Could not launch $url';
                            // }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
