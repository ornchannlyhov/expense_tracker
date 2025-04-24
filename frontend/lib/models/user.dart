class User {
  final int id;
  final String username;
  final String email;

  User({required this.id, required this.username, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['ID'] ?? 0,
      username: json['username'] ?? json['USERNAME'] ?? 'Unknown',
      email: json['email'] ?? json['EMAIL'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'username': username, 'email': email};
}
