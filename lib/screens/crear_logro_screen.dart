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
  String? logroId; // Para saber si estamos editando
  bool datosCargados = false;
  String? existingImageUrl;
  bool _isSaving = false;
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

  Future<void> _cargarDatosLogro(String id) async {
    final doc = await FirebaseFirestore.instance.collection('achievements').doc(id).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        nombreController.text = data['name_logro'] ?? '';
        fechaInicioController.text = data['fec_inicio'] ?? '';
        fechaFinController.text = data['fec_fin'] ?? '';
        montoController.text = data['monto'] ?? '';
        existingImageUrl = data['photoUrl'];
        // Puedes guardar la URL de la imagen si quieres mostrarla
      });
    }
  }

  Future<void> _guardarLogro() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Debes iniciar sesión primero')),
        );
        setState(() => _isSaving = false);
        return;
      }

      final nombre = nombreController.text.trim();
      final fechaInicio = fechaInicioController.text.trim();
      final fechaFin = fechaFinController.text.trim();
      final monto = montoController.text.replaceAll(RegExp(r'[^\d]'), '').trim();

      if ([nombre, fechaInicio, fechaFin, monto].any((v) => v.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor completa todos los campos')),
        );
        setState(() => _isSaving = false);
        return;
      }

      try {
        String? imageUrl = await uploadImage(user.uid);
        imageUrl ??= existingImageUrl; // usa la existente si no hay nueva

        if (logroId != null) {
          await FirebaseFirestore.instance.collection('achievements').doc(logroId).update({
            'name_logro': nombre,
            'fec_inicio': fechaInicio,
            'fec_fin': fechaFin,
            'monto': monto,
            'photoUrl': imageUrl ?? FieldValue.delete(),
            'updated_at': Timestamp.now(),
          });

          await mostrarNotificacion(
            '¡Logro Actualizado!',
            'Tu logro "$nombre" ha sido modificado.',
          );

        } else {
          await FirebaseFirestore.instance.collection('achievements').add({
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
        }

        Navigator.pop(context); // Regresa a la pantalla anterior
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      } finally {
        setState(() => _isSaving = false);
      }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (!datosCargados && args != null && args['logroId'] != null) {
      logroId = args['logroId'];
      _cargarDatosLogro(logroId!);
      datosCargados = true;
    }

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
              logroId != null ? l10n.updateAchievement : l10n.createAchievement,
              //l10n.createAchievement,
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
                      ? (existingImageUrl != null
                          ? Image.network(existingImageUrl!, height: 150)
                          : Text('No has seleccionado una imagen'))
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
                          if (_isSaving) return; // Evita múltiples clics
                          await _guardarLogro();
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
                    if (logroId != null) 
                      SizedBox(height: 16),
                      if (logroId != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _mostrarModalAbonos(context , logroId!);
                            },
                            icon: Icon(Icons.visibility),
                            label: Text(l10n.viewPays),
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
                          ),
                        ),
                    
                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Usamos Stack para posicionar múltiples widgets flotantes
      floatingActionButton: Stack(
        children: [
          // Botón de la casita flotante a la izquierda
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 35.0,
                bottom: 20.0,
              ), // Ajusta el padding según necesites
              child: FloatingActionButton(
                heroTag: 'homeBtn', // Es importante para múltiples FABs
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
                backgroundColor: Colors.teal,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.home,
                  color: Colors.white,
                ), // Icono de la casita
              ),
            ),
          ),
          // Menú Circular (se mantiene igual, a la derecha)
          CircularMenu(
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
        ],
      ),
    );
  }
}

void _mostrarModalAbonos(BuildContext context, String logroId) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('agregados')
            .where('achievementId', isEqualTo: logroId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(child: Text('No hay abonos registrados para este logro')),
            );
          }

          final abonos = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: abonos.length,
              itemBuilder: (context, index) {
                final abono = abonos[index].data() as Map<String, dynamic>;
                final monto = abono['valor_agregado'] ?? '';
                final fecha = abono['fecha'] ?? '';
                final docId = abonos[index].id;

                return ListTile(
                  leading: Icon(Icons.attach_money, color: Colors.green),
                  title: Text('Monto: \$${monto.toString()}'),
                  subtitle: Text('Fecha: $fecha'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Eliminar este abono'),
                          content: Text('¿Estás seguro de que deseas eliminar este abono?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await FirebaseFirestore.instance
                            .collection('agregados')
                            .doc(docId)
                            .delete();

                        Navigator.of(context).pop(); // Cierra el modal
                        _mostrarModalAbonos(context, logroId); // Lo vuelve a abrir actualizado
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      );
    },
  );
}
