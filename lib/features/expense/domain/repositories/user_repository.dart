import 'package:pockettrack/features/auth/domain/entities/user.dart';

abstract class UserRepository {
  Future<void> register(User user);
  Future<User> login(String email, String password);
}
