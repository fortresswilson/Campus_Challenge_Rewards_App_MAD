import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class LoginService {
  Map<String, dynamic>? _currentUser;

  /// Returns null on success, or an error string on failure.
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    final db = await DatabaseHelper.instance.database;
 
    final results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email.trim().toLowerCase(), password],
    );
 
    if (results.isEmpty) {
      return 'Incorrect email or password.';
    }
 
    _currentUser = Map<String, dynamic>.from(results.first);
    return null; // success
  }
 
  // ── GET CURRENT USER ─────────────────────────────────────
  Map<String, dynamic>? getCurrentUser() => _currentUser;
 
  // ── LOGOUT ───────────────────────────────────────────────
  void logout() => _currentUser = null;
}
