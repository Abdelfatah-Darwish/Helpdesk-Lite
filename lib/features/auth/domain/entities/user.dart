import 'package:equatable/equatable.dart';

enum UserRole {
  employee,
  support,
  manager;

  String get displayName {
    switch (this) {
      case UserRole.employee:
        return 'Employee';
      case UserRole.support:
        return 'Support Staff';
      case UserRole.manager:
        return 'Manager';
    }
  }
}

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [id, name, email, role];
}
