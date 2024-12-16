import 'package:firebase_test_app/providers/auth_provider.dart';
import 'package:firebase_test_app/ui/screens/profile_screen.dart';
import 'package:firebase_test_app/ui/screens/sign_up_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _selectedSegment = 0; // 0 for Email, 1 for Phone

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  String? _verificationId;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            if (_selectedSegment == 0) ...[
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                    labelText: "Email", border: OutlineInputBorder()),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                    labelText: "Password", border: OutlineInputBorder()),
                obscureText: true,
              ),
            ] else ...[
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                    labelText: "Phone Number", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              if (_verificationId != null)
                TextField(
                  controller: _otpController,
                  decoration: InputDecoration(
                      labelText: "OTP", border: OutlineInputBorder()),
                ),
            ],

            const SizedBox(height: 10),
            // Submit Button
            ElevatedButton(
              onPressed: () async {
                if (_validateInputs()) {
                  if (_selectedSegment == 0) {
                    // Login with Email
                    try {
                      await authProvider.loginWithEmail(
                        _emailController.text,
                        _passwordController.text,
                      );
                      _showSnackBar(context, "Login successful!");
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()),
                        (_) => false,
                      );
                    } catch (e) {
                      _showSnackBar(context, e.toString());
                    }
                  } else {
                    // Login with Phone
                    if (_verificationId == null) {
                      try {
                        await authProvider.signUpWithPhone(
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
                        await authProvider.validateOtp(
                          _verificationId!,
                          _otpController.text,
                        );
                        _showSnackBar(context, "Login successful!");
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
              child: Text(_selectedSegment == 0 ? "Login" : "Login with Phone"),
            ),

            // Not have account
            RichText(
              text: TextSpan(
                text: 'Not have an account? ',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                children: [
                  TextSpan(
                    text: "Sign Up",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                          ),
                        );
                      },
                  ),
                ],
              ),
            )
          ],
        ),
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
    super.dispose();
  }
}
