import 'package:flutter/material.dart';
import 'package:sms/pages/admin/admin_dashboard.dart';
import 'package:sms/pages/auth/Signup.dart';
import 'package:sms/pages/auth/forgotpassword.dart';
import 'package:sms/pages/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/stud_dashboard/student_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  bool _obscurePassword = true; // 👈 for eye toggle

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final username = usernameController.text.trim();
      final password = passwordController.text.trim();

      final response = await ApiService.login(username, password);

      if (response['success'] == true) {
        if (response['user_email'] == null) {
          throw Exception('Server response missing user_email');
        }

        final prefs = await SharedPreferences.getInstance();
        await Future.wait([
          prefs.setString('token', response['token']),
          prefs.setString('role', response['role']),
          prefs.setString('user_email', response['user_email']),
          if (response['user_id'] != null)
            prefs.setString('user_id', response['user_id'].toString()),
        ]);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful')),
        );

        _navigateToRoleDashboard(response['role']);
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Invalid Credentials';
        });
      }
    } catch (e) {
      debugPrint('Login error: $e');
      setState(() {
        _errorMessage = 'Login failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToRoleDashboard(String role) {
    Widget dashboard;

    switch (role.toLowerCase()) {
      case 'student':
        dashboard = const StudentDashboard();
        break;
      case 'admin':
      case 'operator':
      default:
        dashboard = const AdminDashboard();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => dashboard),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/almanet1.jpg'),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Welcome Back! Please enter your details.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildTextField("Email/Username", Icons.person, false,
                          usernameController),
                      const SizedBox(height: 15),
                      buildTextField(
                          "Password", Icons.lock, true, passwordController),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : const Text(
                                  "Log In",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ForgetPage()),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hintText, IconData icon, bool isPassword,
      TextEditingController controller) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue.shade900),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your ${hintText.toLowerCase()}';
        }
        return null;
      },
    );
  }
}
