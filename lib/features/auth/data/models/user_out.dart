// lib/features/auth/data/models/user_out.dart
class UserOut {
  final String id;        // ← UUID como string
  final String email;
  final String? firstName;
  final String? lastName;
  final bool? active;
  final int? points;

  UserOut({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.active,
    this.points,
  });

  factory UserOut.fromJson(Map<String, dynamic> json) {
    return UserOut(
      id: json['id'] as String,                    // ← antes int
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      active: json['active'] as bool?,
      points: json['points'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "first_name": firstName,
        "last_name": lastName,
        "active": active,
        "points": points,
      };
}
