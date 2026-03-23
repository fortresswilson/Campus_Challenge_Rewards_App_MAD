// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../database/challenge_service.dart';
import '../database/login_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String _userName = '';
  String _userEmail = '';
  int _points = 0;
  int _streak = 0;
  int _joined = 0;
  int _completed = 0;
  List<Map<String, dynamic>> _badges = [];
  List<Map<String, dynamic>> _activeChallenges = [];
  List<Map<String, dynamic>> _leaderboard = [];

  int get _currentUserId =>
      LoginService.instance.getCurrentUser()?['id'] as int? ?? 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // Reload every time this tab becomes visible
  Future<void> loadData() async {
    final user = LoginService.instance.getCurrentUser();
    if (user == null) return;

    final points =
        await ChallengeService.instance.getUserPoints(_currentUserId);
    final badges =
        await ChallengeService.instance.getUserBadges(_currentUserId);
    final joined =
        await ChallengeService.instance.getJoinedChallenges(_currentUserId);
    final leaderboard = await ChallengeService.instance.getLeaderboard();

    final completedCount = joined.where((c) => c['completed'] == 1).length;
    final active = joined.where((c) => c['completed'] == 0).toList();

    if (mounted) {
      setState(() {
        _userName = user['name'] as String? ?? '';
        _userEmail = user['email'] as String? ?? '';
        _points = points;
        _streak = user['streak'] as int? ?? 0;
        _joined = joined.length;
        _completed = completedCount;
        _badges = badges;
        _activeChallenges = active;
        _leaderboard = leaderboard;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadData,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    _buildProfileHero(),
                    const SizedBox(height: 24),
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    _buildBadgesSection(),
                    const SizedBox(height: 24),
                    _buildActiveChallenges(),
                    const SizedBox(height: 24),
                    _buildLeaderboardCard(),
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

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      titleSpacing: 20,
      title: Text('Profile', style: AppTextStyles.heading2),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2E2C4A)),
            ),
            child: const Icon(Icons.settings_outlined,
                color: AppColors.textSecondary, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHero() {
    final firstName =
        _userName.isNotEmpty ? _userName.split(' ').first : '?';
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
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Center(
                  child: Text(
                    firstName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Icon(Icons.verified_rounded,
                      color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userEmail,
            style: const TextStyle(
                fontFamily: 'Nunito', fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  '$_points Points',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  '$_streak-day streak!',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF9B9B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Stats', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        Row(
          children: [
            _statCard('🎯', '$_joined', 'Joined', AppColors.primary),
            const SizedBox(width: 12),
            _statCard('✅', '$_completed', 'Completed', AppColors.secondary),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _statCard('🏅', '${_badges.length}', 'Badges', AppColors.accent),
            const SizedBox(width: 12),
            _statCard(
                '🔥', '$_streak', 'Day Streak', const Color(0xFFFFBB33)),
          ],
        ),
      ],
    );
  }

  Widget _statCard(
      String emoji, String value, String label, Color accentColor) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                  child:
                      Text(emoji, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                    )),
                Text(label, style: AppTextStyles.label),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Badges', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2E2C4A)),
          ),
          child: _badges.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Complete challenges to earn badges! 🏅',
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ..._badges.map(
                        (b) => _badgePill(b['badge_name'] as String)),
                    _badgePill('???', isLocked: true),
                    _badgePill('???', isLocked: true),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _badgePill(String label, {bool isLocked = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: isLocked ? null : AppColors.primaryGradient,
        color: isLocked ? AppColors.bgDark : null,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isLocked
              ? const Color(0xFF2E2C4A)
              : AppColors.primary.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isLocked) ...[
            const Text('🏅', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
          ] else ...[
            const Icon(Icons.lock_outline_rounded,
                color: AppColors.textMuted, size: 13),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isLocked ? AppColors.textMuted : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveChallenges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Active Challenges', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2E2C4A)),
          ),
          child: _activeChallenges.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No active challenges yet!\nJoin one to get started 🎯',
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Column(
                  children: _activeChallenges
                      .map((c) => _activityRow(c))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _activityRow(Map<String, dynamic> challenge) {
    final progress = (challenge['progress'] as num).toDouble();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Text(challenge['emoji'], style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge['title'],
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.bgDark,
                    valueColor: const AlwaysStoppedAnimation(
                        AppColors.secondary),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '+${challenge['points_reward']}',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Leaderboard', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2E2C4A)),
          ),
          child: _leaderboard.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child:
                        Text('No users yet!', style: AppTextStyles.body),
                  ),
                )
              : Column(
                  children: _leaderboard.asMap().entries.map((entry) {
                    final rank = entry.key + 1;
                    final player = entry.value;
                    final isCurrentUser =
                        player['id'] == _currentUserId;
                    return _leaderboardRow(rank, player, isCurrentUser);
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _leaderboardRow(
      int rank, Map<String, dynamic> player, bool isCurrentUser) {
    final medal = rank == 1
        ? '🥇'
        : rank == 2
            ? '🥈'
            : rank == 3
                ? '🥉'
                : '#$rank';
    final name = player['name'] as String? ?? 'Unknown';
    final points = player['points'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(
                color: AppColors.primary.withOpacity(0.4), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(medal,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center),
          ),
          const SizedBox(width: 10),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.bgCardLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isCurrentUser
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isCurrentUser ? '$name (You)' : name,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isCurrentUser
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '$points pts',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isCurrentUser
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
