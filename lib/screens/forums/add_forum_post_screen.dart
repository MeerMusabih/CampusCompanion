import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/forum_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class AddForumPostScreen extends StatefulWidget {
  const AddForumPostScreen({super.key});

  @override
  State<AddForumPostScreen> createState() => _AddForumPostScreenState();
}

class _AddForumPostScreenState extends State<AddForumPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;

  final List<String> _categories = [
    'General', 'Academics', 'Events', 'Lost & Found', 'Help'
  ];

  bool get _isFormValid => 
    _titleController.text.isNotEmpty &&
    _selectedCategory != null &&
    _contentController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
    _contentController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a category")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final forumProvider = Provider.of<ForumProvider>(context, listen: false);

      await forumProvider.addPost(
        _titleController.text,
        _contentController.text,
        authProvider.user?.displayName ?? 'Anonymous',
        authProvider.user?.uid ?? 'Unknown',
        _selectedCategory!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Forum post created successfully")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF7F9FC);
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final highlightColor = const Color(0xFFE3A42B);
    final navyColor = const Color(0xFF0E3A5D);

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
          "Create Forum Post",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined, color: Colors.white),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          TextButton(
            onPressed: (_isFormValid && !_isLoading) ? _submit : null,
            child: Text(
              "POST",
              style: TextStyle(
                color: (_isFormValid && !_isLoading) ? highlightColor : Colors.white30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: highlightColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    label: "Post Title",
                    controller: _titleController,
                    hint: "What's on your mind?",
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 20),
                  _buildDropdownField(
                    label: "Category",
                    value: _selectedCategory,
                    items: _categories,
                    hint: "Select Category",
                    onChanged: (val) => setState(() => _selectedCategory = val),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: "Content",
                    controller: _contentController,
                    hint: "Share more details...",
                    maxLines: 8,
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: "Tags (Optional)",
                    controller: _tagsController,
                    hint: "e.g. calculus, help, exams",
                  ),
                  const SizedBox(height: 30),
                  _buildGuidelinesCard(cardColor, isDarkMode),
                  const SizedBox(height: 40),
                  _buildSubmitButton(highlightColor, navyColor),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDarkMode ? Colors.white10 : Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE3A42B), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(hint, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
              dropdownColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuidelinesCard(Color cardColor, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                "Forum Guidelines",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700], fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildGuidelineItem("Be respectful and professional"),
          _buildGuidelineItem("No spam or offensive content"),
          _buildGuidelineItem("Posts are visible to all students"),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(color: Colors.grey[600])),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 11))),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(Color highlightColor, Color navyColor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: (_isFormValid && !_isLoading) ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: highlightColor,
          foregroundColor: navyColor,
          disabledBackgroundColor: isDarkMode ? Colors.white10 : Colors.grey[200],
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          "Post to Forum",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
