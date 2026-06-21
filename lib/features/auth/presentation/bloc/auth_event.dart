abstract class AuthEvent {}

class LoginRquestd extends AuthEvent {
  String email;
  String password;
  LoginRquestd(this.email, this.password);
}
