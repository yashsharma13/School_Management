// // ===== ye confirm code hai===
// import 'package:flutter/material.dart';
// import 'package:sms/pages/auth/login.dart';
// import 'package:sms/pages/services/api_service.dart';
// import 'otp_verification.dart';

// class SignUpPage extends StatefulWidget {
//   const SignUpPage({super.key});

//   @override
//   _SignUpPageState createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();

//   bool isEmailVerified = false;
//   bool isPhoneVerified = false;

//   Future<void> _register() async {
//     if (!isEmailVerified || !isPhoneVerified) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text(
//                 'Please verify both email and phone number before registering.')),
//       );
//       return;
//     }

//     final success = await ApiService.register(
//       _emailController.text.trim(),
//       _phoneController.text.trim(),
//       _passwordController.text.trim(),
//       _confirmPasswordController.text.trim(),
//     );

//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Registration Successful!')),
//       );
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Email Already Exists. Try Again!')),
//       );
//     }
//   }

//   void _navigateToOTPPage(String type) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => OTPVerificationPage()),
//     );

//     if (result == true) {
//       setState(() {
//         if (type == "email") {
//           isEmailVerified = true;
//         } else {
//           isPhoneVerified = true;
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 25),
//         child: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const CircleAvatar(
//                   radius: 50,
//                   backgroundImage: AssetImage('assets/images/almanet1.jpg'),
//                 ),
//                 const Text(
//                   "Sign Up",
//                   style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   "Welcome! Please enter your details below.",
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 30),
//                 Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       buildTextField(
//                         "Email",
//                         Icons.email,
//                         false,
//                         _emailController,
//                         isEmailVerified,
//                         "email",
//                       ),
//                       const SizedBox(height: 15),
//                       buildTextField(
//                         "Phone Number",
//                         Icons.phone,
//                         false,
//                         _phoneController,
//                         isPhoneVerified,
//                         "phone",
//                       ),
//                       const SizedBox(height: 15),
//                       buildTextField(
//                         "Password",
//                         Icons.lock,
//                         true,
//                         _passwordController,
//                         false,
//                         "",
//                       ),
//                       const SizedBox(height: 15),
//                       buildTextField(
//                         "Re-Enter Password",
//                         Icons.lock_outline,
//                         true,
//                         _confirmPasswordController,
//                         false,
//                         "",
//                       ),
//                       const SizedBox(height: 25),
//                       SizedBox(
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             if (_formKey.currentState!.validate()) {
//                               _register();
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(content: Text('Signing Up')));
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue.shade900,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                           ),
//                           child: const Text(
//                             "Sign Up",
//                             style: TextStyle(fontSize: 18, color: Colors.white),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Row(
//                         children: [
//                           const Expanded(
//                               child: Divider(color: Colors.grey, thickness: 1)),
//                           const Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 10),
//                             child: Text("OR",
//                                 style: TextStyle(color: Colors.grey)),
//                           ),
//                           const Expanded(
//                               child: Divider(color: Colors.grey, thickness: 1)),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       SizedBox(
//                         width: double.infinity,
//                         height: 50,
//                         child: OutlinedButton.icon(
//                           onPressed: () {
//                             // Handle Google sign-up
//                           },
//                           icon: const Icon(Icons.login, color: Colors.red),
//                           label: const Text(
//                             "Sign Up With Google",
//                             style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87),
//                           ),
//                           style: OutlinedButton.styleFrom(
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             side: const BorderSide(color: Colors.grey),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text("Already have an account?",
//                               style:
//                                   TextStyle(fontSize: 16, color: Colors.grey)),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => LoginPage(),
//                                 ),
//                               );
//                             },
//                             child: const Text(
//                               "Log In",
//                               style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blue),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildTextField(
//     String hintText,
//     IconData icon,
//     bool isPassword,
//     TextEditingController controller,
//     bool isVerified,
//     String type,
//   ) {
//     return TextFormField(
//       controller: controller,
//       obscureText: isPassword,
//       decoration: InputDecoration(
//         prefixIcon: Icon(icon, color: Colors.blue.shade900),
//         hintText: hintText,
//         filled: true,
//         fillColor: Colors.grey.shade100,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(30),
//           borderSide: BorderSide.none,
//         ),
//         suffixIcon: isVerified
//             ? const Icon(Icons.check_circle, color: Colors.green)
//             : (type.isNotEmpty
//                 ? TextButton(
//                     onPressed: () => _navigateToOTPPage(type),
//                     child: const Text(
//                       "Verify",
//                       style: TextStyle(color: Colors.blue),
//                     ),
//                   )
//                 : null),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:sms/pages/auth/login.dart';
import 'package:sms/pages/services/api_service.dart';
import 'otp_verification.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _selectedRole = 'Operator'; // Default role selected is 'Operator'

  bool isEmailVerified = false;
  bool isPhoneVerified = false;

  // List of roles for selection
  final List<String> roles = ['Operator', 'Teacher', 'Principal', 'Parent'];

  Future<void> _register() async {
    if (!isEmailVerified || !isPhoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please verify both email and phone number before registering.')),
      );
      return;
    }

    final success = await ApiService.register(
      _emailController.text.trim(),
      _phoneController.text.trim(),
      _passwordController.text.trim(),
      _confirmPasswordController.text.trim(),
      _selectedRole, // Send the selected role to the backend
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email Already Exists. Try Again!')),
      );
    }
  }

  void _navigateToOTPPage(String type) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OTPVerificationPage()),
    );

    if (result == true) {
      setState(() {
        if (type == "email") {
          isEmailVerified = true;
        } else {
          isPhoneVerified = true;
        }
      });
    }
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
                const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Welcome! Please enter your details below.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildTextField(
                        "Email",
                        Icons.email,
                        false,
                        _emailController,
                        isEmailVerified,
                        "email",
                      ),
                      const SizedBox(height: 15),
                      buildTextField(
                        "Phone Number",
                        Icons.phone,
                        false,
                        _phoneController,
                        isPhoneVerified,
                        "phone",
                      ),
                      const SizedBox(height: 15),
                      buildTextField(
                        "Password",
                        Icons.lock,
                        true,
                        _passwordController,
                        false,
                        "",
                      ),
                      const SizedBox(height: 15),
                      buildTextField(
                        "Re-Enter Password",
                        Icons.lock_outline,
                        true,
                        _confirmPasswordController,
                        false,
                        "",
                      ),
                      const SizedBox(height: 15),
                      // Role Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        items: roles.map((String role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (newRole) {
                          setState(() {
                            _selectedRole = newRole!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Select Role',
                          prefixIcon: const Icon(Icons.account_circle),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _register();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Signing Up')));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Expanded(
                              child: Divider(color: Colors.grey, thickness: 1)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("OR",
                                style: TextStyle(color: Colors.grey)),
                          ),
                          const Expanded(
                              child: Divider(color: Colors.grey, thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Handle Google sign-up
                          },
                          icon: const Icon(Icons.login, color: Colors.red),
                          label: const Text(
                            "Sign Up With Google",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Log In",
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

  Widget buildTextField(
    String hintText,
    IconData icon,
    bool isPassword,
    TextEditingController controller,
    bool isVerified,
    String type,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue.shade900),
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isVerified
            ? const Icon(Icons.check_circle, color: Colors.green)
            : (type.isNotEmpty
                ? TextButton(
                    onPressed: () => _navigateToOTPPage(type),
                    child: const Text(
                      "Verify",
                      style: TextStyle(color: Colors.blue),
                    ),
                  )
                : null),
      ),
    );
  }
}
