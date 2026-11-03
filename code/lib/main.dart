import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/search_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseReady = false;
  final options = DefaultFirebaseOptions.currentPlatform;
  if (!options.apiKey.startsWith('REPLACE_WITH')) {
    try {
      await Firebase.initializeApp(options: options);
      firebaseReady = true;
    } catch (_) {
      firebaseReady = false;
    }
  }
  runApp(FirestoreSearchApp(firebaseReady: firebaseReady));
}

class FirestoreSearchApp extends StatelessWidget {
  final bool firebaseReady;

  const FirestoreSearchApp({super.key, required this.firebaseReady});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: SearchScreen(firebaseReady: firebaseReady),
    );
  }
}
