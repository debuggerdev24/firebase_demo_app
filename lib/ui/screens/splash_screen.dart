import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_test_app/providers/auth_provider.dart';
import 'package:firebase_test_app/ui/screens/login_screen.dart';
import 'package:firebase_test_app/ui/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (snapshot.hasData) {
              context
                  .read<AuthenticationProvider>()
                  .changeCurrentUser(snapshot.data);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()));
              });
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              });
            }
            return Container();
          },
        ),
      ),
    );
  }
}
