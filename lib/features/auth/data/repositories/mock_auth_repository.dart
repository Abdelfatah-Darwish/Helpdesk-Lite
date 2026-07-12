import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:helpdesk_lite/core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class MockAuthRepository implements AuthRepository {
  final SharedPreferences sharedPreferences;
  static const String _userCacheKey = 'CACHED_AUTH_USER';

  // Realistic mock users database
  static const List<Map<String, dynamic>> _mockUsers = [
    {
      'id': 'u-1',
      'name': 'Alice Johnson',
      'email': 'employee@company.com',
      'password': 'password123',
      'role': 'employee',
    },
    {
      'id': 'u-2',
      'name': 'Bob Smith',
      'email': 'support@company.com',
      'password': 'password123',
      'role': 'support',
    },
    {
      'id': 'u-3',
      'name': 'Charlie Brown',
      'email': 'manager@company.com',
      'password': 'password123',
      'role': 'manager',
    },
    {
      'id': 'u-4',
      'name': 'Diana Prince',
      'email': 'support2@company.com',
      'password': 'password123',
      'role': 'support',
    }
  ];

  MockAuthRepository({required this.sharedPreferences});

  @override
  Future<UserEntity> login(String email, String password) async {
    // Artificial latency to simulate REST API request
    await Future.delayed(const Duration(milliseconds: 800));

    final normalizedEmail = email.trim().toLowerCase();
    final userMap = _mockUsers.firstWhere(
      (u) => u['email'] == normalizedEmail && u['password'] == password,
      orElse: () => throw const AuthFailure('Invalid email or password'),
    );

    final user = UserModel.fromJson(userMap);
    await sharedPreferences.setString(_userCacheKey, json.encode(user.toJson()));
    return user;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await sharedPreferences.remove(_userCacheKey);
  }

  @override
  Future<UserEntity?> getAuthenticatedUser() async {
    final cachedString = sharedPreferences.getString(_userCacheKey);
    if (cachedString == null) return null;
    try {
      final userMap = json.decode(cachedString) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (_) {
      return null;
    }
  }

  // Helper to fetch list of mock support agents for ticket assignment dropdown
  static List<UserEntity> getSupportAgents() {
    return _mockUsers
        .where((u) => u['role'] == 'support')
        .map((u) => UserModel.fromJson(u))
        .toList();
  }

  // Helper to get mock user by ID
  static UserEntity? getUserById(String id) {
    try {
      final match = _mockUsers.firstWhere((u) => u['id'] == id);
      return UserModel.fromJson(match);
    } catch (_) {
      return null;
    }
  }
}
