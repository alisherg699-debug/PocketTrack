import 'package:hive/hive.dart';
import 'package:pockettrack/features/auth/infrastructure/models/user_model.dart';

class UserLocalDataSource {
  late Box<UserModel> usersBox;

  Future<void> init() async {
    usersBox = await Hive.openBox<UserModel>('users');
  }

  Future<void> add(UserModel user) async {
    await usersBox.put(user.id, user);
  }

  Future<UserModel?> getById(String id) async {
    return usersBox.get(id);
  }

  Future<UserModel?> getByEmail(String email) async {
    try {
      return usersBox.values.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }
}
