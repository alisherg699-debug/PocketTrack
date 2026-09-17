import 'package:dio/dio.dart';
import 'package:pockettrack/features/auth/domain/entities/auth_result.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  static const _baseUrl = 'https://dummyjson.com';

  Future<AuthResult> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/login',
        data: {'username': username, 'password': password, 'expiresInMins': 60},
      );
      return AuthResult.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? e.message ?? 'Noma\'lum xatolik';
      throw Exception(message);
    }
  }

  Future<String?> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/refresh',
        data: {'refreshToken': refreshToken, 'expiresInMins': 60},
      );

      return response.data['accessToken'];
    } catch (e) {
      return null;
    }
  }

  Future<AuthResult> getMe() async {
    try {
      final response = await _dio.get('$_baseUrl/auth/me');
      return AuthResult.fromJson(response.data);
    } catch (e) {
      throw Exception('Foydalanuvchini yuklashda xato');
    }
  }
}
