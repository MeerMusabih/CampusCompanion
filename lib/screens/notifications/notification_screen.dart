import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/notification_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/notification_model.dart';
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}
class _NotificationScreenState extends State<NotificationScreen> {
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProv = context.read<AuthProvider>();
      if (authProv.user != null) {
        context.read<NotificationProvider>().loadNotifications(authProv.user!.uid);
      }
    });
  }
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat.yMMMd().format(timestamp);
    }
  }
  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.notice:
        return Icons.campaign;
      case NotificationType.event:
        return Icons.event;
      case NotificationType.lostFound:
        return Icons.search;
      case NotificationType.chat:
        return Icons.chat_bubble_outline;
      case NotificationType.forum:
        return Icons.forum_outlined;
    }
  }
  @override
  Widget build(BuildContext context) {
    final notificationProv = context.watch<NotificationProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    final isDark = themeProvider.isDarkMode;
    final notifications = notificationProv.notifications;
    
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FC);
    final appBarColor = const Color(0xFF0E3A5D);
    final highlightColor = const Color(0xFFE3A42B);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F2643);
    final subTextColor = (isDark ? Colors.white70 : Colors.grey[600]) ?? Colors.grey;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: Colors.white),
            tooltip: 'Mark all as read',
            onPressed: () => notificationProv.markAllAsRead(),
          ),
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined, color: Colors.white),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(subTextColor)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(notification, cardColor, textColor, subTextColor, highlightColor, notificationProv);
              },
            ),
      bottomNavigationBar: _buildBottomNav(highlightColor, isDark),
    );
  }
  Widget _buildNotificationCard(NotificationModel notification, Color cardColor, Color textColor, Color subTextColor, Color highlightColor, NotificationProvider prov) {
    return GestureDetector(
      onTap: () => prov.markAsRead(notification.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? cardColor : highlightColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead ? Colors.transparent : highlightColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            if (context.read<ThemeProvider>().isDarkMode == false)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: highlightColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(notification.type),
                color: highlightColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                            fontSize: 15,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: highlightColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.description,
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTimestamp(notification.timestamp),
                    style: TextStyle(
                      color: subTextColor.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildEmptyState(Color subTextColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 80,
            color: subTextColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No notifications yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: subTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll notify you when something important happens!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: subTextColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildBottomNav(Color highlightColor, bool isDarkMode) {
    final navBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index == 0) Navigator.pushReplacementNamed(context, '/home');
        if (index == 1) Navigator.pushReplacementNamed(context, '/chat');
        if (index == 3) Navigator.pushReplacementNamed(context, '/profile');
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: navBg,
      selectedItemColor: highlightColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
      ],
    );
  }
}
