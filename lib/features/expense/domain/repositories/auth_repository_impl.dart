import 'package:flutter/foundation.dart';
import 'package:pockettrack/features/expense/infrastructure/datasources/user_local_data_source.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../infrastructure/datasources/auth_local_data_source.dart';
import '../../infrastructure/datasources/auth_remote_data_source.dart';
import '../../infrastructure/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final UserLocalDataSource userLocalDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.userLocalDataSource,
  });

  @override
  Future<AuthResult> login(String username, String password) async {
    debugPrint('Login harakati: $username');
    final localUser = await userLocalDataSource.getByEmail(username.trim());

    if (localUser != null && localUser.password == password.trim()) {
      final result = AuthResult(
        id: int.tryParse(localUser.id) ?? DateTime.now().millisecondsSinceEpoch,
        username: localUser.firstName,
        email: localUser.email,
        firstName: localUser.firstName,
        lastName: 'Lokal',
        gender: '',
        image: localUser.imagePath ?? '',
        accessToken: 'dummy_access_token_${localUser.id}',
        refreshToken: 'dummy_refresh_token_${localUser.id}',
        phone: localUser.phone,
        currency: localUser.currency,
      );
      await localDataSource.saveAccessToken(result.accessToken);
      await localDataSource.saveRefreshToken(result.refreshToken);
      return result;
    }

    final result = await remoteDataSource.login(username, password);
    await localDataSource.saveAccessToken(result.accessToken);
    await localDataSource.saveRefreshToken(result.refreshToken);
    return result;
  }

  @override
  Future<void> register(User user) async {
    final userModel = UserModel.fromEntity(user);
    await userLocalDataSource.add(userModel);
  }

  @override
  Future<void> updateUser(User user) async {
    final existingUser = await userLocalDataSource.getById(user.id);
    if (existingUser != null) {
      final updatedUserModel = UserModel(
        id: existingUser.id,
        firstName: user.firstName,
        email: user.email,
        password: existingUser.password,
        phone: user.phone,
        currency: user.currency,
        imagePath: user.imagePath,
      );
      await userLocalDataSource.add(updatedUserModel);
    }
  }

  @override
  Future<void> resetPassword(String email, String newPassword) async {
    final user = await userLocalDataSource.getByEmail(email.trim());
    if (user != null) {
      final updatedUser = user.copyWith(password: newPassword.trim());
      await userLocalDataSource.add(updatedUser);
    } else {
      throw Exception("Bunday elektron pochtali foydalanuvchi topilmadi");
    }
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearTokens();
  }

  @override
  Future<String?> refreshToken(String refreshToken) async {
    if (refreshToken.startsWith('dummy_')) return refreshToken;
    return await remoteDataSource.refreshToken(refreshToken);
  }

  @override
  Future<AuthResult> getAuthenticatedUser() async {
    final token = await localDataSource.getAccessToken();
    if (token != null && token.startsWith('dummy_access_token_')) {
      final userId = token.replaceFirst('dummy_access_token_', '');
      final localUser = await userLocalDataSource.getById(userId);
      
      if (localUser != null) {
        return AuthResult(
          id: int.tryParse(localUser.id) ?? 0,
          username: localUser.firstName,
          email: localUser.email,
          firstName: localUser.firstName,
          lastName: 'Lokal',
          gender: '',
          image: localUser.imagePath ?? '',
          accessToken: token,
          refreshToken: '',
          phone: localUser.phone,
          currency: localUser.currency,
        );
      }
    }
    return await remoteDataSource.getMe();
  }
}
