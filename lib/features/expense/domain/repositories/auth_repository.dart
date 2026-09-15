import '../entities/auth_result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<AuthResult> login(String username, String password);

  Future<void> register(User user);

  Future<void> updateUser(User user);

  Future<void> resetPassword(String email, String newPassword);

  Future<void> logout();

  Future<String?> refreshToken(String refreshToken);

  Future<AuthResult> getAuthenticatedUser();
}
