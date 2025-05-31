import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Para notificaciones
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:savvy/l10n/app_localizations.dart'; // este es correcto
import 'package:savvy/main.dart'; // Aquí asumo que tienes flutterLocalNotificationsPlugin definido

class crear_logro extends StatefulWidget {
  @override
  _CrearLogroState createState() => _CrearLogroState();
}

class _CrearLogroState extends State<crear_logro> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController fechaInicioController = TextEditingController();
  final TextEditingController fechaFinController = TextEditingController();
  final TextEditingController montoController = TextEditingController();

  XFile? _imageFile;

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    fechaInicioController.dispose();
    fechaFinController.dispose();
    montoController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<String?> uploadImage(String userId) async {
    if (_imageFile == null) return null;
    final storageRef = FirebaseStorage.instance.ref().child(
      'user_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final uploadTask = storageRef.putFile(File(_imageFile!.path));
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> mostrarNotificacion(String titulo, String cuerpo) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'canal_logros', // ID del canal
          'Logros', // Nombre visible del canal
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails notificacion = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0, // Puedes usar un ID fijo o dinámico aquí
      titulo,
      cuerpo,
      notificacion,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(6, 145, 154, 1),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.createAchievement,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _imageFile == null
                        ? Text('No has seleccionado una imagen')
                        : Image.file(File(_imageFile!.path), height: 150),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: pickImage,
                      child: Text('Seleccionar imagen'),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: nombreController,
                      decoration: InputDecoration(
                        labelText: l10n.achievementName,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: () => _pickDate(fechaInicioController),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: fechaInicioController,
                          decoration: InputDecoration(
                            labelText: l10n.startDate,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: () => _pickDate(fechaFinController),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: fechaFinController,
                          decoration: InputDecoration(
                            labelText: l10n.endDate,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: montoController,
                      decoration: InputDecoration(
                        labelText: l10n.amount,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Debes iniciar sesión primero'),
                              ),
                            );
                            return;
                          }

                          final nombre = nombreController.text.trim();
                          final fechaInicio = fechaInicioController.text.trim();
                          final fechaFin = fechaFinController.text.trim();
                          final monto =
                              montoController.text
                                  .replaceAll(RegExp(r'[^\d]'), '')
                                  .trim();

                          if ([
                            nombre,
                            fechaInicio,
                            fechaFin,
                            monto,
                          ].any((v) => v.isEmpty)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Por favor completa todos los campos',
                                ),
                              ),
                            );
                            return;
                          }

                          String? imageUrl = await uploadImage(user.uid);

                          await FirebaseFirestore.instance
                              .collection('achievements')
                              .add({
                                'userId': user.uid,
                                'name_logro': nombre,
                                'fec_inicio': fechaInicio,
                                'fec_fin': fechaFin,
                                'monto': monto,
                                'photoUrl': imageUrl,
                                'created_at': Timestamp.now(),
                              });

                          await mostrarNotificacion(
                            '¡Logro Creado!',
                            'Tu logro "$nombre" ha sido guardado. ¡Sigue adelante!',
                          );

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(6, 145, 154, 1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                        child: Text(l10n.save),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.attach_money),
              onPressed: () {
                Navigator.pushNamed(context, '/informes');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: CircularMenu(
        alignment: Alignment.bottomRight,
        toggleButtonColor: Colors.teal,
        toggleButtonIconColor: Colors.white,
        items: [
          CircularMenuItem(
            icon: Icons.settings,
            color: Colors.teal,
            onTap: () {
              Navigator.pushNamed(context, '/configuracion');
            },
          ),
          CircularMenuItem(
            icon: Icons.bar_chart,
            color: Colors.teal,
            onTap: () {
              Navigator.pushNamed(context, '/informes');
            },
          ),
          CircularMenuItem(
            icon: Icons.emoji_events,
            color: Colors.teal,
            onTap: () {
              Navigator.pushNamed(context, '/logros');
            },
          ),
        ],
      ),
    );
  }
}
