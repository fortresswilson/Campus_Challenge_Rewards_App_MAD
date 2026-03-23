// lib/screens/challenge_list_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../database/challenge_service.dart';
import '../database/login_service.dart';
import 'challenge_detail_screen.dart';

class ChallengeListScreen extends StatefulWidget {
  const ChallengeListScreen({super.key});

  @override
  State<ChallengeListScreen> createState() => _ChallengeListScreenState();
}

class _ChallengeListScreenState extends State<ChallengeListScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  // Real data from DB
  List<Map<String, dynamic>> _allChallenges = [];
  Set<int> _joinedIds = {};
  Map<int, double> _progressMap = {};
  bool _isLoading = true;

  final List<String> _categories = [
    'All', 'Fitness', 'Academic', 'Mindfulness', 'Health',
  ];

  final Map<String, String> _categoryEmojis = {
    'All': '🌟', 'Fitness': '💪', 'Academic': '📚',
    'Mindfulness': '🧘', 'Health': '❤️',
  };

  int get _currentUserId =>
      LoginService.instance.getCurrentUser()?['id'] as int? ?? 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedCategory = _categories[_tabController.index]);
      }
    });
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final challenges = await ChallengeService.instance.getAllChallenges();
    final joined = await ChallengeService.instance.getJoinedChallenges(_currentUserId);

    final joinedIds = <int>{};
    final progressMap = <int, double>{};
    for (final j in joined) {
      final id = j['id'] as int;
      joinedIds.add(id);
      progressMap[id] = (j['progress'] as num).toDouble();
    }

    if (mounted) {
      setState(() {
        _allChallenges = challenges;
        _joinedIds = joinedIds;
        _progressMap = progressMap;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredChallenges {
    return _allChallenges.where((c) {
      final matchesCategory =
          _selectedCategory == 'All' || c['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          (c['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (c['description'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> _handleJoinLeave(Map<String, dynamic> challenge) async {
    final challengeId = challenge['id'] as int;
    final isJoined = _joinedIds.contains(challengeId);

    if (isJoined) {
      await ChallengeService.instance.leaveChallenge(
        userId: _currentUserId,
        challengeId: challengeId,
      );
    } else {
      await ChallengeService.instance.joinChallenge(
        userId: _currentUserId,
        challengeId: challengeId,
      );
    }

    // Reload data so UI reflects the change
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isJoined
                ? 'Left "${challenge['title']}"'
                : 'Joined "${challenge['title']}"! 🎉',
            style: const TextStyle(fontFamily: 'Nunito'),
          ),
          backgroundColor: isJoined ? AppColors.bgCard : AppColors.primary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryTabs(),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary))
                  : _buildChallengeList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Challenges', style: AppTextStyles.heading2),
              Text(
                '${_allChallenges.length} available',
                style: AppTextStyles.body.copyWith(fontSize: 13),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2E2C4A)),
            ),
            child: const Row(
              children: [
                Icon(Icons.sort_rounded, color: AppColors.primary, size: 16),
                SizedBox(width: 4),
                Text('Filter',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(
            fontFamily: 'Nunito', color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search challenges...',
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textMuted, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: AppColors.textMuted, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (ctx, i) {
          final cat = _categories[i];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = cat);
              _tabController.animateTo(i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected ? null : AppColors.bgCard,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFF2E2C4A),
                  width: 1.5,
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
        },
      ),
    );
  }

  Widget _buildChallengeList() {
    final challenges = _filteredChallenges;

    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😔', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('No challenges found',
                style: AppTextStyles.heading3.copyWith(fontSize: 16)),
            const SizedBox(height: 6),
            Text('Try a different category or search',
                style: AppTextStyles.body),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: challenges.length,
        itemBuilder: (ctx, i) {
          final challenge = challenges[i];
          final challengeId = challenge['id'] as int;
          final isJoined = _joinedIds.contains(challengeId);
          final progress = _progressMap[challengeId] ?? 0.0;

          return _ChallengeCard(
            challenge: challenge,
            isJoined: isJoined,
            progress: progress,
            onTap: () async {
              await Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, a1, a2) =>
                      ChallengeDetailScreen(challenge: challenge),
                  transitionsBuilder: (_, anim, __, child) => SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(
                        CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                    child: child,
                  ),
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
              // Reload when coming back from detail screen
              _loadData();
            },
            onJoin: () => _handleJoinLeave(challenge),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Challenge Card Widget
// ─────────────────────────────────────────────
class _ChallengeCard extends StatelessWidget {
  final Map<String, dynamic> challenge;
  final bool isJoined;
  final double progress;
  final VoidCallback onTap;
  final VoidCallback onJoin;

  const _ChallengeCard({
    required this.challenge,
    required this.isJoined,
    required this.progress,
    required this.onTap,
    required this.onJoin,
  });

  Color get _difficultyColor {
    switch (challenge['difficulty']) {
      case 'Easy': return AppColors.secondary;
      case 'Medium': return const Color(0xFFFFBB33);
      case 'Hard': return AppColors.accent;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isJoined
                ? AppColors.primary.withOpacity(0.5)
                : const Color(0xFF2E2C4A),
            width: 1.5,
          ),
          boxShadow: isJoined
              ? [BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 16, offset: const Offset(0, 4))]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(challenge['emoji'],
                        style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              challenge['title'],
                              style: AppTextStyles.heading3.copyWith(fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isJoined)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Joined',
                                  style: TextStyle(
                                    fontFamily: 'Nunito', fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  )),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _difficultyColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              challenge['difficulty'],
                              style: TextStyle(
                                fontFamily: 'Nunito', fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _difficultyColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(challenge['category'],
                              style: AppTextStyles.label.copyWith(fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              challenge['description'],
              style: AppTextStyles.body.copyWith(fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            if (isJoined) ...[
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.bgDark,
                        valueColor:
                            const AlwaysStoppedAnimation(AppColors.secondary),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      fontFamily: 'Nunito', fontSize: 12,
                      fontWeight: FontWeight.w700, color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
            Row(
              children: [
                _infoChip(Icons.timer_outlined,
                    '${challenge['duration_days']} days'),
                const Spacer(),
                _joinButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textMuted, size: 13),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.label.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _joinButton() {
    return GestureDetector(
      onTap: onJoin,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isJoined ? null : AppColors.primaryGradient,
          color: isJoined ? AppColors.bgDark : null,
          borderRadius: BorderRadius.circular(10),
          border: isJoined
              ? Border.all(color: const Color(0xFF2E2C4A))
              : null,
        ),
        child: Text(
          isJoined ? 'Leave' : '⭐ ${challenge['points_reward']} pts →',
          style: TextStyle(
            fontFamily: 'Nunito', fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isJoined ? AppColors.textMuted : Colors.white,
          ),
        ),
      ),
    );
  }
}
