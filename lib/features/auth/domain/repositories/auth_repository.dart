import 'package:pockettrack/features/auth/domain/entities/auth_result.dart';
import 'package:pockettrack/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<AuthResult> login(String username, String password);

  Future<void> register(User user);

  Future<String?> updateUser(User user);

  Future<void> resetPassword(String email, String newPassword);

  Future<void> changePassword(String currentPassword, String newPassword);

  Future<void> logout();

  Future<String?> refreshToken(String refreshToken);

  Future<AuthResult> getAuthenticatedUser();
}
