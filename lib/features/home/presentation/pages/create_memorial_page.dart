import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:online_graveyard/features/auth/presentation/providers/auth_provider.dart';
import 'package:online_graveyard/features/home/domain/entities/memorial.dart';
import 'package:online_graveyard/features/home/presentation/providers/memorial_provider.dart';
import 'package:online_graveyard/theme/app_colors.dart';
import 'package:online_graveyard/theme/app_text_styles.dart';

class CreateMemorialPage extends StatefulWidget {
  const CreateMemorialPage({super.key});

  @override
  State<CreateMemorialPage> createState() => _CreateMemorialPageState();
}

class _CreateMemorialPageState extends State<CreateMemorialPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _epitaphController = TextEditingController();
  
  DateTime? _birthDate;
  DateTime? _deathDate;
  String _category = 'family';
  Uint8List? _profileImageBytes;
  
  final ImagePicker _picker = ImagePicker();

  List<Uint8List> _galleryImageBytesList = [];
  
  /// Check if the form has the minimum required fields filled.
  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
           _birthDate != null &&
           _deathDate != null;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _profileImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load image: $e')),
        );
      }
    }
  }

  Future<void> _pickGalleryImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (images.isNotEmpty) {
        final List<Uint8List> newImages = [];
        for (var img in images) {
          final bytes = await img.readAsBytes();
          newImages.add(bytes);
        }
        setState(() {
          _galleryImageBytesList.addAll(newImages);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load gallery images: $e')),
        );
      }
    }
  }

  void _removeGalleryImage(int index) {
    setState(() {
      _galleryImageBytesList.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null || _deathDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both birth and death dates'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Prepare Auth user info
    final authUser = context.read<AuthProvider>().currentUser;
    final userId = authUser?.uid ?? 'anonymous';

    final memorial = Memorial(
      id: '',
      name: _nameController.text.trim(),
      birthDate: _birthDate!,
      deathDate: _deathDate!,
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      epitaph: _epitaphController.text.trim().isEmpty ? null : _epitaphController.text.trim(),
      category: _category,
      createdAt: DateTime.now(),
      createdBy: userId,
      candleCount: 0,
      flowerCount: 0,
    );

    final provider = context.read<MemorialProvider>();
    // Updated createMemorial signature to accept gallery list
    final id = await provider.createMemorial(
      memorial, 
      profileImageBytes: _profileImageBytes,
      galleryImageBytesList: _galleryImageBytesList,
    );

    if (mounted) {
      if (id != null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Memorial created successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to create memorial'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _epitaphController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<MemorialProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Create Memorial',
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 100), // Extra padding for button
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... Profile Photo Picker ...
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Column(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.08),
                              image: _profileImageBytes != null
                                  ? DecorationImage(
                                      image: MemoryImage(_profileImageBytes!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              border: Border.all(
                                color: _profileImageBytes != null
                                    ? AppColors.primary.withValues(alpha: 0.3)
                                    : AppColors.borderLight,
                                width: 2,
                              ),
                            ),
                            child: _profileImageBytes == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_rounded, size: 32, color: AppColors.primary.withValues(alpha: 0.5)),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Add Photo',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.primary.withValues(alpha: 0.5),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ... (Existing fields: Personal Info, Dates, Category, Story) ...
                  _sectionLabel('Personal Information'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name *',
                    hint: 'e.g. Eleanor Rose Mitchell',
                    icon: Icons.person_outline_rounded,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _DatePickerField(
                          label: 'Born *',
                          selectedDate: _birthDate,
                          icon: Icons.cake_outlined,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime(1980),
                              firstDate: DateTime(1800),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) setState(() => _birthDate = date);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DatePickerField(
                          label: 'Passed *',
                          selectedDate: _deathDate,
                          icon: Icons.event_outlined,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1800),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) setState(() => _deathDate = date);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: _inputDecoration(
                      label: 'Relationship',
                      icon: Icons.people_outline_rounded,
                    ),
                    dropdownColor: AppColors.surfaceLight,
                    style: AppTextStyles.bodyText.copyWith(color: AppColors.textPrimary),
                    items: const [
                       DropdownMenuItem(value: 'family', child: Text('Family')),
                       DropdownMenuItem(value: 'friends', child: Text('Friend')),
                       DropdownMenuItem(value: 'colleagues', child: Text('Colleague')),
                       DropdownMenuItem(value: 'famous', child: Text('Public Figure')),
                       DropdownMenuItem(value: 'pets', child: Text('Pet')),
                    ],
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                  const SizedBox(height: 24),

                  _sectionLabel('Their Story'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _epitaphController,
                    label: 'Epitaph / Quote',
                    hint: 'A short phrase to remember them by',
                    icon: Icons.format_quote_rounded,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _bioController,
                    label: 'Biography',
                    hint: 'Tell their story — their passions, their legacy...',
                    icon: Icons.article_outlined,
                    maxLines: 5,
                    alignLabelWithHint: true,
                  ),
                  const SizedBox(height: 24),

                  // ─── Gallery Section ────────────────────
                  _sectionLabel('Gallery'),
                  const SizedBox(height: 12),
                  Text(
                    'Add photos to their memorial gallery.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: _galleryImageBytesList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _galleryImageBytesList.length) {
                        return InkWell(
                          onTap: _pickGalleryImages,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: const Center(
                              child: Icon(Icons.add_photo_alternate_outlined, color: AppColors.textMuted),
                            ),
                          ),
                        );
                      }
                      
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _galleryImageBytesList[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeGalleryImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: ElevatedButton(
                        onPressed: (isLoading || !_isFormValid) ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: _isFormValid ? 3 : 0,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.spa_rounded, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Create Memorial',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  // Required hint
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      '* Required fields',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (isLoading)
             Container(
               color: Colors.black.withValues(alpha: 0.15),
               child: const Center(
                 child: CircularProgressIndicator(color: AppColors.primary),
               ),
             ),
        ],
      ),
    );
  }


  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.dividerLabel.copyWith(
        color: AppColors.textMuted,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _inputDecoration({required String label, IconData? icon, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
      prefixIcon: icon != null ? Icon(icon, size: 20, color: AppColors.textMuted) : null,
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    bool alignLabelWithHint = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      style: AppTextStyles.bodyText.copyWith(color: AppColors.textPrimary),
      maxLines: maxLines,
      decoration: _inputDecoration(label: label, icon: icon, hint: hint).copyWith(
        alignLabelWithHint: alignLabelWithHint,
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final IconData? icon;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.selectedDate,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasDate = selectedDate != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: hasDate ? AppColors.primary.withValues(alpha: 0.3) : AppColors.borderLight),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: hasDate ? AppColors.primary : AppColors.textMuted),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: hasDate ? AppColors.primary : AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasDate
                        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                        : 'Select',
                    style: AppTextStyles.bodyText.copyWith(
                      color: hasDate ? AppColors.textPrimary : AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
