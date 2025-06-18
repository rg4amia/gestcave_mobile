import 'transaction.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String? role; // admin, user
  final List<Transaction>? transactions;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.transactions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      transactions: json['transactions'] != null
          ? (json['transactions'] as List)
              .map((t) => Transaction.fromJson(t))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
