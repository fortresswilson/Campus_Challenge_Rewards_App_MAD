import 'database_helper.dart';

class ChallengeService {
  static final ChallengeService instance = ChallengeService._internal();
  ChallengeService._internal();

  // ── GET ALL CHALLENGES ───────────────────────────────────
  Future<List<Map<String, dynamic>>> getAllChallenges() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query('challenges', orderBy: 'id DESC');
  }

  // ── GET CHALLENGE BY ID ──────────────────────────────────
  Future<Map<String, dynamic>?> getChallengeById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'challenges',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // ── CREATE CHALLENGE ─────────────────────────────────────
  /// Returns the new challenge's id.
  Future<int> createChallenge({
    required String title,
    required String description,
    required String category,
    required String difficulty,
    required int durationDays,
    required int pointsReward,
    required String emoji,
    required int createdBy,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('challenges', {
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'duration_days': durationDays,
      'points_reward': pointsReward,
      'emoji': emoji,
      'created_by': createdBy,
    });
  }

  // ── DELETE CHALLENGE ─────────────────────────────────────
  Future<void> deleteChallenge(int id) async {
    final db = await DatabaseHelper.instance.database;
    // Also remove all participants for this challenge
    await db.delete('participants', where: 'challenge_id = ?', whereArgs: [id]);
    await db.delete('challenges', where: 'id = ?', whereArgs: [id]);
  }

  // ── JOIN CHALLENGE ───────────────────────────────────────
  /// Returns false if user already joined.
  Future<bool> joinChallenge({
    required int userId,
    required int challengeId,
  }) async {
    if (await isJoined(userId: userId, challengeId: challengeId)) return false;

    final db = await DatabaseHelper.instance.database;
    await db.insert('participants', {
      'user_id': userId,
      'challenge_id': challengeId,
      'progress': 0.0,
      'joined_at': DateTime.now().toIso8601String(),
      'completed': 0,
    });
    return true;
  }

  // ── LEAVE CHALLENGE ──────────────────────────────────────
  Future<void> leaveChallenge({
    required int userId,
    required int challengeId,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'participants',
      where: 'user_id = ? AND challenge_id = ?',
      whereArgs: [userId, challengeId],
    );
  }

  // ── LOG ACTIVITY ─────────────────────────────────────────
  /// Increases progress by one step (1 / duration_days).
  /// Awards points and a badge when the challenge is completed.
  Future<void> logActivity({
    required int userId,
    required int challengeId,
  }) async {
    final db = await DatabaseHelper.instance.database;

    // Fetch current participant row
    final rows = await db.query(
      'participants',
      where: 'user_id = ? AND challenge_id = ?',
      whereArgs: [userId, challengeId],
    );
    if (rows.isEmpty) return;

    final participant = rows.first;
    if (participant['completed'] == 1) return; // already done

    // Fetch challenge to know total days
    final challenge = await getChallengeById(challengeId);
    if (challenge == null) return;

    final totalDays = challenge['duration_days'] as int;
    final step = 1.0 / totalDays;
    final newProgress = ((participant['progress'] as double) + step).clamp(0.0, 1.0);
    final isCompleted = newProgress >= 1.0 ? 1 : 0;

    await db.update(
      'participants',
      {'progress': newProgress, 'completed': isCompleted},
      where: 'user_id = ? AND challenge_id = ?',
      whereArgs: [userId, challengeId],
    );

    // Award points if completed
    if (isCompleted == 1) {
      final points = challenge['points_reward'] as int;
      await updatePoints(userId: userId, pointsToAdd: points);
      await checkAndAwardBadges(userId);
    }
  }

  // ── GET JOINED CHALLENGES ────────────────────────────────
  /// Returns a list of challenges with participant progress merged in.
  Future<List<Map<String, dynamic>>> getJoinedChallenges(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery('''
      SELECT c.*, p.progress, p.completed, p.joined_at
      FROM challenges c
      INNER JOIN participants p ON c.id = p.challenge_id
      WHERE p.user_id = ?
      ORDER BY p.joined_at DESC
    ''', [userId]);
    return results;
  }

  // ── IS JOINED ────────────────────────────────────────────
  Future<bool> isJoined({
    required int userId,
    required int challengeId,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'participants',
      where: 'user_id = ? AND challenge_id = ?',
      whereArgs: [userId, challengeId],
    );
    return result.isNotEmpty;
  }

  // ── GET USER POINTS ──────────────────────────────────────
  Future<int> getUserPoints(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'users',
      columns: ['points'],
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (result.isEmpty) return 0;
    return result.first['points'] as int;
  }

  // ── UPDATE POINTS ────────────────────────────────────────
  Future<void> updatePoints({
    required int userId,
    required int pointsToAdd,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.rawUpdate(
      'UPDATE users SET points = points + ? WHERE id = ?',
      [pointsToAdd, userId],
    );
  }

  // ── GET USER BADGES ──────────────────────────────────────
  Future<List<Map<String, dynamic>>> getUserBadges(int userId) async {
    final db = await DatabaseHelper.instance.database;
    return await db.query(
      'rewards',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'earned_at DESC',
    );
  }

  // ── CHECK AND AWARD BADGES ───────────────────────────────
  Future<void> checkAndAwardBadges(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final points = await getUserPoints(userId);

    // Count how many challenges the user has completed
    final completed = await db.query(
      'participants',
      where: 'user_id = ? AND completed = 1',
      whereArgs: [userId],
    );
    final completedCount = completed.length;

    // Existing badges so we don't double-award
    final existing = await getUserBadges(userId);
    final existingNames = existing.map((b) => b['badge_name'] as String).toSet();

    Future<void> award(String badgeName, int pointsRequired) async {
      if (!existingNames.contains(badgeName)) {
        await db.insert('rewards', {
          'user_id': userId,
          'badge_name': badgeName,
          'earned_at': DateTime.now().toIso8601String(),
          'points_required': pointsRequired,
        });
      }
    }

    // Badge rules
    if (completedCount >= 1) await award('First Challenge 🎉', 0);
    if (completedCount >= 5) await award('Challenge Streak 🔥', 0);
    if (completedCount >= 10) await award('Quest Master 👑', 0);
    if (points >= 100)  await award('Century Club 💯', 100);
    if (points >= 500)  await award('Point Hoarder 💰', 500);
    if (points >= 1000) await award('Legend 🏆', 1000);
  }

  // ── GET LEADERBOARD ──────────────────────────────────────
  /// Returns top 20 users sorted by points descending.
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final db = await DatabaseHelper.instance.database;
    return await db.rawQuery('''
      SELECT id, name, points, streak,
             (SELECT COUNT(*) FROM participants p
              WHERE p.user_id = users.id AND p.completed = 1) AS completed_count
      FROM users
      WHERE email != 'system@campusquest.app'
      ORDER BY points DESC
      LIMIT 20
    ''');
  }
}
