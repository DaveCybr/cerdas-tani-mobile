// presentation/dashboard/chatbot/screens/chatbot_screen.dart - IMPROVED VERSION
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import '../../../../core/constants/colors.dart';
import '../providers/chat_provider.dart';
import '../widgets/bubble.dart';
import '../widgets/input.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatbotProvider>().addListener(_scrollToBottom);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<bool> _requestCameraPermission() async {
    try {
      var status = await Permission.camera.status;

      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        status = await Permission.camera.request();
        return status.isGranted;
      }

      if (status.isPermanentlyDenied) {
        _showPermissionDialog('Kamera', () => openAppSettings());
        return false;
      }

      return false;
    } catch (e) {
      debugPrint('Error requesting camera permission: $e');
      _showErrorSnackBar('Gagal meminta izin kamera');
      return false;
    }
  }

  Future<bool> _requestStoragePermission() async {
    try {
      Permission permission;

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;

        if (androidInfo.version.sdkInt >= 33) {
          permission = Permission.photos;
        } else {
          permission = Permission.storage;
        }
      } else {
        permission = Permission.photos;
      }

      var status = await permission.status;

      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        status = await permission.request();
        return status.isGranted;
      }

      if (status.isPermanentlyDenied) {
        _showPermissionDialog('Penyimpanan', () => openAppSettings());
        return false;
      }

      return false;
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      _showErrorSnackBar('Gagal meminta izin penyimpanan');
      return false;
    }
  }

  void _showPermissionDialog(
    String permissionName,
    VoidCallback onOpenSettings,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Izin $permissionName Diperlukan',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          content: Text(
            'Aplikasi memerlukan akses $permissionName untuk mengambil foto. '
            'Silakan aktifkan di pengaturan aplikasi.',
            style: const TextStyle(color: AppColors.lightText, height: 1.4),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Batal',
                style: TextStyle(color: AppColors.lightText),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                child: const Text(
                  'Buka Pengaturan',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onOpenSettings();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'Tutup',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  bool _isValidImageFormat(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.png', '.jpg', '.jpeg', '.gif', '.webp'].contains(extension);
  }

  Future<void> _pickImage() async {
    try {
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        _showErrorSnackBar('Izin akses galeri diperlukan untuk memilih gambar');
        return;
      }

      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);

        // Validate image format
        if (!_isValidImageFormat(imageFile.path)) {
          _showErrorSnackBar(
            'Format gambar tidak didukung. Gunakan PNG, JPG, GIF, atau WebP',
          );
          return;
        }

        // Check file size (max 10MB)
        final fileSizeInMB = imageFile.lengthSync() / (1024 * 1024);
        if (fileSizeInMB > 10) {
          _showErrorSnackBar('Ukuran gambar terlalu besar. Maksimal 10MB');
          return;
        }

        setState(() {
          _selectedImage = imageFile;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      _showErrorSnackBar('Gagal memilih gambar: ${e.toString()}');
    }
  }

  Future<void> _takePicture() async {
    try {
      bool hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        _showErrorSnackBar('Izin akses kamera diperlukan untuk mengambil foto');
        return;
      }

      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);

        // Validate image format
        if (!_isValidImageFormat(imageFile.path)) {
          _showErrorSnackBar(
            'Format gambar tidak didukung. Gunakan PNG, JPG, GIF, atau WebP',
          );
          return;
        }

        // Check file size (max 10MB)
        final fileSizeInMB = imageFile.lengthSync() / (1024 * 1024);
        if (fileSizeInMB > 10) {
          _showErrorSnackBar('Ukuran gambar terlalu besar. Maksimal 10MB');
          return;
        }

        setState(() {
          _selectedImage = imageFile;
        });
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      _showErrorSnackBar('Gagal mengambil foto: ${e.toString()}');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty && _selectedImage == null) {
      _showErrorSnackBar('Tulis pesan atau pilih gambar terlebih dahulu');
      return;
    }

    try {
      final response = context.read<ChatbotProvider>().sendMessage(
        message,
        imageFile: _selectedImage,
      );

      print('Chatbot response: $response');

      _messageController.clear();
      setState(() {
        _selectedImage = null;
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error sending message: $e');
      _showErrorSnackBar('Gagal mengirim pesan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Date separator
          _buildDateSeparator(),

          // Chat Messages
          Expanded(
            child: Consumer<ChatbotProvider>(
              builder: (context, provider, child) {
                if (provider.messages.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount:
                      provider.messages.length + (provider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.messages.length &&
                        provider.isLoading) {
                      return _buildTypingIndicator();
                    }

                    final message = provider.messages[index];
                    return ChatBubble(
                      message: message,
                      onDelete: (messageId) {
                        provider.deleteMessage(messageId);
                      },
                      // onRetry:
                      //     message['text']?.toString().contains('kesalahan') ==
                      //                 true ||
                      //             message['text']?.toString().contains(
                      //                   'error',
                      //                 ) ==
                      //                 true
                      //         ? () {
                      //           provider.retryLastMessage();
                      //         }
                      //         : null,
                    );
                  },
                );
              },
            ),
          ),

          // Selected Image Preview
          if (_selectedImage != null) _buildImagePreview(),

          // Chat Input
          ChatInput(
            controller: _messageController,
            onSend: _sendMessage,
            onImagePick: _pickImage,
            onCameraPick: _takePicture,
            isLoading: context.watch<ChatbotProvider>().isLoading,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'GrowBot Assistant',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: AppColors.lightText,
              size: 20,
            ),
          ),
          onPressed: () {
            _showClearChatDialog();
          },
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.outline.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildDateSeparator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outline.withOpacity(0.3)),
            ),
            child: const Text(
              'Hari ini',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.lightText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Selamat datang di GrowBot!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tanyakan tentang pertanian, pupuk,\natau kirim foto tanaman Anda',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.lightText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withOpacity(0.8),
                  AppColors.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(
                20,
              ).copyWith(bottomLeft: const Radius.circular(4)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.4, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.lightText,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () => setState(() {}),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _selectedImage!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gambar siap dikirim',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ukuran: ${(_selectedImage!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.lightText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.close, color: AppColors.danger, size: 16),
            ),
            onPressed: _removeImage,
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Hapus Riwayat Chat',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus semua pesan? Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(color: AppColors.lightText, height: 1.4),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Batal',
                style: TextStyle(color: AppColors.lightText),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  try {
                    context.read<ChatbotProvider>().clearChat();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Chat berhasil dihapus'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } catch (e) {
                    Navigator.of(context).pop();
                    _showErrorSnackBar('Gagal menghapus chat');
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
