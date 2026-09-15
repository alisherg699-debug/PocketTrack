import 'package:dio/dio.dart';
import '../../features/expense/infrastructure/datasources/auth_local_data_source.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource _localDataSource;
  final Dio _dio;

  AuthInterceptor(this._localDataSource, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path.contains('/auth/login')) {
      return handler.next(options);
    }
    final token = await _localDataSource.getAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _localDataSource.getRefreshToken();

      if (refreshToken != null) {
        try {
          final response = await _dio.post(
            'https://dummyjson.com/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          final newAccessToken = response.data['accessToken'];

          if (newAccessToken != null) {
            await _localDataSource.saveAccessToken(newAccessToken);

            err.requestOptions.headers['Authorization'] =
                'Bearer $newAccessToken';

            final cloneRequest = await _dio.fetch(err.requestOptions);
            return handler.resolve(cloneRequest);
          }
        } catch (e) {
          await _localDataSource.clearTokens();
        }
      }
    }
    return handler.next(err);
  }
}
