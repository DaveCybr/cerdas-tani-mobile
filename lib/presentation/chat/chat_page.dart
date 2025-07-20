import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http_parser/http_parser.dart'; // untuk MediaType

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final box = GetStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? currentUserId;
  final ScrollController _scrollController = ScrollController();
  String botTypingText = '';
  bool isTyping = false;
  bool showImagePreview = false;
  bool showSearchBar = false;
  String? openedImageUrl;
  File? selectedImage;
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatusAndLoadChats();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    if (bottomInset > 0.0) {
      // Keyboard muncul
      scrollToBottom();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkLoginStatusAndLoadChats() {
    User? user = _auth.currentUser;

    if (user != null) {
      currentUserId = user.uid;
      print("✅ Login terdeteksi. UID: $currentUserId");
      _loadChatHistory();
    } else {
      messages.clear();
      currentUserId = null;
      print("❌ Tidak ada user yang login. UID: null");
    }
  }

  void _loadChatHistory() {
    final stored = box.read('chat_history_$currentUserId');
    if (stored != null && stored is List) {
      messages.clear();
      messages.addAll(List<Map<String, dynamic>>.from(stored));
      setState(() {});
    }
    scrollToBottom();
  }

  void _saveChatHistory() {
    if (currentUserId != null) {
      box.write('chat_history_$currentUserId', messages);
    }
  }

  List<Map<String, dynamic>> get filteredMessages {
    if (_searchController.text.isEmpty) return messages;
    return messages.where((msg) {
      final content = msg['text'] ?? '';
      return content
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
    }).toList();
  }

  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> sendMessageToAPI(String userMessage, File? imageFile) async {
    const url = 'http://sirangga.satelliteorbit.cloud/api/growbot/chat';

    final history = messages
        .where((msg) => msg['type'] == 'sent' || msg['type'] == 'received')
        .map((msg) {
      return {
        'role': msg['type'] == 'sent' ? 'user' : 'assistant',
        'content': msg['text'] ?? '[gambar]',
      };
    }).toList();

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields['user_message'] = userMessage.isEmpty ? '""' : userMessage;
      request.fields['history'] = jsonEncode(history);

      if (imageFile != null) {
        final mimeType =
            imageFile.path.endsWith('.png') ? 'image/png' : 'image/jpeg';

        final multipartFile = await http.MultipartFile.fromPath(
          'image_file',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        );

        request.files.add(multipartFile);
      }

      print('Mengirim ke API dengan data berikut:');
      print('user_message: ${request.fields['user_message']}');
      print('chat_history: ${request.fields['chat_history']}');
      print(
          'image: ${imageFile != null ? imageFile.path : 'Tidak ada gambar'}');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['ai_reply'];
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR saat mengirim ke API: $e');
      return null;
    }
  }

  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty && selectedImage == null) return;

    final userText = _controller.text.trim();

    // Tambahkan pesan ke daftar message
    messages.add({
      'type': 'sent',
      'text': userText.isEmpty ? null : userText,
      if (selectedImage != null) 'image': selectedImage!.path,
    });

    messages.add({'type': 'loading'});

    setState(() {
      _controller.clear();
    });
    scrollToBottom();
    final imageToSend = selectedImage;
    selectedImage = null;

    final response =
        await sendMessageToAPI(userText.isEmpty ? "" : userText, imageToSend);

    messages.removeWhere((msg) => msg['type'] == 'loading');

    if (response == null || response.trim().isEmpty) {
      // Gagal
      setState(() {
        final lastSentIndex =
            messages.lastIndexWhere((msg) => msg['type'] == 'sent');
        if (lastSentIndex != -1) {
          messages[lastSentIndex] = {
            ...messages[lastSentIndex],
            'type': 'failed',
            'text': userText,
            'originalText': userText,
            'originalImage': imageToSend?.path,
          };
        }
      });
      return;
    }

    // Sukses
    messages.add({'type': 'received', 'text': response});
    _saveChatHistory();

    setState(() {});
    scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isComposing =
        _controller.text.trim().isNotEmpty || selectedImage != null;

    return Scaffold(
      backgroundColor: const Color(0xFFE9FDF0),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            if (showSearchBar)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'Search messages...',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.black), // border normal
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.black, width: 2), // border saat focus
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            Expanded(
              child: Stack(
                children: [
                  _buildMessageList(),
                  if (openedImageUrl != null)
                    _buildFullImagePopup(openedImageUrl!),
                ],
              ),
            ),
            if (selectedImage != null) _buildSelectedImagePreview(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFD3FAD6),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green, width: 2),
            ),
            padding: const EdgeInsets.all(2),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
              children: parseBoldText('GrowBOT'),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => showSearchBar = !showSearchBar),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: filteredMessages.length,
      itemBuilder: (context, index) {
        final msg = filteredMessages[index];
        final isSender = msg['type'] == 'sent';
        final prevType = index > 0 ? filteredMessages[index - 1]['type'] : null;
        final nextType = index < filteredMessages.length - 1
            ? filteredMessages[index + 1]['type']
            : null;
        final isFirstOfGroup = prevType != msg['type'];
        final isLastOfGroup = nextType != msg['type'];

        final topMargin = isFirstOfGroup && index > 0 ? 20.0 : 4.0;

        BorderRadius messageBorderRadius;
        if (isSender) {
          if (isFirstOfGroup && isLastOfGroup) {
            messageBorderRadius = const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(0),
            );
          } else if (isFirstOfGroup) {
            messageBorderRadius = const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(0),
            );
          } else if (isLastOfGroup) {
            messageBorderRadius = const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(0),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            );
          } else {
            messageBorderRadius = const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(0),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(0),
            );
          }
        } else {
          if (isFirstOfGroup && isLastOfGroup) {
            messageBorderRadius = const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(16),
            );
          } else if (isFirstOfGroup) {
            messageBorderRadius = const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(0),
            );
          } else if (isLastOfGroup) {
            messageBorderRadius = const BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            );
          } else {
            messageBorderRadius = const BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(16),
            );
          }
        }

        if (msg['type'] == 'loading') {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 4, top: 4),
              padding: const EdgeInsets.all(12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green),
              ),
              child: const SpinKitThreeBounce(
                color: Colors.green,
                size: 18,
              ),
            ),
          );
        }

        if (msg['type'] == 'typing') {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 4, top: 4),
              padding: const EdgeInsets.all(12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green),
              ),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: parseBoldText(msg['text'] ?? ''),
                ),
              ),
            ),
          );
        }

        if (msg.containsKey('image')) {
          List<Widget> imageWidgets = [];

          if (msg['image'] is String) {
            // Hanya satu gambar
            final imageWidget = msg['image'].toString().startsWith('http')
                ? Image.network(msg['image'], width: 160)
                : Image.file(File(msg['image']), width: 160);

            imageWidgets.add(
              GestureDetector(
                onTap: () => setState(() => openedImageUrl = msg['image']),
                child: imageWidget,
              ),
            );
          } else if (msg['image'] is List) {
            // Beberapa gambar
            for (var img in msg['image']) {
              final imageWidget = img.toString().startsWith('http')
                  ? Image.network(img, width: 160)
                  : Image.file(File(img), width: 160);

              imageWidgets.add(
                GestureDetector(
                  onTap: () => setState(() => openedImageUrl = img),
                  child: imageWidget,
                ),
              );
            }
          }

          final textContent = msg['text'];
          final textWidget =
              (textContent != null && textContent.toString().isNotEmpty)
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          children: parseBoldText(msg['text'] ?? ''),
                        ),
                      ))
                  : const SizedBox.shrink();

          return Align(
            alignment: msg['type'] == 'sent'
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: messageBorderRadius,
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...imageWidgets,
                  textWidget,
                ],
              ),
            ),
          );
        }

        if (msg['type'] == 'failed') {
          return Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 7, bottom: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.orange),
                      const SizedBox(width: 4),
                      Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                              children: parseBoldText(msg['text'] ?? ''),
                            ),
                          )),
                    ],
                  ),
                  TextButton(
                      onPressed: () async {
                        final failedText = msg['originalText'] ?? '';
                        final failedImage = msg['originalImage'];
                        final index = messages.indexOf(msg);

                        if (index != -1) {
                          setState(() {
                            messages[index] = {
                              'type': 'sent',
                              if (failedText.isNotEmpty) 'text': failedText,
                              if (failedImage != null) 'image': failedImage,
                            };
                            // Tambahkan loading bubble
                            messages.insert(index + 1, {'type': 'loading'});
                          });

                          final imagePath = failedImage;
                          final response =
                              await sendMessageToAPI(failedText, null);

                          // Hapus loading bubble
                          messages
                              .removeWhere((msg) => msg['type'] == 'loading');

                          if (response == null || response.trim().isEmpty) {
                            setState(() {
                              messages[index] = {
                                ...messages[index],
                                'type': 'failed',
                                'text': messages[index]['text'] ?? '[gambar]',
                                'originalText': failedText,
                                'originalImage': imagePath,
                              };
                            });
                            return;
                          }

                          // Tampilkan typing effect
                          messages.add({'type': 'typing', 'text': ''});
                          isTyping = true;
                          botTypingText = '';
                          setState(() {});

                          for (int i = 0; i < response.length; i++) {
                            await Future.delayed(
                                const Duration(milliseconds: 5));
                            botTypingText += response[i];
                            final typingIndex = messages
                                .indexWhere((msg) => msg['type'] == 'typing');
                            if (typingIndex != -1) {
                              setState(() {
                                messages[typingIndex]['text'] = botTypingText;
                              });
                            }
                          }

                          messages
                              .removeWhere((msg) => msg['type'] == 'typing');
                          messages
                              .add({'type': 'received', 'text': botTypingText});
                          isTyping = false;
                          botTypingText = '';
                          _saveChatHistory();

                          setState(() {});
                        }
                      },
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                          ),
                          children: parseBoldText(msg['text'] ?? ''),
                        ),
                      ))
                ],
              ),
            ),
          );
        }

        return Align(
          alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            margin: EdgeInsets.only(bottom: 7, top: 7),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: messageBorderRadius,
              border: Border.all(color: Colors.green),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 2)
              ],
            ),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: parseBoldText(msg['text'] ?? ''),
              ),
            ),
          ),
        );
      },
    );
  }

  List<InlineSpan> parseBoldText(String text) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    var currentIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ));
      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
      ));
    }

    return spans;
  }

  Widget _buildInputArea() {
    bool isComposing =
        _controller.text.trim().isNotEmpty || selectedImage != null;

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: "Type Message...",
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: Colors.black, // <- ubah warna teks di sini
                fontSize: 14, // opsional
              ),
            ),
          ),
          GestureDetector(
            onTap: isComposing ? sendMessage : pickImageFromGallery,
            child: CircleAvatar(
              backgroundColor: Colors.green,
              radius: 16,
              child: Icon(
                isComposing ? Icons.send : Icons.add_photo_alternate,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedImagePreview() {
    if (selectedImage == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 10,
      left: 16,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              selectedImage!,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => selectedImage = null),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullImagePopup(String url) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Stack(
          children: [
            Center(
              child: url.startsWith('http')
                  ? Image.network(url, width: 300, fit: BoxFit.contain)
                  : Image.file(File(url), width: 300, fit: BoxFit.contain),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => setState(() => openedImageUrl = null),
                child: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            )
          ],
        ),
      ),
    );
  }
}
