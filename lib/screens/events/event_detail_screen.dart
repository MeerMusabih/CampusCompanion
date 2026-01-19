import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/constants.dart';
class EventDetailScreen extends StatelessWidget {
  final EventModel event;
  const EventDetailScreen({super.key, required this.event});
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final userId = context.read<AuthProvider>().user?.uid;
    
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                event.title,
                style: const TextStyle(
                  shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                ),
              ),
              background: event.imageUrl!.isNotEmpty
                  ? Image.network(event.imageUrl ?? '', fit: BoxFit.cover)
                  : Container(
                      color: AppColors.primary,
                      child: const Icon(
                        Icons.event,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined, color: Colors.white),
                onPressed: () => themeProvider.toggleTheme(),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    Icons.calendar_month,
                    "Date",
                    DateFormat('EEE, MMM d, yyyy').format(event.dateTime),
                    isDark,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  _buildInfoRow(
                    Icons.access_time,
                    "Time",
                    DateFormat('hh:mm a').format(event.dateTime),
                    isDark,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    "Venue",
                    event.location,
                    isDark,
                  ),
                  const Divider(height: 40),
                  const Text(
                    "About Event",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Attendees",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${event.registeredUsers.length} students have joined this event",
                    style: TextStyle(color: subTextColor),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildRegistrationBar(context, userId, isDark),
    );
  }
  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildRegistrationBar(BuildContext context, String? userId, bool isDark) {
    final isRegistered = event.registeredUsers.contains(userId);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isRegistered
                ? Colors.redAccent
                : AppColors.primary,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            if (userId != null) {
              context.read<EventProvider>().toggleRegistration(
                event.id,
                userId,
              );
              Navigator.pop(context);
            }
          },
          child: Text(
            isRegistered ? "Unregister from Event" : "Register Now",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
