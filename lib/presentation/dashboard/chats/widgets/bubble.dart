// presentation/dashboard/chatbot/widgets/chat_bubble.dart - FIXED VERSION
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final Function(String) onDelete;

  const ChatBubble({Key? key, required this.message, required this.onDelete})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message['type'] == 'sent';
    final hasImage =
        message['image'] != null && message['image'].toString().isNotEmpty;
    final text = message['text'] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildBotAvatar(),
          if (!isUser) const SizedBox(width: 12),

          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageOptions(context),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: Column(
                  crossAxisAlignment:
                      isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(hasImage ? 8 : 16),
                      decoration: BoxDecoration(
                        gradient:
                            isUser
                                ? LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primary.withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                                : null,
                        color: isUser ? null : AppColors.card,
                        borderRadius: BorderRadius.circular(20).copyWith(
                          bottomLeft:
                              isUser
                                  ? const Radius.circular(20)
                                  : const Radius.circular(4),
                          bottomRight:
                              isUser
                                  ? const Radius.circular(4)
                                  : const Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image if exists
                          if (hasImage) _buildImage(),
                          if (hasImage && text != null && text.isNotEmpty)
                            const SizedBox(height: 8),

                          // Text if exists
                          if (text != null && text.isNotEmpty)
                            _buildFormattedText(text, isUser),
                        ],
                      ),
                    ),

                    // Timestamp
                    Padding(
                      padding: EdgeInsets.only(
                        top: 4,
                        left: isUser ? 0 : 4,
                        right: isUser ? 4 : 0,
                      ),
                      child: Text(
                        _formatTimestamp(message['timestamp']),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (isUser) const SizedBox(width: 12),
          if (isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildFormattedText(String text, bool isUser) {
    // Parse markdown-like formatting for better display
    final spans = <TextSpan>[];
    final lines = text.split('\n');

    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      String line = lines[lineIndex];

      // Handle numbered lists
      if (RegExp(r'^\d+\.\s*\*\*.*\*\*:').hasMatch(line)) {
        // Extract number, bold text, and description
        final match = RegExp(
          r'^(\d+)\.\s*\*\*(.*?)\*\*:\s*(.*)',
        ).firstMatch(line);
        if (match != null) {
          final number = match.group(1);
          final boldText = match.group(2);
          final description = match.group(3);

          spans.add(
            TextSpan(
              text: '$number. ',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isUser ? Colors.white : AppColors.darkText,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          );

          spans.add(
            TextSpan(
              text: '$boldText: ',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isUser ? Colors.white : AppColors.darkText,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          );

          spans.add(
            TextSpan(
              text: description,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color:
                    isUser ? Colors.white.withOpacity(0.9) : AppColors.darkText,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          );
        }
      }
      // Handle bold text with **
      else if (line.contains('**')) {
        final parts = line.split('**');
        for (int i = 0; i < parts.length; i++) {
          final isBold = i % 2 == 1; // Odd indices are bold
          if (parts[i].isNotEmpty) {
            spans.add(
              TextSpan(
                text: parts[i],
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: isUser ? Colors.white : AppColors.darkText,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                  height: 1.4,
                ),
              ),
            );
          }
        }
      }
      // Regular text
      else {
        spans.add(
          TextSpan(
            text: line,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: isUser ? Colors.white : AppColors.darkText,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      }

      // Add line break except for last line
      if (lineIndex < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildBotAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withOpacity(0.8),
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.smart_toy_outlined,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 18),
    );
  }

  Widget _buildImage() {
    final imagePath = message['image'] as String;

    // Handle different image sources
    Widget imageWidget;

    if (imagePath.startsWith('data:')) {
      // Base64 image - decode and display
      try {
        final base64String = imagePath.split(',')[1];
        final bytes = base64Decode(base64String);
        imageWidget = Image.memory(
          bytes,
          width: 200,
          height: 150,
          fit: BoxFit.cover,
        );
      } catch (e) {
        imageWidget = _buildImageError();
      }
    } else {
      // File path image
      final file = File(imagePath);
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          width: 200,
          height: 150,
          fit: BoxFit.cover,
        );
      } else {
        imageWidget = _buildImageError();
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageWidget,
    );
  }

  Widget _buildImageError() {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: AppColors.lightText,
            size: 32,
          ),
          SizedBox(height: 8),
          Text(
            'Gambar tidak dapat dimuat',
            style: GoogleFonts.poppins(
              color: AppColors.lightText,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';

    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} hari lalu';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} jam lalu';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} menit lalu';
      } else {
        return 'Baru saja';
      }
    } catch (e) {
      return '';
    }
  }

  void _showMessageOptions(BuildContext context) {
    final text = message['text'] as String?;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Opsi Pesan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 20),

              if (text != null && text.isNotEmpty)
                _buildOptionTile(
                  icon: Icons.copy_outlined,
                  title: 'Salin Teks',
                  subtitle: 'Salin pesan ke clipboard',
                  onTap: () {
                    // Remove markdown formatting when copying
                    final cleanText = text
                        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
                        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1');

                    Clipboard.setData(ClipboardData(text: cleanText));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Teks berhasil disalin'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),

              _buildOptionTile(
                icon: Icons.delete_outline,
                title: 'Hapus Pesan',
                subtitle: 'Hapus pesan ini dari riwayat',
                color: AppColors.danger,
                onTap: () {
                  Navigator.pop(context);
                  onDelete(message['id']);
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final tileColor = color ?? AppColors.darkText;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: tileColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: tileColor, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: tileColor,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.lightText),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
