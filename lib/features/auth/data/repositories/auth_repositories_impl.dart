import 'package:mini_erp/features/auth/data/datasoures/auth_local_datasource.dart';
import 'package:mini_erp/features/auth/domain/repositories/auth_repositoies.dart';

// class AuthRepositoriesImpl implements AuthRepositoies {
//   final AuthLocalDatasource datasource;
// }
class AuthRepositoriesImpl implements AuthRepositoies {
  final AuthLocalDatasource datasource;

  AuthRepositoriesImpl(this.datasource);
  @override
  Future<bool> login(String email, String password) {
    return datasource.login(email, password);
  }

  @override
  Future<bool> isloginIn() {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    return datasource.logout();
  }
}
