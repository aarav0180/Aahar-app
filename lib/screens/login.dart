import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_solution/footer/bottom_nav.dart';
import 'package:google_solution/screens/ngo_home.dart';
import 'package:google_solution/screens/signup.dart';
import '../utils/app_colors.dart';
import '../utils/functions/firebase_user.dart';
import '../widgets/snack_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseServices _firebaseServices = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
            child: CircularProgressIndicator(
                  ),
          )
          : Stack(
        children: [
        Positioned(
        top: -60,
        right: -60,
        child: Container(
          height: 180,
          width: 180,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        bottom: -60,
        left: -60,
        child: Container(
          height: 180,
          width: 180,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
      ),
      Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              const Text(
              'Welcome Back, Changemaker!',
              style: TextStyle(
                fontSize: 37,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Log in to continue your journey of making a difference.',
              style: TextStyle(
                fontSize: 21,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // Image.asset(
            //   'assets/images/food_donation.png',
            //   height: 150,
            // ),
            const SizedBox(height: 30),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                setState(() {
                  _isLoading = true;
                });

                User? user = await _firebaseServices.loginUser(
                  _emailController.text,
                  _passwordController.text,
                );

                if (user != null) {
                  // Fetch user role from Firestore
                  var userData = await _firebaseServices.getUserByEmail(_emailController.text);

                  setState(() {
                    _isLoading = false;
                  });

                  if (userData != null) {
                    showCustomSnackBar(context, 'Login successful!', true);

                    // Navigate based on role
                    String role = userData['role'] ?? 'default';

                    if (role == 'NGO') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => NGOHomeScreen(mail: _emailController.text,)),
                      );
                    } else if (role == 'NGO Agent') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => NGOHomeScreen(mail: _emailController.text)),
                      );
                    } else if (role == 'User') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => BottomNavBar(email: _emailController.text)),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => BottomNavBar(email: _emailController.text,)),
                      );
                    }
                  } else {
                    showCustomSnackBar(context, 'Error fetching user data', false);
                  }
                } else {
                  setState(() {
                    _isLoading = false;
                  });
                  showCustomSnackBar(context, 'Invalid credentials!', false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              child: const Text(
                'Log In',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignUpPage()));
              },
              child: const Text(
                "Don't have an account? Join us now!",
                style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          ],
        ),
      ),
    ),
    ),
    ],
    ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
