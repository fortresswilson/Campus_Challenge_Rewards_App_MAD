// lib/screens/challenge_detail_screen.dart
// UI built by Person 1 — Person 2 hooks up join/log/progress logic

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/mock_data.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final MockChallenge challenge;

  const ChallengeDetailScreen({super.key, required this.challenge});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  late MockChallenge _challenge;

  @override
  void initState() {
    super.initState();
    _challenge = widget.challenge;
  }

  // TODO Person 2: Replace with real SQLite join logic
  void _handleJoin() {
    setState(() {
      // Stub: just shows a snackbar — Person 2 wires real logic here
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _challenge.isJoined
              ? 'Left challenge'
              : 'Successfully joined! 🎉 Good luck!',
          style: const TextStyle(fontFamily: 'Nunito'),
        ),
        backgroundColor: AppColors.bgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // TODO Person 2: Replace with real SQLite progress increment
  void _logActivity() {
    setState(() {
      // Stub: increment progress visually — Person 2 saves to SQLite
      final newProgress = (_challenge.progress + 0.2).clamp(0.0, 1.0);
      _challenge = MockChallenge(
        id: _challenge.id,
        title: _challenge.title,
        description: _challenge.description,
        category: _challenge.category,
        pointsReward: _challenge.pointsReward,
        duration: _challenge.duration,
        durationDays: _challenge.durationDays,
        difficulty: _challenge.difficulty,
        participantCount: _challenge.participantCount,
        progress: newProgress,
        isJoined: _challenge.isJoined,
        emoji: _challenge.emoji,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Activity logged! Keep it up 💪',
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        backgroundColor: AppColors.bgCard,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color get _difficultyColor {
    switch (_challenge.difficulty) {
      case 'Easy':
        return AppColors.secondary;
      case 'Medium':
        return const Color(0xFFFFBB33);
      case 'Hard':
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressPercent = (_challenge.progress * 100).round();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                leading: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2E2C4A)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 18,
                    ),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2E2C4A)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.share_outlined,
                          color: AppColors.textSecondary, size: 18),
                      onPressed: () {},
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Hero section
                    _buildHero(),
                    const SizedBox(height: 24),
                    // Stats row
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    // Progress (if joined)
                    if (_challenge.isJoined) ...[
                      _buildProgressSection(progressPercent),
                      const SizedBox(height: 24),
                    ],
                    // Description
                    _buildDescriptionCard(),
                    const SizedBox(height: 24),
                    // Rules card
                    _buildRulesCard(),
                    const SizedBox(height: 32),
                    // Action buttons
                    _buildActionButtons(),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    _challenge.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _challenge.category,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _difficultyColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _challenge.difficulty,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _difficultyColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _challenge.title,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_challenge.isJoined)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: AppColors.secondary, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'You\'re participating in this challenge!',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statTile('⭐', '${_challenge.pointsReward}', 'Points'),
        const SizedBox(width: 10),
        _statTile('⏱️', _challenge.duration, 'Duration'),
        const SizedBox(width: 10),
        _statTile('👥', '${_challenge.participantCount}', 'Joined'),
      ],
    );
  }

  Widget _statTile(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2E2C4A)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            Text(label, style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(int progressPercent) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.secondary.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Progress', style: AppTextStyles.heading3.copyWith(fontSize: 16)),
              Text(
                '$progressPercent%',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _challenge.progress,
              backgroundColor: AppColors.bgDark,
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.secondary),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            progressPercent < 100
                ? '${100 - progressPercent}% more to earn your ${_challenge.pointsReward} points!'
                : '🎉 Challenge complete! Points awarded!',
            style: AppTextStyles.body.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E2C4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About this challenge',
              style: AppTextStyles.heading3.copyWith(fontSize: 16)),
          const SizedBox(height: 10),
          Text(
            _challenge.description,
            style: AppTextStyles.body.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E2C4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How it works', style: AppTextStyles.heading3.copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          _ruleItem('1', 'Join the challenge and commit to the goal'),
          _ruleItem('2', 'Log your activity each day using the button below'),
          _ruleItem('3',
              'Complete ${_challenge.durationDays} days to earn ${_challenge.pointsReward} points'),
          _ruleItem('4', 'Points go to your profile and leaderboard rank'),
        ],
      ),
    );
  }

  Widget _ruleItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: AppTextStyles.body.copyWith(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_challenge.isJoined) ...[
          SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _logActivity,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AppColors.mintGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Log Activity',
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
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleJoin,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: _challenge.isJoined ? null : AppColors.primaryGradient,
                color: _challenge.isJoined ? AppColors.bgCard : null,
                borderRadius: BorderRadius.circular(16),
                border: _challenge.isJoined
                    ? Border.all(color: const Color(0xFF2E2C4A), width: 1.5)
                    : null,
              ),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  _challenge.isJoined
                      ? 'Leave Challenge'
                      : '⭐ Join for ${_challenge.pointsReward} Points',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _challenge.isJoined
                        ? AppColors.textMuted
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}