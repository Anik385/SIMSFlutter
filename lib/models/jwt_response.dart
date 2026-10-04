class JwtResponse {
  final String token;
  final String email;
  final String role;

  JwtResponse({required this.token, required this.email, required this.role});

  factory JwtResponse.fromJson(Map<String, dynamic> json) => JwtResponse(
        token: json['token'] ?? json['accessToken'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? 'USER',
      );
}