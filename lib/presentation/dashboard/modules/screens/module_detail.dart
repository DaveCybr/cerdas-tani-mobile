// presentation/dashboard/modules/screens/module_detail.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import '../../../../core/constants/colors.dart';
import '../models/module_model.dart';
import '../providers/module_provider.dart';

class ModuleDetailScreen extends StatefulWidget {
  final Module module;

  const ModuleDetailScreen({Key? key, required this.module}) : super(key: key);

  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          widget.module.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 18),
        ),
        actions: [
          if (widget.module.attachment != null)
            IconButton(
              onPressed: _isDownloading ? null : _downloadModule,
              icon:
                  _isDownloading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.download),
              tooltip: 'Download Module',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              // _buildHeaderSection(),
              // const SizedBox(height: 20),

              // Status and Info Card
              // _buildInfoCard(),
              // const SizedBox(height: 20),

              // Description Section
              if (widget.module.description != null &&
                  widget.module.description!.isNotEmpty)
                _buildDescriptionSection(),

              // Attachment Section
              if (widget.module.attachment != null) _buildAttachmentSection(),

              // Details Section
              _buildDetailsSection(),

              // Action Buttons
              const SizedBox(height: 30),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            _getModuleIcon(),
            size: 80,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(height: 16),
          Text(
            widget.module.name,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.module.isActive
                          ? Icons.check_circle
                          : Icons.pause_circle,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.module.isActive ? 'Active' : 'Inactive',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.module.attachment != null) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getAttachmentIcon(), size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        widget.module.attachmentExtension?.toUpperCase() ??
                            'FILE',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getModuleIcon(), color: AppColors.primary, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Module Information',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: #${widget.module.id} • ${widget.module.slug}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
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

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.module.description!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Module Files',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getAttachmentIcon(),
                color: AppColors.secondary,
                size: 24,
              ),
            ),
            title: Text(
              widget.module.attachment!.split('/').last,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
            ),
            subtitle: Text(
              '${widget.module.attachmentExtension?.toUpperCase()} File',
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: IconButton(
              onPressed: _isDownloading ? null : _downloadModule,
              icon:
                  _isDownloading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.download),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Module Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailItem(
                  'Module ID',
                  '#${widget.module.id}',
                  Icons.tag,
                ),
                const Divider(),
                _buildDetailItem('Slug', widget.module.slug, Icons.link),
                const Divider(),
                _buildDetailItem(
                  'Created',
                  _formatDate(widget.module.createdAt),
                  Icons.calendar_today,
                ),
                const Divider(),
                _buildDetailItem(
                  'Last Updated',
                  _formatDate(widget.module.updatedAt),
                  Icons.update,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.module.attachment != null)
          ElevatedButton.icon(
            onPressed: _isDownloading ? null : _downloadModule,
            icon:
                _isDownloading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.download),
            label: Text(_isDownloading ? 'Downloading...' : 'Download Module'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _downloadModule() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final provider = Provider.of<ModuleProvider>(context, listen: false);
      final filePath = await provider.downloadModuleAttachment(widget.module);

      if (mounted) {
        setState(() {
          _isDownloading = false;
        });

        if (filePath != null && filePath.isNotEmpty) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Module downloaded successfully'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Open',
                textColor: Colors.white,
                onPressed: () => _openFile(filePath),
              ),
            ),
          );

          // Auto-open the file after a short delay
          await Future.delayed(const Duration(milliseconds: 500));
          await _openFile(filePath);
        } else {
          _showErrorMessage('Download failed - Invalid file path');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });

        String errorMessage = 'Download failed';
        if (e.toString().contains('Storage permission denied')) {
          errorMessage =
              'Storage permission denied. Please grant storage permission and try again.';
        } else if (e.toString().contains('File not found')) {
          errorMessage = 'File not found on server. Please contact support.';
        }

        _showErrorMessage(errorMessage);
      }
    }
  }

  Future<void> _openFile(String filePath) async {
    try {
      // Check if file exists
      final file = File(filePath);
      if (!await file.exists()) {
        _showErrorMessage('Downloaded file not found');
        return;
      }

      // Try to open the file
      final result = await OpenFilex.open(filePath);

      print('Open file result: ${result.type}');
      print('Open file message: ${result.message}');

      // Handle different result types
      switch (result.type) {
        case ResultType.done:
          // File opened successfully
          break;
        case ResultType.noAppToOpen:
          _showErrorWithAction(
            'No app found to open this file type',
            'Install App',
            () => _showInstallAppDialog(),
          );
          break;
        case ResultType.permissionDenied:
          _showErrorMessage('Permission denied to open file');
          break;
        case ResultType.error:
          _showErrorMessage('Error opening file: ${result.message}');
          break;
        case ResultType.fileNotFound:
          _showErrorMessage('File not found: $filePath');
          break;
      }
    } catch (e) {
      print('Error opening file: $e');
      _showErrorMessage('Failed to open file: ${e.toString()}');
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showErrorWithAction(
    String message,
    String actionLabel,
    VoidCallback onAction,
  ) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: actionLabel,
            textColor: Colors.white,
            onPressed: onAction,
          ),
        ),
      );
    }
  }

  void _showInstallAppDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'App Required',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'You need to install an app that can open ${widget.module.attachmentExtension?.toUpperCase() ?? 'this file type'} files. Please install a suitable app from the Play Store.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getModuleIcon() {
    if (widget.module.name.toLowerCase().contains('hidroponik')) {
      return Icons.water_drop;
    } else if (widget.module.name.toLowerCase().contains('pupuk')) {
      return Icons.eco;
    } else if (widget.module.name.toLowerCase().contains('tanaman')) {
      return Icons.local_florist;
    }
    return Icons.library_books;
  }

  IconData _getAttachmentIcon() {
    if (widget.module.isPdfFile) {
      return Icons.picture_as_pdf;
    }
    return Icons.attach_file;
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
