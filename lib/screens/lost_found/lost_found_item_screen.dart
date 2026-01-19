import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/lost_found_model.dart';
import '../../providers/theme_provider.dart';
class LostFoundItemScreen extends StatelessWidget {
  final LostFoundModel item;
  const LostFoundItemScreen({super.key, required this.item});
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF7F9FC);
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final highlightColor = const Color(0xFFE3A42B);
    final navyColor = const Color(0xFF0E3A5D);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F2643);
    final subTextColor = isDarkMode ? Colors.white70 : Colors.grey[600];
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: navyColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Item Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined, color: Colors.white),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Item bookmarked"))
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(item, isDarkMode),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(item, cardColor, textColor, subTextColor, highlightColor),
                      const SizedBox(height: 24),
                      const Text(
                        "Description",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.description,
                        style: TextStyle(fontSize: 15, color: subTextColor, height: 1.6),
                      ),
                      if (item.type == 'Found' && item.keptAt != null) ...[
                        const SizedBox(height: 24),
                        const Text(
                          "Handover Location",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: highlightColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: highlightColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: highlightColor, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "This item is kept at: ${item.keptAt}",
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildActionSection(context, item, cardColor, highlightColor, navyColor, isDarkMode),
          ),
        ],
      ),
    );
  }
  Widget _buildImageSection(LostFoundModel item, bool isDarkMode) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black26 : Colors.grey[200],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        child: item.imageUrl != null
            ? Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 60, color: Colors.grey),
              )
            : const Icon(Icons.inventory_2, size: 80, color: Colors.grey),
      ),
    );
  }
  Widget _buildInfoCard(LostFoundModel item, Color cardColor, Color textColor, Color? subTextColor, Color highlightColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(item.type),
              Text(
                DateFormat('MMM dd, yyyy').format(item.dateTime),
                style: TextStyle(color: subTextColor, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            item.title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.category_outlined, "Category", item.title.contains('Card') ? 'ID Card' : 'General'),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.location_on_outlined, item.type == 'Lost' ? "Last Seen" : "Found At", item.location, highlightColor),
        ],
      ),
    );
  }
  Widget _buildStatusBadge(String type) {
    final isLost = type == 'Lost';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLost ? Colors.redAccent.withOpacity(0.1) : Colors.greenAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isLost ? Colors.redAccent.withOpacity(0.3) : Colors.greenAccent.withOpacity(0.3)),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: isLost ? Colors.redAccent : Colors.greenAccent[700],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
  Widget _buildDetailRow(IconData icon, String label, String value, [Color? iconColor]) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor ?? Colors.grey),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  Widget _buildActionSection(BuildContext context, LostFoundModel item, Color cardColor, Color highlightColor, Color navyColor, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: highlightColor,
                    foregroundColor: navyColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    item.type == 'Lost' ? "I Found This" : "Contact Owner",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDarkMode ? Colors.white12 : Colors.grey[200]!),
                ),
                child: IconButton(
                  onPressed: () {
                  },
                  icon: Icon(Icons.chat_bubble_outline, color: highlightColor),
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "For your safety, avoid meeting alone and prefer public campus locations.",
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
