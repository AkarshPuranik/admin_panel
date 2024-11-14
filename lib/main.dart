// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';

// Define Firebase configuration for the web
const firebaseConfig = FirebaseOptions(
    apiKey: "AIzaSyBxXmzlvv3nUkgUPC-71PpIscFeSFcxBGo",
    authDomain: "community-b4cba.firebaseapp.com",
    projectId: "community-b4cba",
    storageBucket: "community-b4cba.appspot.com", // Corrected the storageBucket URL
    messagingSenderId: "606215654673",
    appId: "1:606215654673:web:d2d114b5125a49b7c710b0",
    measurementId: "G-K4ZEL5ZJJT"
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with web options
  await Firebase.initializeApp(
    options: firebaseConfig,
  );

  runApp(const UserApp());
}

class UserApp extends StatelessWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false, // Removes the debug banner
    );
  }
}
