/*

LOGIN PAGE

On this page, an existing user can login with their :
- email
- pw

-----------
Once the user successfully logs in, they will be redirected to home page

If user doesn't have an account yet,they can go to register page from here to create one.

*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixora/features/auth/presentation/components/my_button.dart';
import 'package:pixora/features/auth/presentation/components/my_text_field.dart';
import 'package:pixora/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:pixora/responsive/constrained_scaffold.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;
  const LoginPage({super.key, required this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text controller
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  void login() {
    final String email = emailController.text;
    final String pw = pwController.text;

    //auth cubit
    final authCubit = context.read<AuthCubit>();

    //ensure that the email and password fields are non empthy
    if (email.isNotEmpty && pw.isNotEmpty) {
      //login!
      authCubit.login(email, pw);
    }

    //display error if some fields are empth
    else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter both email and password")));
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    pwController.dispose();

    super.dispose();
  }

  //BUILD UI

  @override
  Widget build(BuildContext context) {
    //Scaffold

    return ConstrainedScaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //logo
                Icon(
                  Icons.lock_open_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(
                  height: 50,
                ),

                //welcome back message
                Text(
                  "Welcome back, you've been missed!",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16),
                ),

                const SizedBox(
                  height: 25,
                ),

                //email textfield
                MyTextField(
                    controller: emailController,
                    hintText: "Email",
                    obscureText: false),

                const SizedBox(
                  height: 10,
                ),

                //pw textfield
                MyTextField(
                    controller: pwController,
                    hintText: "Password",
                    obscureText: true),

                //login button
                MyButton(onTap: login, text: "Login"),

                //not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not a member?",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    GestureDetector(
                      onTap: widget.togglePages,
                      child: Text(
                        " Register now",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
