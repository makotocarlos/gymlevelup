import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymlevelup/screen/login.dart';
import 'package:gymlevelup/screenhome/HomeScreen.dart';
import 'package:gymlevelup/screen/QuestionnaireScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymLevelUp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, // Ocultar el banner de debug
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          final String userId = FirebaseAuth.instance.currentUser!.uid;

          // Verificar si el usuario ya completó el cuestionario
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users') // Colección de usuarios
                .doc(userId)
                .collection('questionnaires') // Subcolección de cuestionarios
                .doc('user_info') // Documento cambiado a 'user_info'
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                // Si el cuestionario no ha sido completado
                return QuestionnaireScreen(userId: userId);
              }

              // Si el cuestionario ya está completado
              return HomeScreen(userId: userId);
            },
          );
        }

        // Usuario no autenticado
        return LoginScreen();
      },
    );
  }
}
