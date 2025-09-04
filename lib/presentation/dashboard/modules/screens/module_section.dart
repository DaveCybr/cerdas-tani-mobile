// presentation/dashboard/modules/screens/module_section.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../models/module_model.dart';

class ModuleSection extends StatelessWidget {
  final List<Module> modules;
  final VoidCallback? onSeeAllPressed;
  final Function(Module)? onModuleTap;
  final Function(Module)? onModuleDownload;

  const ModuleSection({
    Key? key,
    required this.modules,
    this.onSeeAllPressed,
    this.onModuleTap,
    this.onModuleDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Learning Modules',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (onSeeAllPressed != null)
              TextButton(
                onPressed: onSeeAllPressed,
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Modules List
        if (modules.isEmpty) _buildEmptyState() else _buildModulesList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No modules available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Check back later for new learning modules',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModulesList() {
    // Show maximum 3 modules in home section
    final displayModules = modules.take(3).toList();

    return Column(
      children: [
        ...displayModules.map(
          (module) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildModuleItem(module),
          ),
        ),

        // Show "See All" button if there are more modules
        if (modules.length > 3 && onSeeAllPressed != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onSeeAllPressed,
              icon: const Icon(Icons.library_books),
              label: Text('View All ${modules.length} Modules'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModuleItem(Module module) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onModuleTap != null ? () => onModuleTap!(module) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Module Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getModuleIcon(module),
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Module Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                module.isActive
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            module.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color:
                                  module.isActive
                                      ? Colors.green[700]
                                      : Colors.grey[600],
                            ),
                          ),
                        ),
                        if (module.attachment != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getAttachmentIcon(module),
                                  size: 10,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  module.attachmentExtension?.toUpperCase() ??
                                      'FILE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(module.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),

              // Action Button
              if (module.attachment != null && onModuleDownload != null)
                IconButton(
                  onPressed: () => onModuleDownload!(module),
                  icon: const Icon(
                    Icons.download_outlined,
                    color: AppColors.primary,
                  ),
                  tooltip: 'Download',
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getModuleIcon(Module module) {
    if (module.name.toLowerCase().contains('hidroponik')) {
      return Icons.water_drop;
    } else if (module.name.toLowerCase().contains('pupuk')) {
      return Icons.eco;
    } else if (module.name.toLowerCase().contains('tanaman')) {
      return Icons.local_florist;
    }
    return Icons.library_books;
  }

  IconData _getAttachmentIcon(Module module) {
    if (module.isPdfFile) {
      return Icons.picture_as_pdf;
    }
    return Icons.attach_file;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
