import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_test_app/firebase_options.dart';
import 'package:firebase_test_app/providers/auth_provider.dart';
import 'package:firebase_test_app/providers/profile_provider.dart';
import 'package:firebase_test_app/services/auth_service.dart';
import 'package:firebase_test_app/services/firestore_service.dart';
import 'package:firebase_test_app/ui/screens/login_screen.dart';
import 'package:firebase_test_app/ui/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthenticationProvider(
            authService: FirebaseAuthService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileProvider(
            firestoreService: FirestoreService(),
          ),
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
