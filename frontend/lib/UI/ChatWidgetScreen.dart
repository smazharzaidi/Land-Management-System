import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Functionality/ChatService.dart';

class ChatWidgetScreen extends StatefulWidget {
  @override
  _ChatWidgetScreenState createState() => _ChatWidgetScreenState();
}

class _ChatWidgetScreenState extends State<ChatWidgetScreen> {
  final _chatService = ChatService();
  List<Map<String, String>> messages = [];
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final userMessage = {"sender": "user", "text": _controller.text};

      setState(() {
        _isSending = true;
        messages.add(userMessage);
      });

      await Future.delayed(
          Duration(seconds: 1)); // Simulate a delay for testing
      final response = await _chatService.sendMessage(_controller.text);

      setState(() {
        messages.add({"sender": "chatbot", "text": response});
        _isSending = false;
      });
      _controller.clear(); // Clear the text field after the state update

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(Map<String, String> message) {
    final bool isUser = message["sender"] == "user";
    final Alignment alignment =
        isUser ? Alignment.centerRight : Alignment.centerLeft;
    final Color bubbleColor = isUser ? Color.fromARGB(255, 162, 235, 126)! : Colors.grey[300]!;
    final Color textColor = isUser ? Colors.blue[900]! : Colors.black;
    final BorderRadius borderRadius = isUser
        ? BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          );

    return Align(
      alignment: alignment,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: borderRadius,
        ),
        child: Text(
          message["text"]!,
          style: GoogleFonts.lato(
            fontSize: 14,
            color: textColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) => _buildMessage(messages[index]),
              ),
            ),
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        
                        hintText: "Send a message...",
                      
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.green,
                    child: IconButton(
                      key: ValueKey<bool>(_isSending),
                      icon: _isSending
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                      onPressed: _isSending ? null : _sendMessage,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
