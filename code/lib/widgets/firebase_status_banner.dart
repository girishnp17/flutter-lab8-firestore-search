import 'package:flutter/material.dart';

/// Shown whenever Firebase.initializeApp() failed (no project configured
/// yet) so the UI still renders instead of crashing.
class FirebaseStatusBanner extends StatelessWidget {
  const FirebaseStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.amber.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Firebase not configured — run `flutterfire configure` with your '
              'own project to enable live Firestore data.',
              style: TextStyle(fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}
