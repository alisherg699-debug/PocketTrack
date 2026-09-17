import 'dart:async';
import 'package:dio/dio.dart';
import '../../features/expense/infrastructure/datasources/auth_local_data_source.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource _localDataSource;
  final Dio _dio;
  
  // Parallel refresh-larni bitta qilish uchun
  bool _isRefreshing = false;
  Completer<String?>? _refreshCompleter;

  AuthInterceptor(this._localDataSource, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path.contains('/auth/login') || options.path.contains('/auth/refresh')) {
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
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('/auth/refresh')) {
      
      // Agar hozirda refresh jarayoni ketayotgan bo'lsa, kutiladi
      if (_isRefreshing) {
        final newToken = await _refreshCompleter?.future;
        if (newToken != null) {
          return handler.resolve(await _retry(err.requestOptions, newToken));
        }
      }

      _isRefreshing = true;
      _refreshCompleter = Completer<String?>();

      final refreshToken = await _localDataSource.getRefreshToken();

      if (refreshToken != null) {
        try {
          // Alohida Dio instance ishlatish tavsiya etiladi, lekin mavjudini lock qilib ham ishlatsa bo'ladi
          final response = await _dio.post(
            'https://dummyjson.com/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          final newAccessToken = response.data['accessToken'];

          if (newAccessToken != null) {
            await _localDataSource.saveAccessToken(newAccessToken);
            
            // Kutib turgan barcha so'rovlarga yangi tokenni yuborish
            _refreshCompleter?.complete(newAccessToken);
            _isRefreshing = false;

            return handler.resolve(await _retry(err.requestOptions, newAccessToken));
          }
        } catch (e) {
          _refreshCompleter?.complete(null);
          _isRefreshing = false;
          await _localDataSource.clearTokens();
        }
      } else {
        _isRefreshing = false;
        _refreshCompleter?.complete(null);
      }
    }
    return handler.next(err);
  }

  Future<Response> _retry(RequestOptions requestOptions, String token) {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $token',
      },
    );
    
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
