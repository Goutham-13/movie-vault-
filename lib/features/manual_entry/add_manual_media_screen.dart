import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/media_item.dart';
import '../../providers/app_providers.dart';

class AddManualMediaScreen extends ConsumerStatefulWidget {
  const AddManualMediaScreen({super.key});

  @override
  ConsumerState<AddManualMediaScreen> createState() => _AddManualMediaScreenState();
}

class _AddManualMediaScreenState extends ConsumerState<AddManualMediaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _originalTitleController = TextEditingController();
  final _yearController = TextEditingController();
  final _languageController = TextEditingController(text: 'EN');
  final _genreController = TextEditingController();
  final _runtimeController = TextEditingController();
  final _overviewController = TextEditingController();
  final _posterUrlController = TextEditingController();

  String _mediaType = 'movie';
  String _initialStatus = 'wishlist';

  @override
  void dispose() {
    _titleController.dispose();
    _originalTitleController.dispose();
    _yearController.dispose();
    _languageController.dispose();
    _genreController.dispose();
    _runtimeController.dispose();
    _overviewController.dispose();
    _posterUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Manual Media'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Custom Cinema Entry",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                "Create custom movies or shows offline when not listed on TMDB.",
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Media Type Toggle
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Movie')),
                      selected: _mediaType == 'movie',
                      selectedColor: AppColors.primaryAccent,
                      onSelected: (val) {
                        if (val) setState(() => _mediaType = 'movie');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('TV Show')),
                      selected: _mediaType == 'tv',
                      selectedColor: AppColors.primaryAccent,
                      onSelected: (val) {
                        if (val) setState(() => _mediaType = 'tv');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title Input
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: AppColors.textPrimary),
                validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  prefixIcon: Icon(Icons.movie_rounded),
                ),
              ),
              const SizedBox(height: 16),

              // Original Title
              TextFormField(
                controller: _originalTitleController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Original Title (Optional)',
                  prefixIcon: Icon(Icons.subtitles_rounded),
                ),
              ),
              const SizedBox(height: 16),

              // Year & Runtime
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        prefixIcon: Icon(Icons.calendar_today_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _runtimeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Runtime (mins)',
                        prefixIcon: Icon(Icons.timer_rounded),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Genre & Poster URL
              TextFormField(
                controller: _genreController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Genres (e.g. Action, Drama)',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _posterUrlController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Poster Image URL (Optional)',
                  prefixIcon: Icon(Icons.image_rounded),
                ),
              ),
              const SizedBox(height: 16),

              // Overview
              TextFormField(
                controller: _overviewController,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Description / Overview',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // Initial Collection Status Dropdown
              DropdownButtonFormField<String>(
                value: _initialStatus,
                decoration: const InputDecoration(labelText: 'Initial Collection Status'),
                items: const [
                  DropdownMenuItem(value: 'wishlist', child: Text('Wishlist')),
                  DropdownMenuItem(value: 'watching', child: Text('Watching')),
                  DropdownMenuItem(value: 'watched', child: Text('Watched')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _initialStatus = val);
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveManualItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                  ),
                  child: const Text('Save Manual Media', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveManualItem() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final year = int.tryParse(_yearController.text.trim());
    final runtime = int.tryParse(_runtimeController.text.trim());
    final genres = _genreController.text
        .split(',')
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toList();

    final manualId = 'manual_${DateTime.now().millisecondsSinceEpoch}';

    final media = MediaItem(
      localId: manualId,
      mediaType: _mediaType,
      title: title,
      originalTitle: _originalTitleController.text.trim(),
      overview: _overviewController.text.trim(),
      posterPath: _posterUrlController.text.trim(),
      year: year,
      originalLanguage: _languageController.text.trim(),
      genres: genres,
      runtime: runtime,
      source: 'manual',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(collectionProvider.notifier).saveManualMedia(media, _initialStatus);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added "$title" to $_initialStatus')),
    );
  }
}
