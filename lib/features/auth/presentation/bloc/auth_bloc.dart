import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_erp/features/auth/domain/usecases/login_usercase.dart';
import 'package:mini_erp/features/auth/presentation/bloc/auth.state.dart';
import 'package:mini_erp/features/auth/presentation/bloc/auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, Authstate> {
  final LoginUsercase loginUsercase;

  AuthBloc(this.loginUsercase) : super(AuthIntial()) {
    on<LoginRquestd>((event, emit) async {
      emit(AuthLoading());

      try {
        final success = await loginUsercase.call(event.email, event.password);
        if (success) {
          emit(Authenticated());
        } else {
          emit(AuthError('Email or password is wrong'));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}
