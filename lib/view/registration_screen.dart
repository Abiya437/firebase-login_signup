import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treegreens_task/core/route.dart';

import '../controller/auth_service.dart';
import '../widgets/all_button.dart';
import '../widgets/customtextform_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  File? _image;
  bool obscureText = true;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        }
      });
    } catch (e) {
      debugPrint("Image picker error: $e");
    }
  }

  Future<void> saveUserIdToSharedPreferences(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                const SizedBox(height: 39),
                Text(
                  'Create Your Account',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 19,
                      color: Colors.grey.shade700),
                ),
                const SizedBox(height: 26),
                CustomTextFormField(
                  controller: nameController,
                  labelText: 'Name',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: confirmPasswordController,
                  labelText: 'Confirm Password',
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
                      return 'Please confirm your password';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Image'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color((0XFF044275)),
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _image == null
                    ? const Text('No image selected.')
                    : Center(child: Image.file(_image!)),
                const SizedBox(height: 24),
                Center(
                  child: MaterialButtonDesign(
                      height: 50,
                      width: 290,
                      text: 'Sign Up',
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          String email = emailController.text;
                          String password = passwordController.text;
                          String name = nameController.text;

                          try {
                            String result =
                                await AuthService.createAccountWithEmail(
                                    email, password);
                            if (result == 'Account Created') {
                              if (_image != null) {
                                String imageUrl =
                                    await AuthService.uploadProfileImage(
                                            _image!) ??
                                        "";
                                if (imageUrl.isNotEmpty) {
                                  await AuthService.saveUserData(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      name,
                                      email,
                                      imageUrl);
                                  await saveUserIdToSharedPreferences(
                                      FirebaseAuth.instance.currentUser!.uid);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Account Created Successfully....',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      backgroundColor: Colors.green.shade400,
                                    ),
                                  );

                                  Navigator.of(context).pushReplacementNamed(
                                      AppRoutes.loginRoute);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Failed to upload profile image',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      backgroundColor: Colors.red.shade400,
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('No image selected'),
                                    backgroundColor: Colors.red.shade400,
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result)),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      e.message ?? 'Failed to create account')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
