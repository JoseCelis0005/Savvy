import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class crear_logro extends StatefulWidget {
  @override
  _CrearLogroState createState() => _CrearLogroState();
}

class _CrearLogroState extends State<crear_logro> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController fechaInicioController = TextEditingController();
  final TextEditingController fechaFinController = TextEditingController();
  final TextEditingController montoController = TextEditingController();

  @override
  void dispose() {
    nombreController.dispose();
    fechaInicioController.dispose();
    fechaFinController.dispose();
    montoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Obtén la instancia

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(6, 145, 154, 1),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.createAchievement, // Usa la clave traducida
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
                    TextFormField(
                      controller: nombreController,
                      decoration: InputDecoration(
                        labelText:
                            l10n.achievementName, // Usa la clave traducida
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: fechaInicioController,
                      decoration: InputDecoration(
                        labelText: l10n.startDate, // Usa la clave traducida
                        border: OutlineInputBorder(),
                        hintText: 'DD/MM/AAAA', // No se traduce, es un formato
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: fechaFinController,
                      decoration: InputDecoration(
                        labelText: l10n.endDate, // Usa la clave traducida
                        border: OutlineInputBorder(),
                        hintText: 'DD/MM/AAAA', // No se traduce, es un formato
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: montoController,
                      decoration: InputDecoration(
                        labelText: l10n.amount, // Usa la clave traducida
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          final nombre = nombreController.text;
                          final fechaInicio = fechaInicioController.text;
                          final fechaFin = fechaFinController.text;
                          final monto = montoController.text;

                          await FirebaseFirestore.instance
                              .collection('achievements')
                              .add({
                                'name_logro': nombre,
                                'fec_inicio': fechaInicio,
                                'fec_fin': fechaFin,
                                'monto': monto,
                                'created_at': Timestamp.now(),
                              });

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
                        child: Text(l10n.save), // Usa la clave traducida
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
