import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:savvy/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HelloWorldScreen extends StatefulWidget {
  @override
  _HelloWorldScreenState createState() => _HelloWorldScreenState();
}

class _HelloWorldScreenState extends State<HelloWorldScreen> {
  int _selectedIndex = 0;
  bool _mostroDialogo = false;
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userEmail = user.email ?? 'Usuario';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mostrarDialogoBienvenida();
    });
  }

  void _mostrarDialogoBienvenida() {
    if (_mostroDialogo) return;
    _mostroDialogo = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¡Bienvenido a Savvy! 🎉'),
          content: Text(
            '¡Qué alegría tenerte aquí, $userEmail! Prepárate para transformar tus finanzas y hacer realidad tus sueños.',
          ),
          actions: [
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '\$' + formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Inicio')),
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(6, 145, 154, 1),
        centerTitle: true,
        title: Text(
          'Inicio',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Aquí quita el const para que no de error
            _UserInfoSection(userEmail: userEmail),
            const SizedBox(height: 16),
            SizedBox(
              width: 300,
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('agregados')
                        .where('userId', isEqualTo: user.uid)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final docs = snapshot.data!.docs;
                  final now = DateTime.now();
                  final currentMonth = now.month;
                  final currentYear = now.year;

                  double totalMensual = 0;

                  for (var doc in docs) {
                    final fechaStr = doc['fecha'];
                    final valorStr = doc['valor_agregado'];

                    try {
                      final fecha = DateTime.parse(
                        fechaStr.split('/').reversed.join('-'),
                      );

                      if (fecha.month == currentMonth &&
                          fecha.year == currentYear) {
                        totalMensual +=
                            double.tryParse(valorStr.toString()) ?? 0;
                      }
                    } catch (e) {
                      continue;
                    }
                  }

                  return Recuadro(
                    titulo: 'Ahorros Mensuales',
                    monto: _formatCurrency(totalMensual),
                    porcentaje: '',
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('achievements')
                        .where('userId', isEqualTo: user.uid)
                        .snapshots(),
                builder: (context, snapshotObjetivos) {
                  if (!snapshotObjetivos.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final docsObjetivos = snapshotObjetivos.data!.docs;

                  double totalObjetivo = docsObjetivos.fold(0, (sum, doc) {
                    final monto = doc['monto'];
                    return sum + (double.tryParse(monto.toString()) ?? 0);
                  });

                  return StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('agregados')
                            .where('userId', isEqualTo: user.uid)
                            .snapshots(),
                    builder: (context, snapshotAgregados) {
                      if (!snapshotAgregados.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final docsAgregados = snapshotAgregados.data!.docs;
                      final now = DateTime.now();
                      final currentMonth = now.month;
                      final currentYear = now.year;

                      double totalAgregado = 0;

                      for (var doc in docsAgregados) {
                        Timestamp ts = doc['created_at'];
                        DateTime fecha = ts.toDate();

                        if (fecha.month == currentMonth &&
                            fecha.year == currentYear) {
                          final valor = doc['valor_agregado'];
                          totalAgregado +=
                              double.tryParse(valor.toString()) ?? 0;
                        }
                      }

                      double porcentaje =
                          totalObjetivo > 0
                              ? (totalAgregado / totalObjetivo).clamp(0, 1)
                              : 0;

                      Color color;
                      if (porcentaje <= 0.3) {
                        color = Colors.red;
                      } else if (porcentaje <= 0.6) {
                        color = Colors.yellow.shade700;
                      } else {
                        color = Colors.green;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Recuadro(
                            titulo: 'Ahorros Mensuales',
                            monto: _formatCurrency(totalObjetivo),
                            porcentaje:
                                '${(porcentaje * 100).toStringAsFixed(1)}%',
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: porcentaje,
                            backgroundColor: Colors.grey.shade300,
                            color: color,
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: Recuadro(
                titulo: 'Gastos',
                monto: '\$1,234.56',
                porcentaje: '+12.34%',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.arrow_back), label: 'Atrás'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Salir'),
        ],
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

// Clase _UserInfoSection definida sin const
class _UserInfoSection extends StatelessWidget {
  final String userEmail;

  _UserInfoSection({Key? key, required this.userEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/informe.png'),
                radius: 25,
              ),
              const SizedBox(width: 10),
              Text(
                userEmail,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
    );
  }
}

class Recuadro extends StatelessWidget {
  final String titulo;
  final String monto;
  final String porcentaje;

  const Recuadro({
    Key? key,
    required this.titulo,
    required this.monto,
    required this.porcentaje,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      decoration: BoxDecoration(
        color: Colors.teal.shade200,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8.0),
          Text(
            monto,
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              porcentaje,
              style: TextStyle(fontSize: 12.0, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
