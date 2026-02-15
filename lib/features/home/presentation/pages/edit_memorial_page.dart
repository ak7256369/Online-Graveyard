import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:online_graveyard/features/auth/presentation/providers/auth_provider.dart';
import 'package:online_graveyard/features/home/domain/entities/memorial.dart';
import 'package:online_graveyard/features/home/presentation/providers/memorial_provider.dart';
import 'package:online_graveyard/theme/app_colors.dart';
import 'package:online_graveyard/theme/app_text_styles.dart';

class EditMemorialPage extends StatefulWidget {
  final Memorial memorial;

  const EditMemorialPage({super.key, required this.memorial});

  @override
  State<EditMemorialPage> createState() => _EditMemorialPageState();
}

class _EditMemorialPageState extends State<EditMemorialPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _epitaphController;
  
  DateTime? _birthDate;
  DateTime? _deathDate;
  late String _category;
  Uint8List? _newProfileImageBytes;
  
  final ImagePicker _picker = ImagePicker();

  // We don't support editing existing gallery images in this MVP efficiently 
  // without downloading them first, so we'll just allow adding NEW gallery images for now,
  // or simple removal if we had the logic. 
  // For "100% complete", let's strictly allow adding new ones.
  List<Uint8List> _newGalleryImageBytesList = [];
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.memorial.name);
    _bioController = TextEditingController(text: widget.memorial.bio);
    _epitaphController = TextEditingController(text: widget.memorial.epitaph);
    _birthDate = widget.memorial.birthDate;
    _deathDate = widget.memorial.deathDate;
    _category = widget.memorial.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _epitaphController.dispose();
    super.dispose();
  }

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
          _newProfileImageBytes = bytes;
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
          _newGalleryImageBytesList.addAll(newImages);
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

  void _removeNewGalleryImage(int index) {
    setState(() {
      _newGalleryImageBytesList.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null || _deathDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both birth and death dates')),
      );
      return;
    }

    final updatedMemorial = widget.memorial.copyWith(
      name: _nameController.text.trim(),
      birthDate: _birthDate!,
      deathDate: _deathDate!,
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      epitaph: _epitaphController.text.trim().isEmpty ? null : _epitaphController.text.trim(),
      category: _category,
    );

    final provider = context.read<MemorialProvider>();
    
    // We reuse createMemorial logic partially or call update specifically?
    // Provider doesn't have a high-level `updateMemorialWithImages` method yet.
    // We should probably add one or handle it here manually using repository?
    // Better to add `updateMemorial` to provider.
    
    // For now, I'll use the repository directly via provider? No, keep architecture clean.
    // I need to add `updateMemorial` to `MemorialProvider`.
    
    final success = await provider.updateMemorial(
      updatedMemorial, 
      newProfileImageBytes: _newProfileImageBytes,
      newGalleryImageBytesList: _newGalleryImageBytesList
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Memorial updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? 'Failed to update memorial')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<MemorialProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('Edit Memorial', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
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
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
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
                              image: _newProfileImageBytes != null
                                  ? DecorationImage(image: MemoryImage(_newProfileImageBytes!), fit: BoxFit.cover)
                                  : (widget.memorial.profileImageUrl != null
                                      ? DecorationImage(image: NetworkImage(widget.memorial.profileImageUrl!), fit: BoxFit.cover)
                                      : null),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: (_newProfileImageBytes == null && widget.memorial.profileImageUrl == null)
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_rounded, size: 32, color: AppColors.primary.withValues(alpha: 0.5)),
                                      const SizedBox(height: 4),
                                      Text('Change Photo', style: TextStyle(fontSize: 10, color: AppColors.primary.withValues(alpha: 0.5))),
                                    ],
                                  )
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text('Tap to change', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  _buildTextField(controller: _nameController, label: 'Full Name *', icon: Icons.person_outline_rounded,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null, onChanged: (_) => setState(() {})),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(child: _DatePickerField(label: 'Born *', selectedDate: _birthDate, icon: Icons.cake_outlined,
                          onTap: () async {
                            final date = await showDatePicker(context: context, initialDate: _birthDate ?? DateTime(1980), firstDate: DateTime(1800), lastDate: DateTime.now());
                            if (date != null) setState(() => _birthDate = date);
                          })),
                      const SizedBox(width: 12),
                      Expanded(child: _DatePickerField(label: 'Passed *', selectedDate: _deathDate, icon: Icons.event_outlined,
                          onTap: () async {
                            final date = await showDatePicker(context: context, initialDate: _deathDate ?? DateTime.now(), firstDate: DateTime(1800), lastDate: DateTime.now());
                            if (date != null) setState(() => _deathDate = date);
                          })),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                   DropdownButtonFormField<String>(
                    value: _category,
                    items: const [
                       DropdownMenuItem(value: 'family', child: Text('Family')),
                       DropdownMenuItem(value: 'friends', child: Text('Friend')),
                       DropdownMenuItem(value: 'colleagues', child: Text('Colleague')),
                       DropdownMenuItem(value: 'famous', child: Text('Public Figure')),
                       DropdownMenuItem(value: 'pets', child: Text('Pet')),
                    ],
                    onChanged: (v) => setState(() => _category = v!),
                    decoration: InputDecoration(
                      labelText: 'Relationship',
                      filled: true,
                      fillColor: AppColors.surfaceLight,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildTextField(controller: _epitaphController, label: 'Epitaph / Quote', icon: Icons.format_quote_rounded, maxLines: 2),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _bioController, label: 'Biography', icon: Icons.article_outlined, maxLines: 5, alignLabelWithHint: true),
                  const SizedBox(height: 24),

                  Text('Add More Photos', style: AppTextStyles.dividerLabel),
                  const SizedBox(height: 12),
                   GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                    itemCount: _newGalleryImageBytesList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _newGalleryImageBytesList.length) {
                        return InkWell(
                          onTap: _pickGalleryImages,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
                            child: const Center(child: Icon(Icons.add_photo_alternate_outlined, color: AppColors.textMuted)),
                          ),
                        );
                      }
                      return Stack(
                        children: [
                          ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(_newGalleryImageBytesList[index], fit: BoxFit.cover, width: double.infinity, height: double.infinity)),
                          Positioned(top: 4, right: 4, child: GestureDetector(onTap: () => _removeNewGalleryImage(index), child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)))),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (isLoading || !_isFormValid) ? null : _submit,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widgets (condensed)
  Widget _buildTextField({required TextEditingController controller, required String label, IconData? icon, int maxLines=1, bool alignLabelWithHint=false, String? Function(String?)? validator, void Function(String)? onChanged}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20, color: AppColors.textMuted) : null,
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.borderLight)),
        alignLabelWithHint: alignLabelWithHint,
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final IconData? icon;
  final VoidCallback onTap;
  const _DatePickerField({required this.label, required this.selectedDate, required this.onTap, this.icon});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
        child: Row(
          children: [
             if (icon != null) ...[Icon(icon, size: 18, color: AppColors.textMuted), const SizedBox(width: 8)],
             Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
               Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
               Text(selectedDate != null ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}' : 'Select', style: const TextStyle(fontSize: 14)),
             ])),
          ],
        ),
      ),
    );
  }
}
