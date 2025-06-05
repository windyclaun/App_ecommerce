class User {
  final int id;
  final String username;
  final String email;
  final String role;

  User({required this.id, required this.username, required this.email, required this.role});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        username: json['username'],
        email: json['email'],
        role: json['role'],
      );
}

class AuthResponse {
  final String token;

  AuthResponse({required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['token'],
      );
}