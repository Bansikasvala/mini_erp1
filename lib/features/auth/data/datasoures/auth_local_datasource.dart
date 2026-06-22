import 'package:hive/hive.dart';

class AuthLocalDatasource {
  Future<bool> login(String email, String password) async {
    if (email == 'admin@gmail.com' && password == '123456') {
      // Hive.box()

      Hive.box('session').put('isloggedIn', true);

      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await Hive.box('session').put('isloggedIn', false);
  }
}
