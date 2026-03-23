// lib/database/login_service.dart
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class LoginService {
  // FIX: proper singleton so _currentUser persists across the app
  static final LoginService instance = LoginService._internal();
  LoginService._internal();

  Map<String, dynamic>? _currentUser;

  /// Returns null on success, or an error string on failure.
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;

      final results = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email.trim().toLowerCase(), password],
      );

      if (results.isEmpty) {
        // FIX: clear message telling user to sign up
        return 'No account found. Please sign up first!';
      }

      _currentUser = Map<String, dynamic>.from(results.first);
      return null; // success
    } catch (e) {
      return 'Login failed: ${e.toString()}';
    }
  }

  Map<String, dynamic>? getCurrentUser() => _currentUser;

  void logout() => _currentUser = null;
}
