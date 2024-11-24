import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymlevelup/screen/login.dart';

class HomeScreen extends StatelessWidget {
  final String userId;

  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  Future<Map<String, dynamic>> _fetchUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('questionnaires')
          .doc('user_info')
          .get();

      Map<String, dynamic> userData = userDoc.data() ?? {};
      String experience = userData['exercise_experience'] ?? 'principiante';
      int initialLevel;

      switch (experience) {
        case 'intermedia':
          initialLevel = 15;
          break;
        case 'avanzada':
          initialLevel = 20;
          break;
        default: // 'principiante' o valor por defecto
          initialLevel = 1;
      }

      // Verificar si el nivel ya fue asignado previamente
      int currentLevel = userData['level'] ?? initialLevel;

      // Si no se ha guardado el nivel, guardarlo en Firestore
      if (userData['level'] == null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('questionnaires')
            .doc('user_info')
            .set({'level': currentLevel}, SetOptions(merge: true));
      }

      return {'username': userData['username'] ?? 'Usuario', 'level': currentLevel};
    } catch (e) {
      return {'username': 'Error', 'level': 0};
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Error al cargar el usuario.'));
          }

          final userData = snapshot.data!;
          final username = userData['username'];
          final level = userData['level'];

          return Center(
            child: Text(
              'Bienvenido, $username\nSu nivel actual es $level',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }
}
