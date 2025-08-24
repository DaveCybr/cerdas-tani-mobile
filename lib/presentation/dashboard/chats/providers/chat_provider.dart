// presentation/dashboard/chatbot/providers/chatbot_provider.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart' as path;

class ChatbotProvider extends ChangeNotifier {
  final GetStorage _storage = GetStorage();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  String? _currentUserId;

  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;

  void setUserId(String userId, uid) {
    _currentUserId = userId;
    _loadChatHistory();
  }

  void _loadChatHistory() {
    if (_currentUserId == null) return;

    try {
      final history = _storage.read<List>('chat_history_$_currentUserId');
      if (history != null) {
        _messages = List<Map<String, dynamic>>.from(
          history.map((item) => Map<String, dynamic>.from(item)),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading chat history: $e');
      _messages = [];
    }
  }

  void _saveChatHistory() {
    if (_currentUserId == null) return;

    try {
      _storage.write('chat_history_$_currentUserId', _messages);
    } catch (e) {
      debugPrint('Error saving chat history: $e');
    }
  }

  // Validate image file format and size
  String? _validateImageFile(File imageFile) {
    try {
      // Check if file exists
      if (!imageFile.existsSync()) {
        return 'File gambar tidak ditemukan';
      }

      // Get file extension
      final extension = path.extension(imageFile.path).toLowerCase();
      final supportedFormats = ['.png', '.jpg', '.jpeg', '.gif', '.webp'];

      if (!supportedFormats.contains(extension)) {
        return 'Format gambar tidak didukung. Gunakan PNG, JPG, JPEG, GIF, atau WebP';
      }

      // Check file size (max 10MB)
      final fileSizeInMB = imageFile.lengthSync() / (1024 * 1024);
      if (fileSizeInMB > 10) {
        return 'Ukuran gambar terlalu besar. Maksimal 10MB';
      }

      return null; // No error
    } catch (e) {
      return 'Error validasi gambar: ${e.toString()}';
    }
  }

  // Get proper MIME type for image
  String _getImageMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.png':
        return 'image/png';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg'; // fallback
    }
  }

  Future<void> sendMessage(String userMessage, {File? imageFile}) async {
    if (userMessage.trim().isEmpty && imageFile == null) return;

    // Validate image file if present
    if (imageFile != null) {
      final validationError = _validateImageFile(imageFile);
      if (validationError != null) {
        _addErrorMessage(validationError);
        return;
      }
    }

    // Add user message to chat
    final userMsg = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'sent',
      'text': userMessage.trim().isEmpty ? null : userMessage.trim(),
      'image': imageFile?.path,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _messages.add(userMsg);
    _isLoading = true;
    notifyListeners();
    _saveChatHistory();

    try {
      final aiReply = await _sendToAPI(userMessage, imageFile);

      // Add AI response to chat
      final aiMsg = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'received',
        'text':
            aiReply ?? 'Maaf, tidak ada respon dari server. Silakan coba lagi.',
        'timestamp': DateTime.now().toIso8601String(),
      };

      _messages.add(aiMsg);
      _saveChatHistory();
    } catch (e) {
      debugPrint('Error in sendMessage: $e');
      _addErrorMessage(_getErrorMessage(e));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _addErrorMessage(String errorText) {
    final errorMsg = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'received',
      'text': errorText,
      'timestamp': DateTime.now().toIso8601String(),
    };
    _messages.add(errorMsg);
    _saveChatHistory();
  }

  String _getErrorMessage(dynamic error) {
    debugPrint('Handling error: $error');
    final errorString = error.toString();

    // Handle specific error cases
    if (errorString.contains('Validation error')) {
      return 'Data yang dikirim tidak valid. Silakan periksa kembali.';
    } else if (errorString.contains('Server error: 500')) {
      return 'Server sedang bermasalah. Silakan coba lagi dalam beberapa menit.';
    } else if (errorString.contains('Server error: 413')) {
      return 'Ukuran gambar terlalu besar. Silakan gunakan gambar yang lebih kecil.';
    } else if (errorString.contains('SocketException') ||
        errorString.contains('Connection')) {
      return 'Tidak ada koneksi internet. Periksa jaringan Anda dan coba lagi.';
    } else if (errorString.contains('TimeoutException')) {
      return 'Koneksi timeout. Silakan coba lagi.';
    } else if (errorString.contains('FormatException')) {
      return 'Format data tidak valid. Silakan coba lagi.';
    } else {
      return 'Terjadi kesalahan tidak terduga. Silakan coba lagi nanti.';
    }
  }

