import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/timetable_model.dart';
import '../../providers/timetable_provider.dart';
import '../../providers/theme_provider.dart';

class ManageTimetableScreen extends StatefulWidget {
  const ManageTimetableScreen({super.key});

  @override
  State<ManageTimetableScreen> createState() => _ManageTimetableScreenState();
}

class _ManageTimetableScreenState extends State<ManageTimetableScreen> {
  String selectedDay = 'Monday';
  String selectedDept = 'Education';

  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  final List<String> departments = ['Education', 'History', 'ICT', 'Business', 'Linguistics'];

  void _showAddEntryDialog(bool isDark, Color cardColor, Color textColor, Color subTextColor, Color highlightColor) {
    final subjectController = TextEditingController();
    final lecturerController = TextEditingController();
    final roomController = TextEditingController();
    final timeController = TextEditingController();
    String dialogDay = selectedDay;
    String dialogDept = selectedDept;
    String selectedSection = 'A';
    String selectedSemester = '1';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text("Add Timetable Entry", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   _buildDialogField("Subject", subjectController, Icons.book_outlined, textColor, subTextColor, isDark),
                  const SizedBox(height: 16),
                  _buildDialogField("Lecturer", lecturerController, Icons.person_outline, textColor, subTextColor, isDark),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildDialogField("Room", roomController, Icons.room_outlined, textColor, subTextColor, isDark)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDialogField("Time (e.g. 08:00)", timeController, Icons.access_time, textColor, subTextColor, isDark)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown("Day", dialogDay, days, (v) => setDialogState(() => dialogDay = v!), cardColor, textColor, subTextColor, highlightColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown("Dept", dialogDept, departments, (v) => setDialogState(() => dialogDept = v!), cardColor, textColor, subTextColor, highlightColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown("Sem", selectedSemester, ['1','2','3','4','5','6','7','8'], (v) => setDialogState(() => selectedSemester = v!), cardColor, textColor, subTextColor, highlightColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown("Sec", selectedSection, ['A','B','C'], (v) => setDialogState(() => selectedSection = v!), cardColor, textColor, subTextColor, highlightColor),
                      ),
                    ],
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
                  if (subjectController.text.isNotEmpty && timeController.text.isNotEmpty) {
                    final newEntry = TimetableModel(
                      id: '',
                      title: subjectController.text.trim(),
                      prof: lecturerController.text.trim(),
                      room: roomController.text.trim(),
                      startTime: timeController.text.trim(),
                      endTime: "10:00", // Default or add field
                      day: dialogDay,
                      department: dialogDept,
                      semester: selectedSemester,
                      section: selectedSection,
                      type: 'Lecture',
                    );
                    await context.read<TimetableProvider>().addEntry(newEntry);
                    if (mounted) Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E3A5D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Save Entry", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller, IconData icon, Color textColor, Color subTextColor, bool isDark) {
    return TextField(
      controller: controller,
      style: TextStyle(color: textColor, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: subTextColor, fontSize: 12),
        prefixIcon: Icon(icon, color: const Color(0xFFE3A42B), size: 20),
        isDense: true,
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

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged, Color cardColor, Color textColor, Color subTextColor, Color highlightColor) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: cardColor,
      style: TextStyle(color: textColor, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: subTextColor, fontSize: 12),
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final timetableProv = context.watch<TimetableProvider>();

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final navyColor = const Color(0xFF0E3A5D);
    final highlightColor = const Color(0xFFE3A42B);
    final textColor = isDark ? Colors.white : const Color(0xFF0F2643);
    final subTextColor = (isDark ? Colors.grey[400] : Colors.grey[600]) ?? Colors.grey;

    final filteredEntries = timetableProv.entries.where((e) => e.day == selectedDay && e.department == selectedDept).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: navyColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Manage Timetable", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: highlightColor,
        onPressed: () => _showAddEntryDialog(isDark, cardColor, textColor, subTextColor, highlightColor),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: cardColor,
            child: Column(
              children: [
                _buildFilterRow("Day", selectedDay, days, (v) => setState(() => selectedDay = v!), textColor, highlightColor),
                const SizedBox(height: 12),
                _buildFilterRow("Dept", selectedDept, departments, (v) => setState(() => selectedDept = v!), textColor, highlightColor),
              ],
            ),
          ),
          Expanded(
            child: timetableProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredEntries.isEmpty
                    ? _buildEmptyState(textColor)
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: filteredEntries.length,
                        itemBuilder: (context, index) {
                          final entry = filteredEntries[index];
                          return _buildTimetableCard(entry, cardColor, textColor, subTextColor, highlightColor, () {
                            timetableProv.deleteEntry(entry.id);
                          });
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(String label, String value, List<String> items, ValueChanged<String?> onChanged, Color textColor, Color highlightColor) {
    return Row(
      children: [
        SizedBox(width: 50, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items.map((item) {
                final isSelected = item == value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(item, style: TextStyle(color: isSelected ? Colors.white : textColor, fontSize: 12)),
                    selected: isSelected,
                    onSelected: (selected) => selected ? onChanged(item) : null,
                    selectedColor: const Color(0xFF0E3A5D),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3))),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimetableCard(TimetableModel entry, Color cardColor, Color textColor, Color subTextColor, Color highlightColor, VoidCallback onDelete) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: highlightColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text(entry.startTime, style: TextStyle(color: highlightColor, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 15)),
                const SizedBox(height: 2),
                Text("Room: ${entry.room} • ${entry.prof}", style: TextStyle(color: subTextColor, fontSize: 12)),
                const SizedBox(height: 2),
                Text("Sem ${entry.semester} • Sec ${entry.section}", style: TextStyle(color: subTextColor.withOpacity(0.7), fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 60, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text("No entries for this selection", style: TextStyle(color: textColor.withOpacity(0.5))),
        ],
      ),
    );
  }
}
