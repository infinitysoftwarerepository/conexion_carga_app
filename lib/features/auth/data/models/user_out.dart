
/// Representa el shape que devuelve tu backend para un usuario
/// (response_model=UserOut).
class UserOut {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final bool isCompany;
  final String? companyName;
  final bool active;

  UserOut({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.isCompany,
    required this.active,
    this.companyName,
  });

  factory UserOut.fromJson(Map<String, dynamic> j) => UserOut(
        id: j['id'] as String,
        email: j['email'] as String,
        firstName: j['first_name'] as String,
        lastName: j['last_name'] as String,
        phone: j['phone'] as String,
        isCompany: j['is_company'] as bool,
        companyName: j['company_name'] as String?,
        active: j['active'] as bool,
      );
}
