import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/notice_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notice_provider.dart';
import '../../providers/theme_provider.dart';

class ManageNoticesScreen extends StatefulWidget {
  const ManageNoticesScreen({super.key});

  @override
  State<ManageNoticesScreen> createState() => _ManageNoticesScreenState();
}

class _ManageNoticesScreenState extends State<ManageNoticesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoticeProvider>().fetchNotices();
    });
  }

  void _showAddNoticeDialog(bool isDark, Color cardColor, Color textColor, Color subTextColor, Color highlightColor) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final attachmentController = TextEditingController();
    String selectedCategory = 'General';
    bool isUrgent = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text("Add New Notice", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogField("Title", titleController, Icons.title, textColor, subTextColor, isDark),
                  const SizedBox(height: 16),
                  _buildDialogField("Content", contentController, Icons.description, textColor, subTextColor, isDark, maxLines: 4),
                  const SizedBox(height: 16),
                  _buildDialogField("Attachment URL", attachmentController, Icons.link, textColor, subTextColor, isDark),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    dropdownColor: cardColor,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: "Category",
                      labelStyle: TextStyle(color: subTextColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.category, color: highlightColor),
                    ),
                    items: ['General', 'Exam', 'Holiday', 'Placement']
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedCategory = v!),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text("Mark as Urgent", style: TextStyle(color: textColor, fontSize: 14)),
                    secondary: Icon(Icons.priority_high, color: isUrgent ? Colors.red : subTextColor),
                    value: isUrgent,
                    activeColor: Colors.red,
                    onChanged: (v) => setDialogState(() => isUrgent = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: TextStyle(color: subTextColor)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                    final user = context.read<AuthProvider>().user;
                    final newNotice = NoticeModel(
                      id: '',
                      title: titleController.text.trim(),
                      content: contentController.text.trim(),
                      category: selectedCategory,
                      timestamp: DateTime.now(),
                      attachmentUrl: attachmentController.text.trim().isEmpty ? null : attachmentController.text.trim(),
                      isUrgent: isUrgent,
                      authorName: user?.displayName ?? "Admin",
                    );
                    await context.read<NoticeProvider>().addNotice(newNotice);
                    if (mounted) Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E3A5D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Post Notice", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller, IconData icon, Color textColor, Color subTextColor, bool isDark, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: subTextColor),
        prefixIcon: Icon(icon, color: const Color(0xFFE3A42B)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0E3A5D)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final noticeProv = context.watch<NoticeProvider>();

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final navyColor = const Color(0xFF0E3A5D);
    final highlightColor = const Color(0xFFE3A42B);
    final textColor = isDark ? Colors.white : const Color(0xFF0F2643);
    final subTextColor = (isDark ? Colors.grey[400] : Colors.grey[600]) ?? Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: navyColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Manage Notices", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: highlightColor,
        onPressed: () => _showAddNoticeDialog(isDark, cardColor, textColor, subTextColor, highlightColor),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: noticeProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: noticeProv.notices.length,
              itemBuilder: (context, index) {
                final notice = noticeProv.notices[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: notice.isUrgent ? Colors.red.withOpacity(0.1) : highlightColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        notice.isUrgent ? Icons.priority_high : Icons.article_outlined,
                        color: notice.isUrgent ? Colors.red : highlightColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notice.title,
                      style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 15),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notice.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: subTextColor, fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 12, color: subTextColor),
                            const SizedBox(width: 4),
                            Text(DateFormat('MMM d, yyyy').format(notice.timestamp), style: TextStyle(color: subTextColor, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => noticeProv.deleteNotice(notice.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
