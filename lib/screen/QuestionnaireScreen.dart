import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymlevelup/screenhome/HomeScreen.dart';

class QuestionnaireScreen extends StatefulWidget {
  final String userId;

  const QuestionnaireScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _username;
  double? _weight;
  String? _exerciseExperience;
  String? _mainGoals;
  bool _isLoading = false;

  final List<String> _experienceOptions = [
    'Principiante',
    'Intermedio',
    'Avanzado',
  ];

  final List<String> _goalOptions = [
    'Perder peso',
    'Ganar músculo',
    'Mantenerse en forma',
  ];

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      // Guardamos los datos en un documento con ID fijo (user_info)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('questionnaires')
          .doc('user_info') // Documento con ID fijo
          .set({
        'username': _username,
        'weight': _weight,
        'exerciseExperience': _exerciseExperience,
        'mainGoals': _mainGoals,
      });

      // Navegamos a la HomeScreen después de guardar los datos
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(userId: widget.userId),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cuestionario'),
        backgroundColor: Colors.black87,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cuestionario de Registro',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nombre de usuario',
                        labelStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.black45,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa un nombre de usuario.';
                        }
                        if (value.length < 3) {
                          return 'El nombre debe tener al menos 3 caracteres.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _username = value!;
                      },
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Peso (kg)',
                        labelStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.black45,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa tu peso.';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ingresa un número válido.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _weight = double.tryParse(value!);
                      },
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Experiencia con ejercicio:',
                      style: TextStyle(color: Colors.white),
                    ),
                    DropdownButtonFormField<String>(
                      items: _experienceOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option, style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        _exerciseExperience = value!;
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecciona tu experiencia.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Selecciona una opción',
                        labelStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.black45,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Objetivos principales:',
                      style: TextStyle(color: Colors.white),
                    ),
                    DropdownButtonFormField<String>(
                      items: _goalOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option, style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        _mainGoals = value!;
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecciona tus objetivos.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Selecciona una opción',
                        labelStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.black45,
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveData,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.blueAccent, // Color personalizado
                        ),
                        child: Text(
                          'Finalizar y Guardar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      backgroundColor: Colors.black,
    );
  }
}
