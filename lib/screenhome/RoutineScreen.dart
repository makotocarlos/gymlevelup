import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoutineScreen extends StatefulWidget {
  final String userId;
  final String mainGoals;

  const RoutineScreen({Key? key, required this.userId, required this.mainGoals}) : super(key: key);

  @override
  _RoutineScreenState createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  Map<String, bool> _completionStatus = {};
  bool _isLoading = false;

  Future<Map<String, dynamic>> _fetchRoutineData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('questionnaires')
          .doc('user_info')
          .get();

      final userData = userDoc.data() ?? {};
      String mainGoals = userData['mainGoals'] ?? '';

      Map<String, List<String>> routines = {
        'Perder peso': [
          'Cardio HIIT: 20 min (correr/ciclo).',
          'Fuerza: 3 ejercicios (sentadillas, planchas, push-ups).',
          'Descanso activo: 1 min entre sets.',
          'Dieta balanceada: bajo carbohidratos, alta proteína.',
          'Hidratación: 2-3 litros.'
        ],
        'Ganar músculo': [
          'Fuerza: Peso muerto, press banca, dominadas.',
          'Repeticiones: 8-12 por set (3-4 sets).',
          'Cardio ligero: 10-15 min.',
          'Dieta alta en proteína y calorías controladas.',
          'Descanso: 7-8 horas diarias.'
        ],
        'Mantenerse en forma': [
          'Cardio moderado: 30 min (correr, nadar).',
          'Fuerza ligera: 2-3 sets de cuerpo completo.',
          'Flexibilidad: Yoga o estiramientos, 10 min.',
          'Dieta equilibrada: frutas, verduras, proteínas.',
          'Hidratación adecuada: 2-3 litros diarios.'
        ],
      };

      if (!routines.containsKey(mainGoals) || mainGoals.isEmpty) {
        throw Exception('Rutina no encontrada para el objetivo: $mainGoals');
      }

      return {
        'username': userData['username'] ?? 'Usuario',
        'routine': routines[mainGoals]!,
      };
    } catch (e) {
      return {
        'username': 'Error',
        'routine': ['Error al cargar la rutina.']
      };
    }
  }

  Future<void> _completeActivity(String activity) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.userId);

      await userDoc.collection('historial').add({
        'activity': activity,
        'timestamp': FieldValue.serverTimestamp(),
        'goal': widget.mainGoals,
      });

      await userDoc.collection('completados').add({
        'activity': activity,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await userDoc
          .collection('questionnaires')
          .doc('user_info')
          .update({'level': FieldValue.increment(1)});

      setState(() {
        _completionStatus[activity] = true;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Has completado: $activity')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al completar la actividad: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rutina')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchRoutineData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Error al cargar los datos.'));
          }

          final userData = snapshot.data!;
          final username = userData['username'];
          final routine = userData['routine'] as List<String>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Hola $username, esta es tu rutina:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: routine.length,
                    itemBuilder: (context, index) {
                      final activity = routine[index];
                      final isCompleted = _completionStatus[activity] ?? false;

                      return ListTile(
                        title: Text(
                          activity,
                          style: TextStyle(
                            fontSize: 16,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: isCompleted || _isLoading
                              ? null
                              : () => _completeActivity(activity),
                          child: Text(isCompleted ? 'Completada' : 'Completar'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
