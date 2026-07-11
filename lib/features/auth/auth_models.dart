class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
    this.emailVerified = false,
  });

  final Object id;
  final String name;
  final String email;
  final List<String> roles;
  final bool emailVerified;

  bool get isAdmin => roles.contains('Super Admin') || roles.contains('Administrateur');
  bool get isPharmacist => roles.contains('Pharmacien');

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final rolesJson = json['roles'];
    final roles = <String>[];
    if (rolesJson is List) {
      for (final role in rolesJson) {
        if (role is String) {
          roles.add(role);
        } else if (role is Map && role['name'] is String) {
          roles.add(role['name'] as String);
        }
      }
    }

    return AuthUser(
      id: json['id'] as Object,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      roles: roles,
      emailVerified: json['email_verified_at'] != null,
    );
  }
}
