import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String password;

  @HiveField(4)
  final String accountType; // 'admin' o 'user'

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.accountType = 'user', // Por defecto es 'user'
  });

  // Método para verificar si es administrador
  bool get isAdmin => accountType == 'admin';

  // Método para verificar si es usuario regular
  bool get isUser => accountType == 'user';
}