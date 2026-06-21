abstract class AuthRepositoies {
  Future<bool> login(String email, String password);
  Future<void> logout();
  Future<bool> isloginIn();
}
