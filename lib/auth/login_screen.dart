import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:govguide/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  
  // ADDED: Controllers to get the text from the fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _setLoading(bool value) {
    if (mounted) {
      setState(() => _isLoading = value);
    }
  }

  // ADDED: Real Email/Password Login Logic
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      _setLoading(true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) context.go('/'); 
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login Failed: ${e.toString()}")),
          );
        }
      } finally {
        _setLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    const Text(
                      "GG",
                      style: TextStyle(
                        color: Color(0xFF1877F2),
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 40),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildModernField("Email address", Icons.email_outlined, _emailController),
                          const SizedBox(height: 12),
                          _buildModernField("Password", Icons.lock_outline, _passwordController, isPassword: true),
                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1877F2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              onPressed: _handleLogin, // Updated to handle real login
                              child: const Text(
                                "Log In",
                                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Forgotten password?",
                              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text("OR", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 30),

                    _SocialSignInButton(onLoading: _setLoading),

                    const SizedBox(height: 60),

                    OutlinedButton(
                      onPressed: () => context.push('/signup'), // Ensure this matches your router!
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                        side: const BorderSide(color: Color(0xFF1877F2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        "Create new account",
                        style: TextStyle(color: Color(0xFF1877F2), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          if (_isLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.8), 
              child: const Center(child: CircularProgressIndicator(color: Color(0xFF1877F2))),
            ),
        ],
      ),
    );
  }

  Widget _buildModernField(String hint, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return TextFormField(
      controller: controller, // Added controller
      obscureText: isPassword,
      style: const TextStyle(fontSize: 16),
      validator: (val) => val!.isEmpty ? "Enter your $hint" : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        filled: true,
        fillColor: const Color(0xFFF5F6F7),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE4E6EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1877F2), width: 1.5),
        ),
      ),
    );
  }
}

class _SocialSignInButton extends StatelessWidget {
  final Function(bool) onLoading;
  const _SocialSignInButton({required this.onLoading});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        onLoading(true);
        try {
          final user = await AuthService().signInWithGoogle();
          if (!context.mounted) return;
          if (user != null) context.go('/');
        } finally {
          onLoading(false);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE4E6EB)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
              height: 20,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.login),
            ),
            const SizedBox(width: 12),
            const Text(
              "Continue with Google",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}