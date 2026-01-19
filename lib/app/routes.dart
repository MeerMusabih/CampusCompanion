import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/timetable/timetable_screen.dart';
import '../screens/events/event_list_screen.dart';
import '../screens/lost_found/lost_found_list_screen.dart';
import '../screens/lost_found/add_lost_item_screen.dart';
import '../screens/lost_found/add_found_item_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/select_user_screen.dart';
import '../screens/forums/add_forum_post_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/forums/forums_screen.dart';
import '../screens/forums/forum_post_detail_screen.dart';
import '../models/forum_post_model.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/manage_notices_screen.dart';
import '../screens/admin/manage_events_screen.dart';
import '../screens/admin/manage_timetable_screen.dart';
import '../screens/notifications/notification_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/notices/bookmarks_screen.dart';
import '../screens/profile/bookmarks_screen.dart';
import '../screens/profile/my_posts_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/profile/help_support_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/manage_users_screen.dart';
import '../screens/admin/add_user_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),
    '/home': (context) => const HomeScreen(),    
    '/timetable': (context) => const TimetableScreen(),
    '/events': (context) => const EventListScreen(),
    '/lost-found': (context) => const LostFoundListScreen(),
    '/lost-found/add': (context) => const AddLostItemScreen(),
    '/lost-found/add-found': (context) => const AddFoundItemScreen(),
    '/chat': (context) => const ChatListScreen(),
    '/chat/new': (context) => const SelectUserScreen(),
    '/forums/add': (context) => const AddForumPostScreen(),
    '/profile': (context) => const ProfileScreen(),
    '/forums': (context) => const ForumsScreen(),    
    '/forums/post': (context) {
      final post = ModalRoute.of(context)!.settings.arguments as ForumPostModel;
      return ForumPostDetailScreen(post: post);
    },
    '/admin': (context) => const AdminDashboardScreen(),
    '/admin/notices': (context) => const ManageNoticesScreen(),
    '/admin/events': (context) => const ManageEventsScreen(),
    '/admin/timetable': (context) => const ManageTimetableScreen(),
    '/notifications': (context) => const NotificationScreen(),
    '/forgot-password': (context) => const ForgotPasswordScreen(),
    '/bookmarks': (context) => const BookmarksScreen(),
    '/profile/my-posts': (context) => const MyPostsScreen(),
    '/settings': (context) => const SettingsScreen(),
    '/help-support': (context) => const HelpSupportScreen(),
    '/admin/dashboard': (context) => const AdminDashboardScreen(),
    '/admin/users': (context) => const ManageUsersScreen(),
    '/admin/add-user': (context) => const AddUserScreen(),
  };
}
