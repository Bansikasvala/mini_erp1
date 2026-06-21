abstract class Authstate {}

class AuthIntial extends Authstate {}

class AuthLoading extends Authstate {}

class AuthError extends Authstate {
  final String messages;

  AuthError(this.messages);
}

class Authenticated extends Authstate {}
