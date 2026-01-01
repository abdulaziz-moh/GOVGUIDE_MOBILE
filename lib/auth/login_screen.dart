import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:govguide/auth/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Helper to safely update loading state and avoid "setState after dispose"
  void _setLoading(bool value) {
    if (mounted) {
      setState(() => _isLoading = value);
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
                    // --- MINIMALIST BRANDING ---
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

                    // --- INPUT SECTION ---
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildModernField("Email address", Icons.email_outlined),
                          const SizedBox(height: 12),
                          _buildModernField("Password", Icons.lock_outline, isPassword: true),
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
                              onPressed: () => context.go('/'),
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

                    // --- GOOGLE SIGN IN ---
                    _SocialSignInButton(
                      onLoading: _setLoading,
                    ),

                    const SizedBox(height: 60),

                    OutlinedButton(
                      onPressed: () => context.push('/signup'),
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
          
          // --- FULL SCREEN LOADER WITH NEW SYNTAX ---
          if (_isLoading)
            Container(
              // FIX: Replaced .withOpacity with .withValues
              color: Colors.white.withValues(alpha: 0.8), 
              child: const Center(child: CircularProgressIndicator(color: Color(0xFF1877F2))),
            ),
        ],
      ),
    );
  }

  Widget _buildModernField(String hint, IconData icon, {bool isPassword = false}) {
    return TextFormField(
      obscureText: isPassword,
      style: const TextStyle(fontSize: 16),
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
          
          // Check if user navigated away during the async call
          if (!context.mounted) return;

          if (user != null) {
            context.go('/');
          }
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