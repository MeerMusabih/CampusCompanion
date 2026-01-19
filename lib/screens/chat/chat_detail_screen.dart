import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/theme_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/chat_model.dart';

class ChatDetailScreen extends StatefulWidget {
  final String userName;
  final String conversationId;

  const ChatDetailScreen({
    super.key, 
    required this.userName, 
    required this.conversationId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().listenToMessages(widget.conversationId);
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    final authProv = context.read<AuthProvider>();
    final chatProv = context.read<ChatProvider>();
    
    chatProv.sendMessage(
      widget.conversationId, 
      text, 
      authProv.user!.uid, 
      authProv.user!.email!.split('@')[0], // Simplified sender name
    );
    
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final currentUserId = context.read<AuthProvider>().user?.uid;
    
    final bgColor = isDark ? const Color(0xFF0B1623) : Colors.grey[100];
    final senderBubbleColor = isDark ? const Color(0xFF0F3460) : const Color(0xFF0F2643);
    final receiverBubbleColor = isDark ? const Color(0xFF374151) : Colors.white;
    final senderTextColor = Colors.white;
    final receiverTextColor = isDark ? Colors.white : Colors.black87;
    final timeColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final inputBgColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final fieldColor = isDark ? const Color(0xFF374151) : Colors.grey[100];
    final inputTextColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2643),
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.amber,
              child: Text(
                widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : "?",
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.userName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round, size: 20),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProv, _) {
                if (chatProv.isLoadingMessages && chatProv.activeMessages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = chatProv.activeMessages;

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      "No messages yet. Say hi!",
                      style: TextStyle(color: timeColor),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Show newest at bottom
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isMe ? senderBubbleColor : receiverBubbleColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(12),
                                  topRight: const Radius.circular(12),
                                  bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                                  bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                msg.content,
                                style: TextStyle(
                                  color: isMe ? senderTextColor : receiverTextColor,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('hh:mm a').format(msg.timestamp),
                              style: TextStyle(color: timeColor, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: inputBgColor,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: fieldColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: isDark ? Colors.transparent : Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: inputTextColor),
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                            color: Color(0xFFF4C470),
                            shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
