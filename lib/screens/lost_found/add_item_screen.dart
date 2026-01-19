import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/lost_found_model.dart';
import '../../providers/lost_found_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});
  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}
class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  String _itemType = 'Lost';
  File? _selectedImage;
  bool _isUploading = false;
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }
  void _submitItem() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      AppUtils.showSnackBar(
        context,
        "Please fill all fields and select an image",
      );
      return;
    }
    setState(() => _isUploading = true);
    try {
      final user = context.read<AuthProvider>().user;
      final provider = context.read<LostFoundProvider>();
      final newItem = LostFoundModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        location: _locationController.text.trim(),
        type: _itemType,
        dateTime: DateTime.now(),
        postedBy: user!.uid,
        contactInfo:
            user.email ??
            "No contact provided",
        isResolved: false,
      );
      final imageBytes = await _selectedImage!.readAsBytes();
      final fileName = _selectedImage!.path.split('/').last;
      await provider.addItem(newItem, imageBytes, fileName);
      if (mounted) {
        Navigator.pop(context);
        AppUtils.showSnackBar(context, "Item posted successfully!");
      }
    } catch (e) {
      AppUtils.showSnackBar(context, "Error: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }
  Future<void> saveItemToDatabase(
    String title,
    String desc,
    String location,
    String imageUrl,
  ) async {
    final supabase = Supabase.instance.client;
    try {
      await supabase.from('lost_items').insert({
        'title': title,
        'description': desc,
        'location': location,
        'image_url': imageUrl,
      });
      print("Item posted successfully!");
    } catch (e) {
      print("Error saving to table: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;
    final navyColor = const Color(0xFF0E3A5D);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: navyColor,
        title: const Text("Report Item", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 50,
                              color: Colors.grey,
                            ),
                            Text("Tap to add item photo"),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    "Item Type: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text("Lost"),
                    selected: _itemType == 'Lost',
                    onSelected: (val) => setState(() => _itemType = 'Lost'),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text("Found"),
                    selected: _itemType == 'Found',
                    onSelected: (val) => setState(() => _itemType = 'Found'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _titleController,
                hintText: "Item Title (e.g. Blue Wallet)",
                prefixIcon: Icons.title,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _locationController,
                hintText: "Where was it found/lost?",
                prefixIcon: Icons.location_on,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _descController,
                hintText: "Detailed Description...",
                prefixIcon: Icons.description,
                maxLines: 4,
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: "Post Item",
                onPressed: _submitItem,
                isLoading: _isUploading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
