// presentation/dashboard/modules/widgets/module_card.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../models/module_model.dart';

class ModuleCard extends StatelessWidget {
  final Module module;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;

  const ModuleCard({
    Key? key,
    required this.module,
    this.onTap,
    this.onDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Module Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),

                    child: Icon(
                      Icons.library_books,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

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
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
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
                              Icon(
                                _getAttachmentIcon(),
                                size: 14,
                                color: AppColors.secondary,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action Button
                  if (module.attachment != null && onDownload != null)
                    IconButton(
                      onPressed: onDownload,
                      icon: const Icon(
                        Icons.download_outlined,
                        color: AppColors.primary,
                      ),
                      tooltip: 'Download Module',
                    ),
                ],
              ),

              // Description (if available)
              if (module.description != null &&
                  module.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  module.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Footer Info
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(module.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const Spacer(),
                  if (module.attachment != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getAttachmentIcon(),
                            size: 12,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            module.attachmentExtension?.toUpperCase() ?? 'FILE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getModuleIcon() {
    // You can customize icons based on module name or category
    if (module.name.toLowerCase().contains('hidroponik')) {
      return Icons.water_drop;
    } else if (module.name.toLowerCase().contains('pupuk')) {
      return Icons.eco;
    } else if (module.name.toLowerCase().contains('tanaman')) {
      return Icons.local_florist;
    }
    return Icons.library_books;
  }

  IconData _getAttachmentIcon() {
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
