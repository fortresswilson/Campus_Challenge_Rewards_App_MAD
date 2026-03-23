// lib/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('campus_quest.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. Users table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        name     TEXT    NOT NULL,
        email    TEXT    NOT NULL UNIQUE,
        password TEXT    NOT NULL,
        points   INTEGER NOT NULL DEFAULT 0,
        streak   INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 2. Challenges table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS challenges (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        title         TEXT    NOT NULL,
        description   TEXT    NOT NULL,
        category      TEXT    NOT NULL,
        difficulty    TEXT    NOT NULL,
        duration_days INTEGER NOT NULL,
        points_reward INTEGER NOT NULL,
        emoji         TEXT    NOT NULL,
        created_by    INTEGER NOT NULL,
        FOREIGN KEY (created_by) REFERENCES users(id)
      )
    ''');

    // 3. Participants table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS participants (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id      INTEGER NOT NULL,
        challenge_id INTEGER NOT NULL,
        progress     REAL    NOT NULL DEFAULT 0.0,
        joined_at    TEXT    NOT NULL,
        completed    INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id)      REFERENCES users(id),
        FOREIGN KEY (challenge_id) REFERENCES challenges(id)
      )
    ''');

    // 4. Rewards table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS rewards (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id          INTEGER NOT NULL,
        badge_name       TEXT    NOT NULL,
        earned_at        TEXT    NOT NULL,
        points_required  INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Seed starter challenges
    await _seedChallenges(db);
  }

  Future _seedChallenges(Database db) async {
    // System user to own seed challenges
    await db.insert('users', {
      'name': 'CampusQuest',
      'email': 'system@campusquest.app',
      'password': 'system',
      'points': 0,
      'streak': 0,
    });

    final seedChallenges = [
      {
        'title': '10K Steps Daily',
        'description': 'Walk 10,000 steps every day for a week.',
        'category': 'Fitness',
        'difficulty': 'Medium',
        'duration_days': 7,
        'points_reward': 150,
        'emoji': '🏃',
        'created_by': 1,
      },
      {
        'title': 'Study Streak',
        'description': 'Study for at least 2 hours each day for 5 days.',
        'category': 'Academic',
        'difficulty': 'Hard',
        'duration_days': 5,
        'points_reward': 200,
        'emoji': '📚',
        'created_by': 1,
      },
      {
        'title': 'Mindful Morning',
        'description': 'Meditate for 10 minutes every morning for 3 days.',
        'category': 'Mindfulness',
        'difficulty': 'Easy',
        'duration_days': 3,
        'points_reward': 75,
        'emoji': '🧘',
        'created_by': 1,
      },
      {
        'title': 'Hydration Hero',
        'description': 'Drink 8 glasses of water daily for 5 days.',
        'category': 'Health',
        'difficulty': 'Easy',
        'duration_days': 5,
        'points_reward': 100,
        'emoji': '💧',
        'created_by': 1,
      },
    ];

    for (final challenge in seedChallenges) {
      await db.insert('challenges', challenge);
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
} 
