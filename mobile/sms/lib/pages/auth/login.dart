// import 'package:flutter/material.dart';
// import 'package:sms/pages/admin/admin_dashboard.dart';
// import 'package:sms/pages/auth/Signup.dart';
// import 'package:sms/pages/auth/forgotpassword.dart';
// import 'package:sms/pages/services/api_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool _isLoading = false; // Loading indicator

//   // Function for login API call
//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return; // Validate form first

//     final email = emailController.text.trim();
//     final password = passwordController.text.trim();

//     setState(() {
//       _isLoading = true; // Show loading indicator
//     });

//     try {
//       final response = await ApiService.login(email, password);
//       if (response['success'] == true) {
//         final token = response['token']; // Get the token from the response

//         // Save the token to shared_preferences
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('token', token);

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Login Successful')),
//         );

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => AdminDashboard()),
//         );

//         // Clear fields after login
//         emailController.clear();
//         passwordController.clear();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(response['message'] ?? 'Invalid Credentials')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Something went wrong! Try again.')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false; // Hide loading indicator
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
//                 const SizedBox(height: 20),
//                 const Text(
//                   "Login",
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   "Welcome Back! Please enter your details.",
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 30),

//                 // Login Form
//                 Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       buildTextField(
//                           "Email", Icons.email, false, emailController, true),
//                       const SizedBox(height: 15),
//                       buildTextField("Password", Icons.lock, true,
//                           passwordController, false),
//                       const SizedBox(height: 25),

//                       // Login Button with loading state
//                       SizedBox(
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton(
//                           onPressed: _isLoading ? null : _login,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue.shade900,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                           ),
//                           child: _isLoading
//                               ? CircularProgressIndicator(
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                       Colors.white),
//                                 )
//                               : const Text(
//                                   "Log In",
//                                   style: TextStyle(
//                                       fontSize: 18,
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       // Forgot Password Button
//                       TextButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const ForgetPage()),
//                           );
//                         },
//                         child: const Text(
//                           'Forgot Password?',
//                           style: TextStyle(color: Colors.black),
//                         ),
//                       ),

//                       // const SizedBox(height: 20),

//                       // // OR Divider
//                       // Row(
//                       //   children: const [
//                       //     Expanded(
//                       //         child: Divider(color: Colors.grey, thickness: 1)),
//                       //     Padding(
//                       //       padding: EdgeInsets.symmetric(horizontal: 10),
//                       //       child: Text("OR",
//                       //           style: TextStyle(color: Colors.grey)),
//                       //     ),
//                       //     Expanded(
//                       //         child: Divider(color: Colors.grey, thickness: 1)),
//                       //   ],
//                       // ),

//                       // const SizedBox(height: 20),

//                       // // Google Login Button
//                       // SizedBox(
//                       //   width: double.infinity,
//                       //   height: 50,
//                       //   child: OutlinedButton.icon(
//                       //     onPressed: () {},
//                       //     label: const Text(
//                       //       "Log In With Google",
//                       //       style: TextStyle(
//                       //           fontSize: 16,
//                       //           fontWeight: FontWeight.bold,
//                       //           color: Colors.black87),
//                       //     ),
//                       //     style: OutlinedButton.styleFrom(
//                       //       shape: RoundedRectangleBorder(
//                       //         borderRadius: BorderRadius.circular(30),
//                       //       ),
//                       //       side: const BorderSide(color: Colors.grey),
//                       //     ),
//                       //   ),
//                       // ),

//                       // const SizedBox(height: 2),

