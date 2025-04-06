import 'package:flutter/material.dart';
import 'package:google_solution/footer/bottom_nav.dart';
import 'package:google_solution/screens/login.dart';
import 'package:google_solution/screens/signup_form.dart';
import '../core/Auth/auth.dart';
import '../utils/app_colors.dart';
import '../widgets/snack_bar.dart';
import 'agent_home.dart';
import 'ngo_home.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _selectedRole = 'User';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isLoading
          ? Center(
            child: const CircularProgressIndicator(
                  ),
          )
          :Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              height: 250,
              width: 250,
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
              height: 250,
              width: 250,
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
                      'Be a Part of Positive Change!',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Sign up to make a meaningful impact',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 30),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      items: ['User', 'NGO', 'NGO Agent']
                          .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Select Role',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      icon: Icons.lock_reset_outlined,
                      obscureText: true,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed:isLoading
                          ? null
                          : () async {
                        setState(() {
                          isLoading = true;
                        });
                        if (_passwordController.text == _confirmPasswordController.text && _passwordController.text != "") {
                          String? result = await AuthService().signUp(
                            _emailController.text,
                            _passwordController.text,
                            _selectedRole, // This will be either 'User Login', 'NGO Login', or 'NGO Agent Login'
                          );

                          if (result == 'Sign up successful') {
                            setState(() {
                              isLoading = false;
                            });
                            // Navigate to the login page or home screen
                            showCustomSnackBar(context, 'SignUp Successfull', true);

                            if (_selectedRole == 'NGO') {

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    NgoFormPage(
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                        title: "NGO Form",
                                        isAgentForm: false,
                                        onSubmit: (data) {
                                          print('Form submitted with data: $data');

                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => NGOHomeScreen(mail: _emailController.text)),
                                          );
                                        }),
                              )
                              );
                            } else if (_selectedRole == 'NGO Agent') {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) =>
                                      NgoFormPage(
                                          email: _emailController.text,
                                          password: _passwordController.text,
                                          title: "NGO Form",
                                          isAgentForm: true,
                                          onSubmit: (data) {
                                            print('Form submitted with data: $data');
                                            // Navigator.pushReplacement(
                                            //   context,
                                            //   MaterialPageRoute(builder: (context) => AgentHomeScreen(mail: _emailController.text)),
                                            // );
                                          })
                                  )
                              );

                            } else if (_selectedRole == 'User') {

                              // String? result = await AuthService().signUp(
                              //   _emailController.text,
                              //   _passwordController.text,
                              //   _selectedRole,
                              // );

                              // if (result == 'Sign up successful') {
                                setState(() {
                                  isLoading = false;
                                });
                                // Navigate to the login page or home screen
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => BottomNavBar(email: _emailController.text)),
                                );
                              //   showCustomSnackBar(context, 'SignUp Successfull', true);
                              // }else{
                              //   showCustomSnackBar(context, 'Some Problem Occured', true);
                              // }
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => BottomNavBar(email: _emailController.text,)),
                              );
                            }
                          } else {
                            setState(() {
                              isLoading = false;
                            });
                            showCustomSnackBar(context, result ?? 'Error during signup', false);
                          }
                        }
                        else {
                            setState(() {
                              isLoading = false;
                            });
                          showCustomSnackBar(context, 'Passwords do not match!', false);
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
                        'Sign Up',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));

                      },
                      child: const Text(
                        'Already have an account? Login',
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
        labelStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
