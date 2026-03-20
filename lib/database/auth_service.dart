import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
 
class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();
 
  // Holds the logged-in user for the session
  Map<String, dynamic>? _currentUser;
 
  // ── CREATE USER ──────────────────────────────────────────
  /// Returns null on success, or an error string on failure.
  Future<String?> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await DatabaseHelper.instance.database;
 
    // Check if email already exists
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
    if (existing.isNotEmpty) {
      return 'An account with this email already exists.';
      }
    }
 
    try {
      final id = await db.insert('users', {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password, // In production: hash this with bcrypt
        'points': 0,
        'streak': 0,
      });
 
      // Auto-login after sign-up
      _currentUser = {
        'id': id,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'points': 0,
        'streak': 0,
      };
 
      return null; // success
    } on DatabaseException catch (e) {
      return 'Sign-up failed: ${e.toString()}';
    }
  }