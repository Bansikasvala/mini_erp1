import 'package:mini_erp/features/auth/domain/repositories/auth_repositoies.dart';

class LoginUsercase {
  final AuthRepositoies repositoies;

  LoginUsercase(this.repositoies);

  Future<bool> call(String email, String password) {
    return repositoies.login(email, password);
  }
}
