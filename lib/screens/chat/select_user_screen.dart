import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/firestore_service.dart';
import 'chat_detail_screen.dart';

class SelectUserScreen extends StatefulWidget {
  const SelectUserScreen({super.key});

  @override
  State<SelectUserScreen> createState() => _SelectUserScreenState();
}

class _SelectUserScreenState extends State<SelectUserScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final currentUserId = context.read<AuthProvider>().user?.uid;
    final allUsers = await _firestoreService.getAllUsers();
    
    if (mounted) {
      setState(() {
        // Exclude self from the list
        _users = allUsers.where((u) => u.uid != currentUserId).toList();
        _filteredUsers = _users;
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      _filteredUsers = _users
          .where((u) => u.name.toLowerCase().contains(query.toLowerCase()) || 
                        u.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _startChat(UserModel otherUser) async {
    final authProv = context.read<AuthProvider>();
    final chatProv = context.read<ChatProvider>();
    final selfId = authProv.user!.uid;
    final selfName = authProv.user!.email!.split('@')[0]; // Using email prefix as name if not available

    // Start or get existing conversation
    final conversationId = await chatProv.startConversation(
      selfId, 
      otherUser.uid, 
      selfName, 
      otherUser.name
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            userName: otherUser.name,
            conversationId: conversationId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bgColor = isDark ? const Color(0xFF0B1623) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final searchBg = isDark ? const Color(0xFF1F2937) : Colors.grey[100];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2643),
        title: const Text("New Chat", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterUsers,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Search users...",
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: searchBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Text(
                          "No users found",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _filteredUsers.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              user.name,
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              user.department.isNotEmpty ? user.department : user.email,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                            onTap: () => _startChat(user),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
