// lib/screens/challenge_detail_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../database/challenge_service.dart';
import '../database/login_service.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> challenge;

  const ChallengeDetailScreen({super.key, required this.challenge});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  late Map<String, dynamic> _challenge;
  bool _isJoined = false;
  double _progress = 0.0;
  bool _isLoading = false;

  int get _currentUserId =>
      LoginService.instance.getCurrentUser()?['id'] as int? ?? 0;

  int get _challengeId => _challenge['id'] as int;

  @override
  void initState() {
    super.initState();
    _challenge = widget.challenge;
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final joined = await ChallengeService.instance.isJoined(
      userId: _currentUserId,
      challengeId: _challengeId,
    );

    if (joined) {
      final list = await ChallengeService.instance
          .getJoinedChallenges(_currentUserId);
      final match = list.where((c) => c['id'] == _challengeId).toList();
      if (match.isNotEmpty) {
        if (mounted) {
          setState(() {
            _isJoined = true;
            _progress = (match.first['progress'] as num).toDouble();
          });
        }
        return;
      }
    }

    if (mounted) setState(() => _isJoined = false);
  }

  Future<void> _handleJoin() async {
    setState(() => _isLoading = true);

    if (_isJoined) {
      await ChallengeService.instance.leaveChallenge(
        userId: _currentUserId,
        challengeId: _challengeId,
      );
    } else {
      await ChallengeService.instance.joinChallenge(
        userId: _currentUserId,
        challengeId: _challengeId,
      );
    }

    await _loadStatus();
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isJoined
              ? 'Joined "${_challenge['title']}"! Good luck 🎉'
              : 'Left "${_challenge['title']}"',
          style: const TextStyle(fontFamily: 'Nunito'),
        ),
        backgroundColor: _isJoined ? AppColors.primary : AppColors.bgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _logActivity() async {
    setState(() => _isLoading = true);

    await ChallengeService.instance.logActivity(
      userId: _currentUserId,
      challengeId: _challengeId,
    );

    await _loadStatus();
    if (!mounted) return;
    setState(() => _isLoading = false);

    final isComplete = _progress >= 1.0;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isComplete
              ? '🎉 Challenge complete! Points awarded!'
              : 'Activity logged! Keep it up 💪',
          style: const TextStyle(fontFamily: 'Nunito'),
        ),
        backgroundColor:
            isComplete ? AppColors.secondary : AppColors.bgCard,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Color get _difficultyColor {
    switch (_challenge['difficulty']) {
      case 'Easy': return AppColors.secondary;
      case 'Medium': return const Color(0xFFFFBB33);
      case 'Hard': return AppColors.accent;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressPercent = (_progress * 100).round();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
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
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary, size: 18),
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
                    _buildHero(),
                    const SizedBox(height: 24),
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    if (_isJoined) ...[
                      _buildProgressSection(progressPercent),
                      const SizedBox(height: 24),
                    ],
                    _buildDescriptionCard(),
                    const SizedBox(height: 24),
                    _buildRulesCard(),
                    const SizedBox(height: 32),
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
            blurRadius: 24, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(_challenge['emoji'],
                      style: const TextStyle(fontSize: 32)),
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
                          child: Text(_challenge['category'],
                              style: const TextStyle(
                                fontFamily: 'Nunito', fontSize: 11,
                                fontWeight: FontWeight.w700, color: Colors.white,
                              )),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _difficultyColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_challenge['difficulty'],
                              style: TextStyle(
                                fontFamily: 'Nunito', fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _difficultyColor,
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_challenge['title'],
                        style: const TextStyle(
                          fontFamily: 'Nunito', fontSize: 22,
                          fontWeight: FontWeight.w900, color: Colors.white,
                          letterSpacing: -0.5, height: 1.1,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isJoined)
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
                  Text("You're participating in this challenge!",
                      style: TextStyle(
                        fontFamily: 'Nunito', fontSize: 12,
                        fontWeight: FontWeight.w700, color: AppColors.secondary,
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final durationDays = _challenge['duration_days'] as int;
    final pointsReward = _challenge['points_reward'] as int;
    return Row(
      children: [
        _statTile('⭐', '$pointsReward', 'Points'),
        const SizedBox(width: 10),
        _statTile('⏱️', '$durationDays days', 'Duration'),
        const SizedBox(width: 10),
        _statTile('📊', _challenge['difficulty'], 'Level'),
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
            Text(value,
                style: const TextStyle(
                  fontFamily: 'Nunito', fontSize: 14,
                  fontWeight: FontWeight.w900, color: AppColors.textPrimary,
                )),
            Text(label, style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(int progressPercent) {
    final pointsReward = _challenge['points_reward'] as int;
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
              Text('Your Progress',
                  style: AppTextStyles.heading3.copyWith(fontSize: 16)),
              Text('$progressPercent%',
                  style: const TextStyle(
                    fontFamily: 'Nunito', fontSize: 22,
                    fontWeight: FontWeight.w900, color: AppColors.secondary,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: AppColors.bgDark,
              valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            progressPercent < 100
                ? '${100 - progressPercent}% more to earn your $pointsReward points!'
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
          Text(_challenge['description'],
              style: AppTextStyles.body.copyWith(height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildRulesCard() {
    final durationDays = _challenge['duration_days'] as int;
    final pointsReward = _challenge['points_reward'] as int;
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
          Text('How it works',
              style: AppTextStyles.heading3.copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          _ruleItem('1', 'Join the challenge and commit to the goal'),
          _ruleItem('2', 'Log your activity each day using the button below'),
          _ruleItem('3',
              'Complete $durationDays days to earn $pointsReward points'),
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
            width: 24, height: 24,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child: Text(number,
                  style: const TextStyle(
                    fontFamily: 'Nunito', fontSize: 12,
                    fontWeight: FontWeight.w800, color: Colors.white,
                  )),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: AppTextStyles.body.copyWith(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final pointsReward = _challenge['points_reward'] as int;
    return Column(
      children: [
        if (_isJoined && _progress < 1.0) ...[
          SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _logActivity,
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
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_rounded,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('Log Activity',
                                style: TextStyle(
                                  fontFamily: 'Nunito', fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                )),
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
            onPressed: _isLoading ? null : _handleJoin,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: _isJoined ? null : AppColors.primaryGradient,
                color: _isJoined ? AppColors.bgCard : null,
                borderRadius: BorderRadius.circular(16),
                border: _isJoined
                    ? Border.all(
                        color: const Color(0xFF2E2C4A), width: 1.5)
                    : null,
              ),
              child: Container(
                alignment: Alignment.center,
                child: _isLoading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : Text(
                        _isJoined
                            ? 'Leave Challenge'
                            : '⭐ Join for $pointsReward Points',
                        style: TextStyle(
                          fontFamily: 'Nunito', fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _isJoined
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
