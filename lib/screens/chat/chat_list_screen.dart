import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'chat_detail_screen.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().user?.uid;
      if (userId != null) {
        context.read<ChatProvider>().listenToConversations(userId);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().user?.uid;
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;
    final bgColor = isDarkMode ? const Color(0xFF0B1623) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = (isDarkMode ? Colors.grey[400] : Colors.grey[600]) ?? Colors.grey;
    final dividerColor = isDarkMode ? Colors.white12 : Colors.grey[300]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2643),
        title: const Text("Chats", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined, color: Colors.white),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProv, _) {
          if (chatProv.isLoadingConversations) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (chatProv.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: isDarkMode ? Colors.white24 : Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("No conversations yet", style: TextStyle(color: subTextColor)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/chat/new'),
                    icon: const Icon(Icons.add),
                    label: const Text("Start new chat"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F2643),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chatProv.conversations.length,
            itemBuilder: (context, index) {
              final conversation = chatProv.conversations[index];
              final otherUserId = conversation.participants.firstWhere(
                (id) => id != currentUserId,
                orElse: () => "Unknown",
              );
              final otherUserName = conversation.participantNames[otherUserId] ?? "Anonymous";
              
              return Column(
                children: [
                  _buildChatTile(
                    context, 
                    conversation.id,
                    otherUserName, 
                    conversation.lastMessage, 
                    DateFormat('hh:mm A').format(conversation.lastMessageTime), 
                    Colors.blue,
                    textColor,
                    subTextColor,
                  ),
                  Divider(height: 1, color: dividerColor),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/chat/new'),
        backgroundColor: const Color(0xFFF4C470),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, String conversationId, String name, String subtitle, String time, Color color, Color textColor, Color subTextColor) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : "?", 
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
      subtitle: Text(
        subtitle.isEmpty ? "Start a conversation" : subtitle, 
        maxLines: 1, 
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: subTextColor),
      ),
      trailing: Text(time, style: TextStyle(color: subTextColor, fontSize: 12)),
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              userName: name,
              conversationId: conversationId,
            ),
          ),
        );
      },
    );
  }
}
