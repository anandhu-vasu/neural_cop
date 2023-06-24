import 'package:flutter/material.dart';
import 'package:neural_cop/controllers/api_controller.dart';
import 'package:neural_cop/utils/globals.dart';
import 'package:neural_cop/utils/helpers.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  promptHostname();
                },
                child: Image.asset(
                  'assets/img/neuralcop.jpeg',
                  width: 150,
                ),
              ),
              const Text(
                "NeuralCop",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 80),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
                obscureText: true,
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                onPressed: () async {
                  final api = await ApiController.init();
                  bool isLogin = await api.login(
                      _usernameController.text, _passwordController.text);

                  if (isLogin) {
                    FocusScope.of(context).unfocus();

                    showSnackBar("Welcome, Login Success!",
                        color: Colors.green, icon: Icons.close);
                    navigatorKey.currentState?.popAndPushNamed('/home');
                  } else {
                    showSnackBar("Login Failed!",
                        color: Colors.red, icon: Icons.close);
                  }
                },
                child: const Text("LOGIN"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
