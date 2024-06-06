import 'package:hive/hive.dart';
part 'User.g.dart'; // Generated file

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  String? email;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? password;

  @HiveField(3)
  String? phone;

  @HiveField(4)
  String? accountId;

  @HiveField(5)
  String? lastLogin;

  @HiveField(6)
  String? userToken;

  @HiveField(7)
  String? role;

  User({
    this.email,
    this.name,
    this.password,
    this.phone,
    this.accountId,
    this.lastLogin,
    this.userToken,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] ?? '',
      name: (json['first_name'] ?? '') + ' ' + (json['last_name'] ?? ''),
      password: json['password'] ?? '',
      phone: json['phone'] ?? '',
      accountId: json['account_id'] ?? '',
      lastLogin: json['last_login'] ?? '',
      userToken: json['token'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'password': password,
      'phone': phone,
      'account_id': accountId,
      'last_login': lastLogin,
      'token': userToken,
      'role': role,
    };
  }
}
