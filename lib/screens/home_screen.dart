// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../database/challenge_service.dart';
import '../database/login_service.dart';
import 'challenge_list_screen.dart';
import 'create_challenge_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _previousIndex = 0;
  final _homeDashboardKey = GlobalKey<_HomeDashboardState>();
  final _profileKey = GlobalKey<ProfileScreenState>();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     final screens = [
      _HomeDashboard(key: _homeDashboardKey),
      const ChallengeListScreen(),
      const CreateChallengeScreen(),
      ProfileScreen(key: _profileKey),
    ];

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: IndexedStack(index: _selectedIndex, children: screens),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: const Border(top: BorderSide(color: Color(0xFF2E2C4A), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20, offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
              _navItem(1, Icons.flag_rounded, Icons.flag_outlined, 'Challenges'),
              _navItem(2, Icons.add_circle_rounded,
                  Icons.add_circle_outline_rounded, 'Create'),
              _navItem(3, Icons.person_rounded,
                  Icons.person_outline_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _selectedIndex == index;
     final isCreate = index == 2;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _previousIndex = _selectedIndex;
            _selectedIndex = index;
          });
          // Reload home when switching back to it
          if (index == 0 && _previousIndex != 0) {
            _homeDashboardKey.currentState?._loadData();
          }
          // Reload profile when switching to it
          // Small delay ensures any pending DB writes finish first
          if (index == 3 && _previousIndex != 3) {
            Future.delayed(const Duration(milliseconds: 300), () {
              _profileKey.currentState?.loadData();
            });
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: isCreate ? const EdgeInsets.all(2) : const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: isActive && isCreate ? AppColors.primaryGradient : null,
                color: isActive && !isCreate
                    ? AppColors.primary.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                color: isActive
                    ? (isCreate ? Colors.white : AppColors.primary)
                    : AppColors.textMuted,
                size: isCreate ? 28 : 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                  fontFamily: 'Nunito', fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.primary : AppColors.textMuted,
                )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Home Dashboard — fully wired to real DB
// ─────────────────────────────────────────────
class _HomeDashboard extends StatefulWidget {
  const _HomeDashboard({super.key});
  @override
  State<_HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<_HomeDashboard> {
  bool _isLoading = true;
  String _userName = '';
  int _points = 0;
  int _streak = 0;
  int _joinedCount = 0;
  int _completedCount = 0;
  int _badgeCount = 0;
  int _rank = 0;
  List<Map<String, dynamic>> _activeChallenges = [];

  int get _currentUserId =>
      LoginService.instance.getCurrentUser()?['id'] as int? ?? 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = LoginService.instance.getCurrentUser();
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final points = await ChallengeService.instance.getUserPoints(_currentUserId);
    final badges = await ChallengeService.instance.getUserBadges(_currentUserId);
    final joined = await ChallengeService.instance.getJoinedChallenges(_currentUserId);
    final leaderboard = await ChallengeService.instance.getLeaderboard();

    final completed = joined.where((c) => c['completed'] == 1).length;
    final active = joined.where((c) => c['completed'] == 0).toList();

    // Dynamic rank
    final rank = leaderboard.indexWhere((u) => u['id'] == _currentUserId);

    if (mounted) {
      setState(() {
        _userName = user['name'] as String? ?? '';
        _points = points;
        _streak = user['streak'] as int? ?? 0;
        _joinedCount = joined.length;
        _completedCount = completed;
        _badgeCount = badges.length;
        _rank = rank == -1 ? leaderboard.length + 1 : rank + 1;
        _activeChallenges = active;
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
          onRefresh: _loadData,
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
                    _buildHeroCard(),
                    const SizedBox(height: 24),
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Active Challenges'),
                    const SizedBox(height: 12),
                    _buildActiveChallengesList(),
                    const SizedBox(height: 24),
                    _buildAICoachCard(),
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
      floating: true,
   titleSpacing: 20,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('🏆', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          const Text('CampusQuest',
              style: TextStyle(
                fontFamily: 'Nunito', fontSize: 20, fontWeight: FontWeight.w900,
                color: AppColors.textPrimary, letterSpacing: -0.5,
              )),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2E2C4A)),
                ),
                child: const Icon(Icons.notifications_outlined,
                    color: AppColors.textSecondary, size: 20),
              ),
              Positioned(
                top: -2, right: -2,
                child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.bgDark, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    final firstName = _userName.split(' ').first;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, $firstName! 👋',
                      style: const TextStyle(
                        fontFamily: 'Nunito', fontSize: 13,
                        fontWeight: FontWeight.w600, color: Colors.white70,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    _streak > 0 ? "You're on fire!" : "Let's get started!",
                    style: const TextStyle(
                      fontFamily: 'Nunito', fontSize: 22,
                      fontWeight: FontWeight.w900, color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text('$_streak day streak',
                        style: const TextStyle(
                          fontFamily: 'Nunito', fontSize: 13,
                          fontWeight: FontWeight.w700, color: Colors.white,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _heroStat('$_points', 'Total Points', '⭐'),
              const SizedBox(width: 12),
              _heroStat('$_joinedCount', 'Joined', '🎯'),
              const SizedBox(width: 12),
              _heroStat('$_completedCount', 'Done', '✅'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String value, String label, String emoji) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                  fontFamily: 'Nunito', fontSize: 18,
                  fontWeight: FontWeight.w900, color: Colors.white,
                )),
            Text(label,
                style: const TextStyle(
                  fontFamily: 'Nunito', fontSize: 10,
                  fontWeight: FontWeight.w600, color: Colors.white70,
                )),
          ],
        ),
      ),
    );
  }

Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard('${_activeChallenges.length}', 'Active', '🏃', AppColors.secondary),
        const SizedBox(width: 12),
        _statCard('$_badgeCount', 'Badges', '🏅', AppColors.accent),
        const SizedBox(width: 12),
        _statCard('#$_rank', 'Rank', '🏆', const Color(0xFFFFD700)),
      ],
    );
  }

  Widget _statCard(String value, String label, String emoji, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                  fontFamily: 'Nunito', fontSize: 20,
                  fontWeight: FontWeight.w900, color: color,
                )),
            Text(label, style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.heading3);
  }

  Widget _buildActiveChallengesList() {
    if (_activeChallenges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: Text(
            'No active challenges yet!\nJoin one to get started 🎯',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Nunito', color: AppColors.textMuted, fontSize: 14),
          ),
        ),
      );
    }
    return Column(
      children: _activeChallenges.map((c) => _activeChallengeCard(c)).toList(),
    );
  }

  Widget _activeChallengeCard(Map<String, dynamic> challenge) {
    final progress = (challenge['progress'] as num).toDouble();
    final progressPercent = (progress * 100).round();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2E2C4A), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(challenge['emoji'],
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge['title'],
                    style: const TextStyle(
                      fontFamily: 'Nunito', fontSize: 14,
                      fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                    )),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.bgDark,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.secondary),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text('$progressPercent% complete',
                    style: AppTextStyles.label.copyWith(fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('+${challenge['points_reward']}pts',
              style: const TextStyle(
                fontFamily: 'Nunito', fontSize: 12,
                fontWeight: FontWeight.w700, color: AppColors.secondary,
              )),
        ],
      ),
    );
    }
Widget _buildAICoachCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2940), Color(0xFF0F2030)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: AppColors.secondary.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.mintGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Coach Suggestion',
                    style: TextStyle(
                      fontFamily: 'Nunito', fontSize: 12,
                      fontWeight: FontWeight.w700, color: AppColors.secondary,
                      letterSpacing: 0.5,
                    )),
                SizedBox(height: 4),
                Text(
                  '"Try the Morning Run challenge — it matches your streak!"',
                  style: TextStyle(
                    fontFamily: 'Nunito', fontSize: 13,
                    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: AppColors.secondary, size: 14),
        ],
      ),
    );
  }
}