  Future<String?> _sendToAPI(String userMessage, File? imageFile) async {
    // FIX: URL endpoint sesuai dengan route Laravel
    const url = 'http://192.168.1.10:8000/api/growbot/chat';
    const timeout = Duration(seconds: 30);

    // Prepare chat history for API (sesuai format Laravel)
    final history =
        _messages
            .where((msg) => msg['type'] == 'sent' || msg['type'] == 'received')
            .take(10) // Limit history to last 10 messages for performance
            .map((msg) {
              return {
                'role': msg['type'] == 'sent' ? 'user' : 'assistant',
                'content': msg['text'] ?? '[gambar]',
              };
            })
            .toList();

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Set headers
      request.headers.addAll({
        'Accept': 'application/json',
        'User-Agent': 'CerdasTani/1.0',
      });

      // FIX: Jika ada gambar tapi tidak ada text, beri default message
      String finalMessage = userMessage;
      if (imageFile != null && userMessage.trim().isEmpty) {
        finalMessage = 'Analisis gambar ini';
      }

      request.fields['user_message'] = finalMessage;
      request.fields['history'] = jsonEncode(history);
      request.fields['system_prompt'] =
          ''; // Optional, akan menggunakan default

      if (imageFile != null) {
        final mimeType = _getImageMimeType(imageFile.path);

        debugPrint('Preparing image file:');
        debugPrint('Path: ${imageFile.path}');
        debugPrint('Size: ${imageFile.lengthSync()} bytes');
        debugPrint('MIME Type: $mimeType');

        final multipartFile = await http.MultipartFile.fromPath(
          'image_file',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        );

        request.files.add(multipartFile);
      }

      debugPrint('Sending to API with data:');
      debugPrint('user_message: ${request.fields['user_message']}');
      debugPrint('history count: ${history.length}');
      debugPrint('has image: ${imageFile != null}');

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);

          // FIX: Sesuaikan dengan response format Laravel controller yang baru
          if (jsonResponse is Map<String, dynamic>) {
            if (jsonResponse['success'] == true &&
                jsonResponse.containsKey('ai_reply')) {
              return jsonResponse['ai_reply']?.toString();
            } else if (jsonResponse.containsKey('ai_reply')) {
              // Fallback untuk format lama
              return jsonResponse['ai_reply']?.toString();
            } else {
              debugPrint('Unexpected response format: $jsonResponse');
              throw Exception('Invalid response format from server');
            }
          } else {
            throw Exception('Invalid response format from server');
          }
        } catch (jsonError) {
          debugPrint('JSON Parse Error: $jsonError');
          debugPrint('Raw Response: ${response.body}');
          throw Exception('Invalid JSON response from server');
        }
      } else if (response.statusCode == 422) {
        // FIX: Handle validation errors dari Laravel
        try {
          final errorResponse = jsonDecode(response.body);
          if (errorResponse['errors'] != null) {
            final errors = errorResponse['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              throw Exception('Validation error: ${firstError.first}');
            }
          }
          throw Exception(
            'Validation error: ${errorResponse['message'] ?? 'Data tidak valid'}',
          );
        } catch (jsonError) {
          throw Exception('Validation error: Invalid data sent to server');
        }
      } else if (response.statusCode == 413) {
        throw Exception('Server error: 413 - File too large');
      } else if (response.statusCode >= 500) {
        try {
          final errorResponse = jsonDecode(response.body);
          if (errorResponse['message'] != null) {
            throw Exception('Server error: ${errorResponse['message']}');
          }
        } catch (_) {
          // Ignore JSON parsing error for server errors
        }
        throw Exception('Server error: ${response.statusCode}');
      } else if (response.statusCode == 400) {
        try {
          final errorResponse = jsonDecode(response.body);
          if (errorResponse['message'] != null) {
            throw Exception(errorResponse['message']);
          } else if (errorResponse['error'] != null) {
            throw Exception(errorResponse['error'].toString());
          } else {
            throw Exception('Bad request: Invalid data sent to server');
          }
        } catch (jsonError) {
          throw Exception('Bad request: ${response.statusCode}');
        }
      } else {
        debugPrint('Unexpected status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection available');
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Data format error: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error in _sendToAPI: $e');
      rethrow;
    }
  }

  void clearChat() {
    try {
      _messages.clear();
      notifyListeners();
      _saveChatHistory();
    } catch (e) {
      debugPrint('Error clearing chat: $e');
    }
  }

  void deleteMessage(String messageId) {
    try {
      _messages.removeWhere((msg) => msg['id'] == messageId);
      notifyListeners();
      _saveChatHistory();
    } catch (e) {
      debugPrint('Error deleting message: $e');
    }
  }

  // Method to retry last failed message
  void retryLastMessage() {
    if (_messages.isNotEmpty) {
      final lastMessage = _messages.last;
      if (lastMessage['type'] == 'received' &&
          lastMessage['text'].toString().contains('kesalahan')) {
        // Remove error message
        _messages.removeLast();

        // Find the user message that caused the error
        for (int i = _messages.length - 1; i >= 0; i--) {
          if (_messages[i]['type'] == 'sent') {
            final userMessage = _messages[i];
            final text = userMessage['text']?.toString() ?? '';
            final imagePath = userMessage['image']?.toString();
            File? imageFile;

            if (imagePath != null && imagePath.isNotEmpty) {
              imageFile = File(imagePath);
              if (!imageFile.existsSync()) {
                imageFile = null;
              }
            }

            // Retry the message
            sendMessage(text, imageFile: imageFile);
            break;
          }
        }
      }
    }
  }

  // FIX: Method untuk test koneksi
  Future<bool> testConnection() async {
    try {
      const url = 'http://sirangga.satelliteorbit.cloud/chatbots/chat';
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_message': 'test',
              'history': '[]',
              'system_prompt': '',
            }),
          )
          .timeout(Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 422;
    } catch (e) {
      debugPrint('Connection test failed: $e');
      return false;
    }
  }
}
