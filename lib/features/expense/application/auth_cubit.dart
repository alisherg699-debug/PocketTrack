import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/entities/user.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthState.initial());

  Future<void> checkAuth() async {
    emit(const AuthState.loading());
    await Future.delayed(const Duration(seconds: 3));
    try {
      final user = await _repository.getAuthenticatedUser();
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> login(String username, String password) async {
    emit(const AuthState.loading());
    try {
      final user = await _repository.login(username, password);
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> register(String firstName, String email, String password) async {
    emit(const AuthState.loading());
    try {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: firstName,
        email: email,
        password: password,
      );
      await _repository.register(user);
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthState.unauthenticated());
  }

  Future<void> updateProfile(String firstName, String email, {String? phone, String? currency}) async {
    final currentState = state;
    currentState.maybeWhen(
      authenticated: (authUser) async {
        emit(const AuthState.loading());
        try {
          final user = User(
            id: authUser.id.toString(),
            firstName: firstName,
            email: email,
            password: '', 
            phone: phone,
            currency: currency,
          );
          await _repository.updateUser(user);
          
          final updatedUser = authUser.copyWith(
            firstName: firstName,
            email: email,
            phone: phone,
            currency: currency,
          );
          emit(AuthState.authenticated(updatedUser));
        } catch (e) {
          emit(AuthState.error(e.toString()));
        }
      },
      orElse: () {},
    );
  }

  Future<void> resetPassword(String email, String newPassword) async {
    emit(const AuthState.loading());
    try {
      await _repository.resetPassword(email, newPassword);
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }
}
