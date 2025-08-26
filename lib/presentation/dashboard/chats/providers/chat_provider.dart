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

  // Convert image to base64 for direct sending to server
  Future<String?> _convertImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      final mimeType = _getImageMimeType(imageFile.path);
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  // NEW: Format history according to API requirements with base64 images
  String _formatHistoryForAPI() {
    final formattedHistory = <Map<String, dynamic>>[];

    // Group messages in pairs (user -> assistant)
    for (int i = 0; i < _messages.length; i++) {
      final message = _messages[i];

      if (message['type'] == 'sent') {
        // User message
        final content = <Map<String, dynamic>>[];

        // Add text content if exists
        if (message['text'] != null &&
            message['text'].toString().trim().isNotEmpty) {
          content.add({
            'type': 'text',
            'text': message['text'].toString().trim(),
          });
        }

        // Add image content if exists
        if (message['image'] != null &&
            message['image'].toString().isNotEmpty) {
          final imagePath = message['image'].toString();

          // Check if it's already a data URI (base64)
          if (imagePath.startsWith('data:')) {
            content.add({
              'type': 'image',
              'image': imagePath, // Already base64 data URI
            });
          } else {
            // It's a local file path, convert to base64
            try {
              final file = File(imagePath);
              if (file.existsSync()) {
                final bytes = file.readAsBytesSync();
                final base64String = base64Encode(bytes);
                final mimeType = _getImageMimeType(imagePath);
                final dataUri = 'data:$mimeType;base64,$base64String';

                content.add({'type': 'image', 'image': dataUri});
              }
            } catch (e) {
              print('Error converting history image to base64: $e');
              // Skip this image if conversion fails
            }
          }
        }

        if (content.isNotEmpty) {
          formattedHistory.add({'role': 'user', 'content': content});
        }
      } else if (message['type'] == 'received') {
        // Assistant message
        if (message['text'] != null &&
            message['text'].toString().trim().isNotEmpty) {
          formattedHistory.add({
            'role': 'assistant',
            'content': message['text'].toString().trim(),
          });
        }
      }
    }

    // Limit to last 10 interactions to avoid payload being too large
    if (formattedHistory.length > 20) {
      return jsonEncode(formattedHistory.sublist(formattedHistory.length - 20));
    }

    return jsonEncode(formattedHistory);
  }

  Future<void> sendMessage(String userMessage, {File? imageFile}) async {
    if (userMessage.trim().isEmpty && imageFile == null) return;

    // Validate image file if present
    String? imageBase64;
    if (imageFile != null) {
      final validationError = _validateImageFile(imageFile);
      if (validationError != null) {
        _addErrorMessage(validationError);
        return;
      }

      // Convert image to base64 data URI
      imageBase64 = await _convertImageToBase64(imageFile);
      if (imageBase64 == null) {
        _addErrorMessage('Gagal memproses gambar. Silakan coba lagi.');
        return;
      }
    }

    print(
      imageFile != null
          ? 'Sending message with image: ${imageFile.path}'
          : 'Sending message without image',
    );

    // Add user message to chat - store base64 for consistency
    final userMsg = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'sent',
      'text': userMessage.trim().isEmpty ? null : userMessage.trim(),
      'image':
          imageBase64 ??
          imageFile?.path, // Store base64 if available, fallback to path for UI
      'timestamp': DateTime.now().toIso8601String(),
    };

    _messages.add(userMsg);
    _isLoading = true;
    notifyListeners();
    _saveChatHistory();

    try {
      final aiReply = await _sendToAPI(userMessage, imageFile, imageBase64);

      print('user msg:$userMsg');
      // Add AI response to chat
      print('=== AI REPLY RECEIVED ===');
      print('AI Reply: $aiReply');
      print('========================');

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

  // UPDATED: Modified to match server expectations exactly
  Future<String?> _sendToAPI(
    String userMessage,
    File? imageFile,
    String? imageBase64,
  ) async {
    // Updated URL to match your server route
    const url = 'http://192.168.1.5:8000/api/growbot/chat';
    const timeout = Duration(seconds: 60); // Match server timeout

    try {
      // Check if we should use multipart (when sending current image file)
      if (imageFile != null) {
        return await _sendMultipartRequest(
          url,
          userMessage,
          imageFile,
          timeout,
        );
      } else {
        return await _sendJsonRequest(url, userMessage, timeout);
      }
    } on SocketException catch (e) {
      print('=== SOCKET EXCEPTION ===');
      print('Socket Error: $e');
      throw Exception('No internet connection available');
    } on http.ClientException catch (e) {
      print('=== CLIENT EXCEPTION ===');
      print('Client Error: $e');
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      print('=== FORMAT EXCEPTION ===');
      print('Format Error: $e');
      throw Exception('Data format error: ${e.message}');
    } catch (e) {
      print('=== UNEXPECTED ERROR ===');
      print('Unexpected error: $e');
      rethrow;
    }
  }

  // Send with image file (multipart request)
  Future<String?> _sendMultipartRequest(
    String url,
    String userMessage,
    File imageFile,
    Duration timeout,
  ) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));

    // Set headers
    request.headers.addAll({
      'Accept': 'application/json',
      'User-Agent': 'CerdasTani/1.0',
    });

    // Add fields
    String finalMessage =
        userMessage.trim().isEmpty ? 'Analisis gambar ini' : userMessage.trim();
    request.fields['user_message'] = finalMessage;
    request.fields['history'] = _formatHistoryForAPI();
    request.fields['system_prompt'] = ''; // Let server use default

    // Add image file
    final mimeType = _getImageMimeType(imageFile.path);
    final multipartFile = await http.MultipartFile.fromPath(
      'image_file', // Server expects 'image_file'
      imageFile.path,
      contentType: MediaType.parse(mimeType),
    );
    request.files.add(multipartFile);

    print('=== MULTIPART REQUEST ===');
    print('URL: $url');
    print('user_message: ${request.fields['user_message']}');
    print('history length: ${request.fields['history']?.length ?? 0}');
    print('has image_file: true');
    print('========================');

    final streamedResponse = await request.send().timeout(timeout);
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  // Send without image (JSON request)
  Future<String?> _sendJsonRequest(
    String url,
    String userMessage,
    Duration timeout,
  ) async {
    final payload = {
      'user_message':
          userMessage.trim().isEmpty
              ? 'Lanjutkan percakapan'
              : userMessage.trim(),
      'image_url': '', // Empty string as expected by server
      'history': _formatHistoryForAPI(),
      'system_prompt': '', // Let server use default
    };

    print('=== JSON REQUEST ===');
    print('URL: $url');
    print('Payload: ${jsonEncode(payload)}');
    print('===================');

    final response = await http
        .post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'CerdasTani/1.0',
          },
          body: jsonEncode(payload),
        )
        .timeout(timeout);

    return _handleResponse(response);
  }

  // Handle response from server
  String? _handleResponse(http.Response response) {
    print('=== RESPONSE RECEIVED ===');
    print('Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');
    print('========================');

    if (response.statusCode == 200) {
      try {
        final jsonResponse = jsonDecode(response.body);
        print('=== PARSING JSON RESPONSE ===');
        print('Parsed JSON: $jsonResponse');

        if (jsonResponse is Map<String, dynamic>) {
          // Handle success response
          if (jsonResponse['success'] == true &&
              jsonResponse.containsKey('ai_reply')) {
            return jsonResponse['ai_reply']?.toString();
          }
          // Handle direct ai_reply response
          else if (jsonResponse.containsKey('ai_reply')) {
            return jsonResponse['ai_reply']?.toString();
          }
          // Handle message response
          else if (jsonResponse.containsKey('message')) {
            return jsonResponse['message']?.toString();
          } else {
            throw Exception('Invalid response format from server');
          }
        } else {
          throw Exception('Invalid response format from server');
        }
      } catch (jsonError) {
        print('=== JSON PARSE ERROR ===');
        print('JSON Error: $jsonError');
        throw Exception('Invalid JSON response from server');
      }
    } else if (response.statusCode == 422) {
      // Handle validation errors
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
        // Ignore JSON parse error for server errors
      }
      throw Exception('Server error: ${response.statusCode}');
    } else if (response.statusCode == 400) {
      try {
        final errorResponse = jsonDecode(response.body);
        if (errorResponse['message'] != null) {
          throw Exception(errorResponse['message']);
        } else if (errorResponse['error'] != null) {
          throw Exception(errorResponse['error'].toString());
        }
      } catch (_) {
        // Ignore JSON parse error
      }
      throw Exception('Bad request: ${response.statusCode}');
    } else {
      throw Exception('HTTP error: ${response.statusCode}');
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

  // Updated connection test to match server expectations
  Future<bool> testConnection() async {
    print('=== TESTING CONNECTION ===');
    try {
      const url = 'http://192.168.1.5:8000/api/growbot/chat';

      final testPayload = {
        'user_message': 'test connection',
        'image_url': '',
        'history': '[]',
        'system_prompt': '',
      };

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(testPayload),
          )
          .timeout(Duration(seconds: 10));

      print('Test Response Status: ${response.statusCode}');
      print('Test Response Body: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 422;
    } catch (e) {
      print('Connection test error: $e');
      return false;
    }
  }
}
