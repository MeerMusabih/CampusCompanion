import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../providers/theme_provider.dart';

class ManageEventsScreen extends StatefulWidget {
  const ManageEventsScreen({super.key});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().fetchEvents();
    });
  }

  void _showAddEventDialog(bool isDark, Color cardColor, Color textColor, Color subTextColor, Color highlightColor) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final locController = TextEditingController();
    final organizerController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedCategory = 'General';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text("Add New Event", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogField("Title", titleController, Icons.title, textColor, subTextColor, isDark),
                  const SizedBox(height: 16),
                  _buildDialogField("Description", descController, Icons.description, textColor, subTextColor, isDark, maxLines: 3),
                  const SizedBox(height: 16),
                  _buildDialogField("Location", locController, Icons.location_on_outlined, textColor, subTextColor, isDark),
                  const SizedBox(height: 16),
                  _buildDialogField("Organizer", organizerController, Icons.person_outline, textColor, subTextColor, isDark),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Date",
                        labelStyle: TextStyle(color: subTextColor),
                        prefixIcon: Icon(Icons.calendar_today, color: highlightColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(DateFormat('MMM d, yyyy').format(selectedDate), style: TextStyle(color: textColor)),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                    items: ['General', 'Workshop', 'Seminar', 'Tech Gala', 'Sports']
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedCategory = v!),
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
                  if (titleController.text.isNotEmpty && descController.text.isNotEmpty) {
                    final newEvent = EventModel(
                      id: '',
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      location: locController.text.trim(),
                      dateTime: selectedDate,
                      organizer: organizerController.text.trim(),
                      category: selectedCategory,
                      registeredUsers: [],
                    );
                    await context.read<EventProvider>().addEvent(newEvent);
                    if (mounted) Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E3A5D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Post Event", style: TextStyle(color: Colors.white)),
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
    final eventProv = context.watch<EventProvider>();

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
        title: const Text("Manage Events", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: highlightColor,
        onPressed: () => _showAddEventDialog(isDark, cardColor, textColor, subTextColor, highlightColor),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: eventProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: eventProv.events.length,
              itemBuilder: (context, index) {
                final event = eventProv.events[index];
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
                        color: highlightColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.event, color: highlightColor, size: 20),
                    ),
                    title: Text(
                      event.title,
                      style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 15),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(event.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: subTextColor, fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 12, color: subTextColor),
                            const SizedBox(width: 4),
                            Text(event.location, style: TextStyle(color: subTextColor, fontSize: 11)),
                            const SizedBox(width: 12),
                            Icon(Icons.calendar_today, size: 12, color: subTextColor),
                            const SizedBox(width: 4),
                            Text(DateFormat('MMM d').format(event.dateTime), style: TextStyle(color: subTextColor, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => eventProv.deleteEvent(event.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
