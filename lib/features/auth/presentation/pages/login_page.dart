import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_erp/features/auth/data/datasoures/auth_local_datasource.dart';
import 'package:mini_erp/features/auth/data/repositories/auth_repositories_impl.dart';
import 'package:mini_erp/features/auth/domain/usecases/login_usercase.dart';
import 'package:mini_erp/features/auth/presentation/bloc/auth.state.dart';
import 'package:mini_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mini_erp/features/auth/presentation/bloc/auth_event.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) {
          final datasouce = AuthLocalDatasource();
          final repositories = AuthRepositoriesImpl(datasouce);
          final loginusercase = LoginUsercase(repositories);

          return AuthBloc(loginusercase);
        },
        child: BlocConsumer<AuthBloc, Authstate>(
          listener: (context, state) {
            if (state is Authenticated) {
              // ScaffoldMessenger.of(
              //   context,
              // ).showSnackBar(SnackBar(content: Text("Naviation")));

              context.go('/dashboard');
            }
            if (state is AuthError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("${state.messages}")));
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Form(
                    key: formkey,
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            "Login ",
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 23,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                        SizedBox(
                          height: 60,
                          width: 300,
                          child: TextFormField(
                            validator: (value) {
                              final bool emailValid = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                              ).hasMatch('${value}');
                              if (value == null || value.isEmpty) {
                                return "Enter email";
                              }
                              if (!emailValid) {
                                return "Please Enter valid email";
                              }
                              return null;
                            },
                            controller: emailController,

                            decoration: InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: SizedBox(
                            height: 60,
                            width: 300,
                            child: TextFormField(
                              controller: passwordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Enter password";
                                }
                                if (value.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                              },

                              decoration: InputDecoration(
                                labelText: "Password",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (formkey.currentState!.validate()) {
                              print('Email :- ${emailController.text}');
                              print('Password :- ${passwordController.text}');

                              context.read<AuthBloc>().add(
                                LoginRquestd(
                                  emailController.text,
                                  passwordController.text,
                                ),
                              );
                            }
                          },
                          child: Text("Login"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },

          // child: ,
        ),
      ),
    );
  }
}
