import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryScreen extends StatelessWidget {
  final String userId;

  const HistoryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de actividades'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[900],
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('completados')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No hay actividades completadas.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final completedActivities = snapshot.data!.docs;

          return ListView.builder(
            itemCount: completedActivities.length,
            itemBuilder: (context, index) {
              final activity = completedActivities[index].data();
              final activityName = activity['activity'] ?? 'Actividad desconocida';
              final timestamp = (activity['timestamp'] as Timestamp?)?.toDate();

              return ListTile(
                title: Text(
                  activityName,
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  timestamp != null
                      ? 'Completada el ${timestamp.toLocal()}'
                      : 'Fecha desconocida',
                  style: TextStyle(color: Colors.white70),
                ),
                tileColor: Colors.grey[850],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              );
            },
          );
        },
      ),
    );
  }
}
