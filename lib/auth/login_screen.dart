import 'package:flutter/material.dart';
import 'package:govguide/auth/auth_service.dart';
import 'package:govguide/screens/home/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.facebook, size: 80, color: Color(0xFF1877F2)),
              const SizedBox(height: 20),
              Text(
                "Welcome Back",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              const LoginForm(),
              GoogleSignInButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                labelText: "Username",
                floatingLabelStyle: TextStyle(color: Colors.blue),
                prefixIcon: Icon(Icons.person),
                focusColor: Colors.blue,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter your email";
                }
                if (!value.contains('@')) {
                  return "Please enter a valid email";
                }
                return null;
              },
            ),

            SizedBox(height: 20),

            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                floatingLabelStyle: TextStyle(color: Colors.blue),
                prefixIcon: Icon(Icons.password),
                focusColor: Colors.blue,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
              ),
              validator: (value) {
                if (value == null) {
                  return "Please enter a password";
                }
                if (value.length < 8) {
                  return "Password length must be greater than 8";
                }
                return null;
              },
            ),

            SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                    print("Form is valid. Navigating... ");
                  } else {
                    print("Form is invalid. Try again.");
                  }
                },
                child: Text("Log In"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
      onPressed: () async {
            await AuthService().signInWithGoogle();
          },
      child: const Text("Continue with Google"),
    );
  }
}