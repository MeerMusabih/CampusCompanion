import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/firestore_service.dart';
class ChatProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<ChatConversationModel> _conversations = [];
  bool _isLoadingConversations = true;
  List<ChatConversationModel> get conversations => _conversations;
  bool get isLoadingConversations => _isLoadingConversations;
  List<ChatMessageModel> _activeMessages = [];
  bool _isLoadingMessages = false;
  List<ChatMessageModel> get activeMessages => _activeMessages;
  bool get isLoadingMessages => _isLoadingMessages;
  void listenToConversations(String userId) {
    _isLoadingConversations = true;
    _firestoreService.getConversations(userId).listen((chats) {
      _conversations = chats;
      _isLoadingConversations = false;
      notifyListeners();
    });
  }
  void listenToMessages(String conversationId) {
    _isLoadingMessages = true;
    _activeMessages = [];
    notifyListeners();
    _firestoreService.getMessages(conversationId).listen((messages) {
      _activeMessages = messages;
      _isLoadingMessages = false;
      notifyListeners();
    });
  }
  Future<void> sendMessage(String conversationId, String content, String senderId, String senderName) async {
    final message = ChatMessageModel(
      id: '',
      senderId: senderId,
      content: content,
      timestamp: DateTime.now(),
    );
    await _firestoreService.sendMessage(conversationId, message, content, senderName);
  }
  Future<String> startConversation(String selfId, String otherId, String selfName, String otherName) async {
    return await _firestoreService.createConversation(selfId, otherId, selfName, otherName);
  }
}
