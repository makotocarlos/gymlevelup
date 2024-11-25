import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymlevelup/screen/registro.dart';
import 'package:gymlevelup/screenhome/HomeScreen.dart';
import 'package:gymlevelup/screen/QuestionnaireScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false; // Indicador de carga

  void loginUser(BuildContext context) async {
    setState(() {
      _isLoading = true; // Muestra el indicador de carga
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Obtén el UID del usuario
      String userId = userCredential.user!.uid;

      // Verifica si el cuestionario está completado en Firestore
      DocumentSnapshot questionnaireSnapshot = await FirebaseFirestore.instance
          .collection('users') // Cambiado a 'users' para consistencia
          .doc(userId)
          .collection('questionnaires')
          .doc('user_info') // Cambiado de 'default' a 'user_info'
          .get();

      if (questionnaireSnapshot.exists &&
          questionnaireSnapshot['completed'] == true) {
        // Si el cuestionario está completado, redirigir a HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userId: userId),
          ),
        );
      } else {
        // Si no está completado, redirigir a QuestionnaireScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionnaireScreen(userId: userId),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No se encontró un usuario con ese correo.";
          break;
        case 'wrong-password':
          errorMessage = "Contraseña incorrecta.";
          break;
        case 'invalid-email':
          errorMessage = "El correo electrónico no es válido.";
          break;
        default:
          errorMessage = "Error: ${e.message}";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error inesperado: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Oculta el indicador de carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Iniciar Sesión"),
        backgroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Bienvenido de nuevo",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: emailController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Correo",
                labelStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.black45,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Contraseña",
                labelStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.black45,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 32),
            _isLoading
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
                  )
                : ElevatedButton(
                    onPressed: () => loginUser(context),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.blueAccent, // Color personalizado
                    ),
                    child: Text(
                      "Iniciar Sesión",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text(
                "Crear una cuenta",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}