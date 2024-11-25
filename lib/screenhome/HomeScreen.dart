import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymlevelup/screenhome/RoutineScreen.dart';
import 'package:gymlevelup/screen/login.dart';
import 'package:gymlevelup/screenhome/HistoryScreen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = 'Usuario';
  int level = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('questionnaires')
          .doc('user_info')
          .get();

      Map<String, dynamic> userData = userDoc.data() ?? {};
      setState(() {
        username = userData['username'] ?? 'Usuario';
        level = userData['level'] ?? 1;
      });
    } catch (e) {
      setState(() {
        username = 'Error';
        level = 0;
      });
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> _fetchmainGoals() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('questionnaires')
          .doc('user_info')
          .get();

      Map<String, dynamic> userData = userDoc.data() ?? {};
      String mainGoals = userData['mainGoals'] ?? 'No definida';

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoutineScreen(userId: widget.userId, mainGoals: mainGoals),
        ),
      );

      if (result != null) {
        _fetchUserData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener la meta principal')),
      );
    }
  }

  void _goToHistoryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
            color: Colors.white,
          ),
        ],
      ),
      backgroundColor: Color(0xFF121212), // Fondo oscuro elegante
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bienvenido, $username',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Nivel actual: $level',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _fetchmainGoals,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Empezar rutina',
                  style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _goToHistoryScreen,
                style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.white),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Ver historial',
                  style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
