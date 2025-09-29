import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String email;
  final String fullName;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, email, fullName, isActive];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'isActive': isActive,
    };
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      isActive: json['isActive'] as bool,
    );
  }
}