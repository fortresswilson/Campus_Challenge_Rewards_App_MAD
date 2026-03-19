// lib/screens/create_challenge_screen.dart
// UI by Person 1 — Person 2 wires up SQLite save logic

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  int _durationDays = 7;
  int _pointsReward = 100;
  String _selectedCategory = 'Fitness';
  String _selectedDifficulty = 'Medium';
  bool _isLoading = false;

  final List<String> _categories = [
    'Fitness', 'Academic', 'Mindfulness', 'Health', 'Social', 'Creative'
  ];
  final Map<String, String> _categoryEmojis = {
    'Fitness': '💪', 'Academic': '📚', 'Mindfulness': '🧘',
    'Health': '❤️', 'Social': '🤝', 'Creative': '🎨',
  };
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // TODO Person 2: Replace with SQLite INSERT
  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Challenge created! 🎉',
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    _titleController.clear();
    _descController.clear();
    setState(() {
      _durationDays = 7;
      _pointsReward = 100;
      _selectedCategory = 'Fitness';
      _selectedDifficulty = 'Medium';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildSection('Challenge Info', [
                        _buildTextField(
                          controller: _titleController,
                          label: 'Challenge Name',
                          hint: 'e.g. 30-Day Plank',
                          icon: Icons.title_rounded,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Title is required'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _descController,
                          label: 'Description',
                          hint: 'Describe what participants need to do...',
                          icon: Icons.notes_rounded,
                          maxLines: 3,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Description is required'
                              : null,
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildSection('Category', [
                        _buildCategoryPicker(),
                      ]),
                      const SizedBox(height: 20),
                      _buildSection('Difficulty', [
                        _buildDifficultyPicker(),
                      ]),
                      const SizedBox(height: 20),
                      _buildSection('Duration', [
                        _buildDurationSlider(),
                      ]),
                      const SizedBox(height: 20),
                      _buildSection('Points Reward', [
                        _buildPointsSlider(),
                      ]),
                      const SizedBox(height: 28),
                      _buildPreviewCard(),
                      const SizedBox(height: 20),
                      _buildCreateButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create', style: AppTextStyles.heading2),
          Text(
            'Design a new challenge for the community',
            style: AppTextStyles.body.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.heading3.copyWith(fontSize: 15)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2E2C4A)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'Nunito',
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  Widget _buildCategoryPicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _categories.map((cat) {
        final isSelected = cat == _selectedCategory;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.primaryGradient : null,
              color: isSelected ? null : AppColors.bgDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : const Color(0xFF2E2C4A),
              ),
            ),
            child: Text(
              '${_categoryEmojis[cat]} $cat',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDifficultyPicker() {
    final colors = {
      'Easy': AppColors.secondary,
      'Medium': const Color(0xFFFFBB33),
      'Hard': AppColors.accent,
    };
    return Row(
      children: _difficulties.map((d) {
        final isSelected = d == _selectedDifficulty;
        final color = colors[d]!;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDifficulty = d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                  right: d != _difficulties.last ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.2)
                    : AppColors.bgDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : const Color(0xFF2E2C4A),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Text(
                d,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? color : AppColors.textMuted,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDurationSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Duration',
              style: AppTextStyles.body.copyWith(fontSize: 13),
            ),
            Text(
              '$_durationDays day${_durationDays > 1 ? 's' : ''}',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.bgDark,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.2),
            trackHeight: 6,
          ),
          child: Slider(
            value: _durationDays.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            onChanged: (v) => setState(() => _durationDays = v.round()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1 day', style: AppTextStyles.label),
            Text('30 days', style: AppTextStyles.label),
          ],
        ),
      ],
    );
  }

  Widget _buildPointsSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Points Reward', style: AppTextStyles.body.copyWith(fontSize: 13)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.mintGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '⭐ $_pointsReward pts',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.secondary,
            inactiveTrackColor: AppColors.bgDark,
            thumbColor: AppColors.secondary,
            overlayColor: AppColors.secondary.withOpacity(0.2),
            trackHeight: 6,
          ),
          child: Slider(
            value: _pointsReward.toDouble(),
            min: 50,
            max: 500,
            divisions: 9,
            onChanged: (v) => setState(() => _pointsReward = v.round()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('50 pts', style: AppTextStyles.label),
            Text('500 pts', style: AppTextStyles.label),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '👀 Preview',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _titleController.text.isEmpty
                ? 'Your challenge title'
                : _titleController.text,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _descController.text.isEmpty
                ? 'Your description will appear here...'
                : _descController.text,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: Colors.white70,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _previewChip('${_categoryEmojis[_selectedCategory]} $_selectedCategory'),
              const SizedBox(width: 8),
              _previewChip('⏱️ $_durationDays days'),
              const SizedBox(width: 8),
              _previewChip('⭐ $_pointsReward pts'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _previewChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleCreate,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: _isLoading ? null : AppColors.primaryGradient,
            color: _isLoading ? AppColors.textMuted : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline_rounded,
                          color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Create Challenge',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}