//                       // Sign Up Section
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text("Don't have an account?",
//                               style:
//                                   TextStyle(fontSize: 16, color: Colors.grey)),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => SignUpPage(),
//                                 ),
//                               );
//                             },
//                             child: const Text(
//                               "Sign Up",
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

//   // Reusable TextField Widget with Validation
//   Widget buildTextField(String hintText, IconData icon, bool isPassword,
//       TextEditingController controller, bool isEmail) {
//     return TextFormField(
//       controller: controller,
//       obscureText: isPassword,
//       keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
//       decoration: InputDecoration(
//         prefixIcon: Icon(icon, color: Colors.blue.shade900),
//         hintText: hintText,
//         hintStyle: const TextStyle(color: Colors.grey),
//         filled: true,
//         fillColor: Colors.grey.shade100,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(30),
//           borderSide: BorderSide.none,
//         ),
//       ),
//       validator: (value) {
//         if (value == null || value.trim().isEmpty) {
//           return isEmail ? "Please enter an email" : "Please enter a password";
//         }
//         if (isEmail &&
//             !RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$").hasMatch(value)) {
//           return "Enter a valid email";
//         }
//         return null;
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:sms/pages/admin/admin_dashboard.dart';
import 'package:sms/pages/auth/Signup.dart';
import 'package:sms/pages/auth/forgotpassword.dart';
import 'package:sms/pages/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/stud_dashboard/student_dashboard.dart';
// Import the dashboard pages for different roles
// import 'package:sms/pages/student/student_dashboard.dart';
// import 'package:sms/pages/teacher/teacher_dashboard.dart';
// import 'package:sms/pages/parent/parent_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  // Add role selection dropdown
  String? selectedRole;
  final List<String> roles = [
    'Student',
    'Teacher',
    'Parent',
    'Principal',
    'Operator'
  ];

  // // Function for login API call with role
  // Future<void> _login() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   // Validate role selection
  //   if (selectedRole == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select your role')),
  //     );
  //     return;
  //   }

  //   final email = emailController.text.trim();
  //   final password = passwordController.text.trim();
  //   final role = selectedRole!.toLowerCase();

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final response = await ApiService.loginWithRole(email, password, role);
  //     if (response['success'] == true) {
  //       final token = response['token'];
  //       final userRole = response['role'];

  //       // Save the token and role to shared_preferences
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('token', token);
  //       await prefs.setString('role', userRole);

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Login Successful')),
  //       );

  //       // Navigate to appropriate dashboard based on role
  //       _navigateToRoleDashboard(userRole);

  //       // Clear fields after login
  //       emailController.clear();
  //       passwordController.clear();
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(response['message'] ?? 'Invalid Credentials')),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Something went wrong! Try again.')),
  //     );
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  // / Modify the _login method to handle student login differently
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate role selection
    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your role')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> response;

      if (selectedRole!.toLowerCase() == 'student') {
        // For students, use the username field
        final username = emailController.text
            .trim(); // Using the existing email controller for username
        final password = passwordController.text.trim();

        // Call a special student login endpoint
        response = await ApiService.studentLogin(username, password);
      } else {
        // For other roles, continue using email
        final email = emailController.text.trim();
        final password = passwordController.text.trim();
        final role = selectedRole!.toLowerCase();

        response = await ApiService.loginWithRole(email, password, role);
      }

      if (response['success'] == true) {
        // Process successful login as before
        final token = response['token'];
        final userRole = response['role'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', userRole);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful')),
        );

        _navigateToRoleDashboard(userRole);
        emailController.clear();
        passwordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Invalid Credentials')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong! Try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Navigate to the appropriate dashboard based on user role
  void _navigateToRoleDashboard(String role) {
    Widget dashboard;

    switch (role.toLowerCase()) {
      case 'student':
        dashboard = const StudentDashboard();
        break;
      case 'teacher':
        dashboard = const AdminDashboard();
        break;
      case 'parent':
        dashboard = const AdminDashboard();
        break;
      case 'principal':
        dashboard = const AdminDashboard();
        break;
      case 'operator':
        dashboard = const AdminDashboard();
        break;
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

                // Login Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Role selection dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            prefixIcon:
                                Icon(Icons.person_outline, color: Colors.blue),
                            border: InputBorder.none,
                            hintText: 'Select Role',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          value: selectedRole,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          items: roles.map((String role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedRole = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your role';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 15),

                      buildTextField(
                          "Email", Icons.email, false, emailController, true),
                      const SizedBox(height: 15),
                      buildTextField("Password", Icons.lock, true,
                          passwordController, false),
                      const SizedBox(height: 25),

                      // Login Button with loading state
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

                      // Forgot Password Button
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

                      // Sign Up Section
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

  // Reusable TextField Widget with Validation
  Widget buildTextField(String hintText, IconData icon, bool isPassword,
      TextEditingController controller, bool isEmail) {
    // Change the hint text based on role selection
    String displayHint = hintText;
    if (hintText == "Email" && selectedRole == "Student") {
      displayHint = "Username";
    }
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      // keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      keyboardType: isPassword ? TextInputType.text : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue.shade900),
        hintText: displayHint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      // validator: (value) {
      //   if (value == null || value.trim().isEmpty) {
      //     return isEmail ? "Please enter an email" : "Please enter a password";
      //   }
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return selectedRole == "Student" && hintText == "Email"
              ? "Please enter a username"
              : (isEmail ? "Please enter an email" : "Please enter a password");
        }
        // if (isEmail &&
        //     !RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$").hasMatch(value)) {
        //   return "Enter a valid email";
        // }
        // Only validate email format if not a student
        if (isEmail &&
            selectedRole != "Student" &&
            !RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$").hasMatch(value)) {
          return "Enter a valid email";
        }
        return null;
      },
    );
  }
}
