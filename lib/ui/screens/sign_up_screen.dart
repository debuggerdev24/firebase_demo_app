import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_test_app/providers/auth_provider.dart';
import 'package:firebase_test_app/ui/screens/login_screen.dart';
import 'package:firebase_test_app/ui/screens/profile_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  int _selectedSegment = 0; // 0 for Email, 1 for Phone

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String? _verificationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child:
            Consumer<AuthenticationProvider>(builder: (context, provider, _) {
          return Column(
            spacing: 20,
            children: [
              // Segment Control
              Row(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSegmentButton("Email", 0),
                  // _buildSegmentButton("Phone", 1),
                ],
              ),

              // Input Fields
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: "First Name",
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: "Last Name",
                  border: OutlineInputBorder(),
                ),
              ),

              if (_selectedSegment == 0) ...[
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ] else ...[
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                  ),
                ),
                // const SizedBox(height: 10),
                // if (_verificationId != null)
                //   TextField(
                //     controller: _otpController,
                //     decoration: InputDecoration(labelText: "OTP"),
                //   ),
              ],

              const SizedBox(height: 10),

              // Submit Button
              ElevatedButton(
                onPressed: () async {
                  if (_validateInputs()) {
                    if (_selectedSegment == 0) {
                      // Sign up with Email
                      try {
                        await provider.signUpWithEmail(
                          _emailController.text,
                          _passwordController.text,
                        );
                        _showSnackBar(context, "Sign up successful!");
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen()),
                          (_) => false,
                        );
                      } catch (e) {
                        _showSnackBar(context, e.toString());
                      }
                    } else {
                      // Sign up with Phone
                      if (_verificationId == null) {
                        try {
                          await provider.signUpWithPhone(
                            _phoneController.text,
                            (verificationId) {
                              setState(() {
                                _verificationId = verificationId;
                              });
                            },
                          );
                          _showSnackBar(context, "OTP sent successfully!");
                        } catch (e) {
                          _showSnackBar(context, e.toString());
                        }
                      } else {
                        try {
                          await provider.validateOtp(
                            _verificationId!,
                            _otpController.text,
                          );
                          _showSnackBar(context, "Sign up successful!");
                        } catch (e) {
                          _showSnackBar(context, e.toString());
                        }
                      }
                    }
                  } else {
                    _showSnackBar(context, "Please fill all fields.");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: provider.isLoading
                    ? CircularProgressIndicator()
                    : Text(_selectedSegment == 0
                        ? "Sign Up"
                        : "Sign Up with Phone"),
              ),

              // Already have account
              RichText(
                text: TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  children: [
                    TextSpan(
                      text: "Login",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              )
            ],
          );
        }),
      ),
    );
  }

  onCodeSent(String verificationId) {
    setState(() => _verificationId = verificationId);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Enter OTP"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _otpController,
            )
          ],
        ),
        actions: [
          ElevatedButton(
              onPressed: () {
                FirebaseAuth auth = FirebaseAuth.instance;
                PhoneAuthCredential _credential = PhoneAuthProvider.credential(
                    verificationId: verificationId,
                    smsCode: _otpController.text);
                auth.signInWithCredential(_credential).then((result) {
                  if (result != null) {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()));
                  }
                }).catchError((e) {
                  print(e);
                });
              },
              child: Text("Done"))
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSegment = index;
          _verificationId = null; // Reset verification state
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedSegment == index ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: _selectedSegment == index ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  bool _validateInputs() {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      return false;
    }
    if (_selectedSegment == 0) {
      return _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    } else {
      if (_verificationId == null) {
        return _phoneController.text.isNotEmpty;
      } else {
        return _otpController.text.isNotEmpty;
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
