class UserResponse {
  final int? id;
  final String fullName;
  final String email;
  final String role;

  UserResponse({
    this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        id: json['id'],
        fullName: json['fullName'] ?? json['name'] ?? json['username'] ?? 'User',
        email: json['email'] ?? '',
        role: json['role'] ?? 'USER',
      );
}