import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Importante!

class LogrosScreen extends StatelessWidget {
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
              l10n.achievements, // Usa la clave traducida
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
            // Barra de Búsqueda
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.search, // Usa la clave traducida
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),

            // Lista de Logros
            Expanded(
              child: ListView(
                children: [
                  StreamBuilder(
                    stream:
                        FirebaseFirestore.instance
                            .collection('achievements')
                            .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text('No achievements found.'),
                        ); // No necesitas traducir esto, es un mensaje de error técnico
                      }
                      return Column(
                        children:
                            snapshot.data!.docs.map((doc) {
                              return Column(
                                children: [
                                  LogroItem(
                                    imagen: 'assets/images/logro.png',
                                    titulo:
                                        (doc['name_logro'] is Map)
                                            ? doc['name_logro']!['es'] ??
                                                'Sin Titulo'
                                            : doc['name_logro'] ?? 'Sin Titulo',
                                    monto: _formatCurrency(doc['monto'] ?? '0'),
                                  ),
                                  SizedBox(height: 12.0),
                                ],
                              );
                            }).toList(),
                      );
                    },
                  ),
                  SizedBox(height: 12.0),
                  LogroItem(
                    imagen: 'assets/images/logro.png',
                    titulo: l10n.newAchievement, // Usa la clave traducida
                    monto: '',
                    isNew: true,
                  ),
                ],
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

      //Circular menú
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

class LogroItem extends StatelessWidget {
  final String imagen;
  final String titulo;
  final String monto;
  final bool isNew;

  const LogroItem({
    Key? key,
    required this.imagen,
    required this.titulo,
    required this.monto,
    this.isNew = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          isNew
              ? () {
                Navigator.pushNamed(context, '/crear-logro');
              }
              : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Image.asset(imagen, width: 80.0, height: 80.0, fit: BoxFit.cover),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isNew)
                      Text(
                        monto,
                        style: TextStyle(fontSize: 16.0, color: Colors.green),
                      ),
                  ],
                ),
              ),
              if (isNew) Icon(Icons.add_circle, color: Colors.teal, size: 32.0),
            ],
          ),
        ),
      ),
    );
  }
}

String _capitalizeFirstLetter(String input) {
  if (input.isEmpty) return '';
  return input[0].toUpperCase() + input.substring(1);
}

String _formatCurrency(String amount) {
  try {
    final number = double.parse(amount);
    final formatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    return formatter.format(number);
  } catch (e) {
    return '\$0';
  }
}
