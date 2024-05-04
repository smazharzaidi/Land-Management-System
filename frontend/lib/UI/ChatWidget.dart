import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Functionality/ChatService.dart';

class ChatWidget extends StatefulWidget {
  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final ValueNotifier<bool> _updateNotifier = ValueNotifier<bool>(false);
  final _chatService = ChatService();
  List<String> messages = [];
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextInputChange);
  }

  void _handleTextInputChange() {
    if (!_controller.text.isNotEmpty && _isSending) {
      // Potentially trigger a state change when keyboard is dismissed and no text is present
      Future.microtask(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextInputChange);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final userMessage = "You: ${_controller.text}";

      setState(() {
        _isSending = true;
        messages.add(userMessage);
      });

      await Future.delayed(
          Duration(seconds: 1)); // Simulate a delay for testing
      final response = await _chatService.sendMessage(_controller.text);

      setState(() {
        messages.add("Chatbot: $response");
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

  @override
  Widget build(BuildContext context) {
    print("Main build method called");
    return Container(
      margin: EdgeInsets.only(right: 10, bottom: 10),
      child: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return ValueListenableBuilder<bool>(
                valueListenable: _updateNotifier,
                builder: (context, value, child) {
                  return Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: _chatInterface(),
                  );
                },
              );
            },
          );
        },
        child: SvgPicture.asset(
          'assets/images/chat-bot.svg',
          width: 24,
          height: 24,
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _chatInterface() {
    print("Chat interface rebuild");
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(messages[index]),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Send a message",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    key: ValueKey<bool>(_isSending),
                    icon: _isSending
                        ? CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue))
                        : Icon(Icons.send),
                    onPressed: _isSending ? null : _sendMessage,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
