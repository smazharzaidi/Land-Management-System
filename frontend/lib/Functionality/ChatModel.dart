import 'package:flutter/material.dart';
import '../Functionality/ChatService.dart'; // Adjust the import path as necessary

class ChatModel with ChangeNotifier {
  bool _isSending = false;
  List<String> messages = [];

  bool get isSending => _isSending;

  void sendMessage(String text, ChatService chatService) async {
    if (text.isNotEmpty) {
      _isSending = true;
      messages.add("You: $text");
      notifyListeners();  // Update UI

      // Simulate a delay or perform actual async operation
      final response = await chatService.sendMessage(text);
      messages.add("Chatbot: $response");

      _isSending = false;
      notifyListeners();  // Update UI again after operation completes
    }
  }
}
