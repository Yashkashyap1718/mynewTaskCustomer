import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../app/models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        fullName TEXT,
        slug TEXT,
        email TEXT,
        loginType TEXT,
        profilePic TEXT,
        dateOfBirth TEXT,
        fcmToken TEXT,
        countryCode TEXT,
        phoneNumber TEXT,
        walletAmount TEXT,
        totalEarning TEXT,
        gender TEXT,
        referralCode TEXT,
        isActive INTEGER,
        createdAt INTEGER
      )
    ''');
  }

  // Insert user into the database
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert(
      'users',
      user.toJson(),
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Replace if the same ID exists
    );
  }

  // Retrieve user by ID
  Future<UserModel?> getUserById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromJson(maps.first);
    } else {
      return null;
    }
  }

  // Retrieve a single user from the database
  Future<UserModel?> retrieveUserFromTable() async {
    // Initialize the database
    final Database db = await database;

    // Query the table for the user data
    final List<Map<String, Object?>> queryResult = await db.query("users");

    // If the table has data, return the first user's data
    if (queryResult.isNotEmpty) {
      return UserModel.fromJson(queryResult.first);
    }

    // Return null if no user is found in the database
    return null;
  }

  // Update user
  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Delete user by ID
  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get all users (if needed)
  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');

    return List.generate(maps.length, (i) {
      return UserModel.fromJson(maps[i]);
    });
  }
}
