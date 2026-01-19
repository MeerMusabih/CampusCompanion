import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lost_found_provider.dart';
import '../../models/lost_found_model.dart';
import 'package:intl/intl.dart';
import 'add_lost_item_screen.dart';
import 'lost_found_item_screen.dart';
import 'add_found_item_screen.dart';
import '../../providers/theme_provider.dart';
class LostFoundListScreen extends StatefulWidget {
  const LostFoundListScreen({super.key});
  @override
  State<LostFoundListScreen> createState() => _LostFoundListScreenState();
}
class _LostFoundListScreenState extends State<LostFoundListScreen> {
  String _searchQuery = "";
  String _selectedCategory = "All";
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<LostFoundProvider>().fetchItems());
  }
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FC);
    final appBarColor = const Color(0xFF0E3A5D);
    final highlightColor = const Color(0xFFE3A42B);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F2643);
    final subTextColor = isDark ? Colors.white70 : Colors.grey[600];
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
          "Lost & Found",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined, color: Colors.white),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/lost-found/add'),
            icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white24 : Colors.grey[200]!),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Search items by name or location...",
                  hintStyle: TextStyle(color: subTextColor),
                  prefixIcon: Icon(Icons.search, color: subTextColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: ["All", "Lost", "Found"].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? highlightColor : cardColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected ? highlightColor : (isDark ? Colors.white12 : Colors.grey[200]!),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<LostFoundProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final filteredItems = provider.items.where((item) {
                  final matchesSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      item.location.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesCat = _selectedCategory == "All" || item.type == _selectedCategory;
                  return matchesSearch && matchesCat;
                }).toList();
                if (filteredItems.isEmpty) {
                  return _buildEmptyState(context, highlightColor, textColor);
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    return _buildItemCard(context, filteredItems[index], cardColor, textColor, subTextColor, highlightColor);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSelection(context),
        backgroundColor: highlightColor,
        child: Icon(Icons.add, color: appBarColor),
      ),
      bottomNavigationBar: _buildBottomNav(highlightColor, isDark),
    );
  }
  Widget _buildItemCard(BuildContext context, LostFoundModel item, Color cardColor, Color textColor, Color? subTextColor, Color highlightColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      boxShadow: [
          if (!context.read<ThemeProvider>().isDarkMode)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LostFoundItemScreen(item: item),
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 100,
                decoration: BoxDecoration(
                  color: context.read<ThemeProvider>().isDarkMode ? Colors.grey[800] : Colors.grey[200],
                ),
                child: item.imageUrl != null
                    ? Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, o, s) => const Icon(Icons.image_not_supported),
                      )
                    : const Icon(Icons.inventory_2, size: 40, color: Colors.grey),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.bookmark_border, size: 20, color: highlightColor),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(color: subTextColor, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Divider(height: 16),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: highlightColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.location,
                              style: TextStyle(color: subTextColor, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(item.dateTime),
                        style: TextStyle(color: subTextColor, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
  Widget _buildEmptyState(BuildContext context, Color highlightColor, Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No items found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/lost-found/add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: highlightColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Add your first item", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  Widget _buildBottomNav(Color highlightColor, bool isDarkMode) {
    final navBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        if (index == 0) return;
        if (index == 1) Navigator.pushReplacementNamed(context, '/chat');
        if (index == 2) Navigator.pushReplacementNamed(context, '/notifications');
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
  void _showAddSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
        final highlightColor = const Color(0xFFE3A42B);
        final navyColor = const Color(0xFF0E3A5D);
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "What would you like to report?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildMenuOption(
                      context,
                      title: "Lost Item",
                      subtitle: "I lost something",
                      icon: Icons.search_off,
                      color: Colors.redAccent,
                      route: '/lost-found/add',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMenuOption(
                      context,
                      title: "Found Item",
                      subtitle: "I found something",
                      icon: Icons.check_circle_outline,
                      color: Colors.greenAccent,
                      route: '/lost-found/add-found',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  Widget _buildMenuOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDarkMode ? Colors.white12 : Colors.grey[200]!),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
