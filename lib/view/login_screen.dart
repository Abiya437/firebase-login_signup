import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treegreens_task/core/route.dart';
import '../controller/auth_service.dart';
import '../widgets/all_button.dart';
import '../widgets/customtextform_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool obscureText = true;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
// GoogleSignIn allows you to authenticate Google users.
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);


  Future<void> _handleGoogleSignIn() async {
    try {
      GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        debugPrint('Signed in: ${account.email}');
        await _storeUserIdInSharedPreferences(account.id);
        _showPopupMessage('Signed in', 'Welcome, ${account.email}');
      } else {
        debugPrint('Sign-in cancelled');
        _showPopupMessage(
            'Sign-in cancelled', 'The sign-in process was cancelled.');
      }
    } catch (error) {
      debugPrint('Error signing in with Google: $error');
      _showPopupMessage('Error', 'Error signing in with Google: $error');
    }
  }

  Future<void> _storeUserIdInSharedPreferences(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  Future<String?> getUserIdFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  void _showPopupMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (title == 'Signed in') {
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.homeRoute);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'images/logo acad.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Login to your account',
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 23),
                  CustomTextFormField(
                    controller: emailController,
                    labelText: 'Email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 34),
                  CustomTextFormField(
                    controller: passwordController,
                    labelText: 'Password',
                    prefixIcon: Icons.password,
                    obscureText: obscureText,
                    showSuffixIcon: true,
                    onSuffixIconTap: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 36),
                  Center(
                    child: MaterialButtonDesign(
                        height: 50,
                        width: 150,
                        text: 'Log in',
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            String email = emailController.text;
                            String password = passwordController.text;

                            try {
                              String? user = await AuthService.loginWithEmail(
                                  email, password);
                              String? userId =
                                  await getUserIdFromSharedPreferences();

                              if (userId != null) {
                                Navigator.of(context).pushReplacementNamed(
                                    AppRoutes.homeRoute,
                                    arguments: {'userId': userId});
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'User ID not found in SharedPreferences')),
                                );
                              }
                                                        } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        }),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      '-Or-',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500),
                    ),
                  ),
                  const SizedBox(height: 31),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _handleGoogleSignIn,
                      icon: Image.asset(
                        'images/google.png',
                        height: 24,
                        width: 24,
                      ),
                      label: const Text('Sign in with Google'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white, // text color
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        "Don't have an account? Sign up",
                        style: TextStyle(
                          color: Color(0XFF1e319d),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
