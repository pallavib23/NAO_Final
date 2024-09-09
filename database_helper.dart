import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'users.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE users('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'username TEXT UNIQUE, '
              'password TEXT)',
        );
      },
    );
  }

  // Register a new user without password hashing
  Future<int> registerUser(String username, String password) async {
    final db = await database;
    try {
      return await db.insert('users', {'username': username, 'password': password});
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception('Username already exists');
      } else {
        throw Exception('Error inserting user: $e');
      }
    } catch (e) {
      throw Exception('Error inserting user: $e');
    }
  }

  // Retrieve user details
  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await database;
    final result =
    await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (result.isNotEmpty) {
      print('User found: ${result.first}');
      return result.first;
    }
    print('User not found for username: $username');
    return null;
  }

  // Log in user without password hashing
  Future<bool> loginUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users');
  }

  // Delete user
  Future<void> deleteUser(String username) async {
    final db = await database;
    await db.delete('users', where: 'username = ?', whereArgs: [username]);
  }

  // Update user password without hashing
  Future<void> updateUser(String username, String newPassword) async {
    final db = await database;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  // Close the database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
