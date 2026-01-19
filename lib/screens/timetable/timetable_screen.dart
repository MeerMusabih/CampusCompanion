import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/timetable_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/timetable_model.dart';
import '../../core/constants.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});
  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  String _selectedDay = 'Monday';
  String _selectedDept = 'BSCS';
  String _selectedSem = '1';
  String _selectedSec = 'A';
  final List<String> _days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
  ];
  final List<String> _depts = ["BSCS", "BSSE", "CS", "SE", "IT", "AI", "DS"];
  final List<String> _semesters = ["1", "2", "3", "4", "5", "6", "7", "8"];
  final List<String> _sections = ["A", "B", "C"];
  final List<String> _timeSlots = [
    "08:30",
    "09:00",
    "09:30",
    "10:00",
    "10:30",
    "11:00",
    "11:30",
    "12:00",
    "12:30",
    "13:00",
    "13:30",
    "14:00",
    "14:30",
    "15:00",
    "15:30",
    "16:00",
  ];
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FC);
    final appBarColor = const Color(0xFF0E3A5D);
    final highlightColor = const Color(0xFFE3A42B);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F2643);
    final subTextColor =
        (isDark ? Colors.white70 : Colors.grey[600]) ?? Colors.grey;
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
          "Timetable",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
              color: Colors.white,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildFilterPanel(cardColor, textColor, highlightColor),
          _buildDaySelector(highlightColor, textColor, subTextColor),
          Expanded(
            child: _buildGrid(
              cardColor,
              textColor,
              subTextColor,
              highlightColor,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(highlightColor, isDark),
    );
  }

  Widget _buildFilterPanel(
    Color cardColor,
    Color textColor,
    Color highlightColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(
          bottom: BorderSide(
            color: context.read<ThemeProvider>().isDarkMode
                ? Colors.white12
                : Colors.grey[200]!,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  "Dept",
                  _selectedDept,
                  _depts,
                  (val) => setState(() => _selectedDept = val!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  "Sem",
                  _selectedSem,
                  _semesters,
                  (val) => setState(() => _selectedSem = val!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  "Sec",
                  _selectedSec,
                  _sections,
                  (val) => setState(() => _selectedSec = val!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final highlightColor = const Color(0xFFE3A42B);
    final borderColor = isDark
        ? highlightColor.withOpacity(0.5)
        : Colors.grey[300]!;
    final dropdownColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: dropdownColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: dropdownColor,
              iconEnabledColor: isDark ? Colors.white70 : Colors.grey[700],
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F2643),
                fontSize: 14,
              ),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector(
    Color highlightColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final day = _days[index];
          final isSelected = day == _selectedDay;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(day),
              selected: isSelected,
              onSelected: (selected) => setState(() => _selectedDay = day),
              selectedColor: highlightColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: context.read<ThemeProvider>().isDarkMode
                  ? const Color(0xFF1E293B)
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : (context.read<ThemeProvider>().isDarkMode
                            ? Colors.white12
                            : Colors.grey[200]!),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid(
    Color cardColor,
    Color textColor,
    Color subTextColor,
    Color highlightColor,
  ) {
    final provider = context.watch<TimetableProvider>();
    final entries = provider.getFilteredEntries(
      day: _selectedDay,
      department: _selectedDept,
      semester: _selectedSem,
      section: _selectedSec,
    );
    final rooms = entries.map((e) => e.room).toSet().toList();
    if (rooms.isEmpty) rooms.add("No Rooms");
    rooms.sort();
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final gridBorderColor = isDark ? Colors.white12 : Colors.grey[300]!;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF152336)
                        : const Color(0xFFE2E8F0),
                    border: Border.all(color: gridBorderColor),
                  ),
                ),
                ..._timeSlots.map(
                  (time) => Container(
                    width: 100,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF152336)
                          : const Color(0xFFE2E8F0),
                      border: Border.all(color: gridBorderColor),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF0F2643),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ...rooms.map(
              (room) => Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF152336)
                          : const Color(0xFFF1F5F9),
                      border: Border.all(color: gridBorderColor),
                    ),
                    child: Text(
                      room,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF0F2643),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ..._timeSlots.map((time) {
                    final classInSlot = entries
                        .where((e) => e.room == room && e.startTime == time)
                        .toList();
                    return Container(
                      width: 100,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: gridBorderColor),
                      ),
                      child: classInSlot.isNotEmpty
                          ? _buildClassItem(classInSlot.first, highlightColor)
                          : null,
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassItem(TimetableModel item, Color highlightColor) {
    return GestureDetector(
      onTap: () => _showClassDetail(item),
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: item.type == 'Lab'
              ? Colors.blue.withOpacity(0.1)
              : highlightColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: item.type == 'Lab'
                ? Colors.blue.withOpacity(0.3)
                : highlightColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  item.type == 'Lab' ? Icons.biotech : Icons.school,
                  size: 10,
                  color: item.type == 'Lab' ? Colors.blue : highlightColor,
                ),
                const SizedBox(width: 2),
                Text(item.section, style: const TextStyle(fontSize: 9)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showClassDetail(TimetableModel item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.type,
                    style: TextStyle(
                      color: item.type == 'Lab'
                          ? Colors.blue
                          : const Color(0xFFE3A42B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${item.startTime} - ${item.endTime}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _detailRow(Icons.person_outline, item.prof),
              _detailRow(Icons.room_outlined, "Room: ${item.room}"),
              _detailRow(
                Icons.groups_outlined,
                "Section: ${item.department} - ${item.semester}${item.section}",
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E3A5D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Close",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBottomNav(Color highlightColor, bool isDarkMode) {
    final navBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    return BottomNavigationBar(
      currentIndex: 2,
      onTap: (index) {
        if (index == 0) Navigator.pushReplacementNamed(context, '/home');
        if (index == 1) Navigator.pushReplacementNamed(context, '/chat');
        if (index == 3)
          Navigator.pushReplacementNamed(context, '/notifications');
        if (index == 4) Navigator.pushReplacementNamed(context, '/profile');
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: navBg,
      selectedItemColor: highlightColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: "Chat",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "Timetable",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          label: "Notifications",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Profile",
        ),
      ],
    );
  }
}
