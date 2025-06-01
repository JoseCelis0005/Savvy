import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:savvy/main.dart'; // Asegúrate de que esta importación sea correcta si main.dart contiene algo relevante.
//import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Si usas localizaciones
import 'package:savvy/l10n/app_localizations.dart'; // este es correcto
import 'package:provider/provider.dart';
import 'package:savvy/screens/configuracion/currency_provider.dart'; // Importa tu CurrencyProvider
import 'package:fl_chart/fl_chart.dart';

class HelloWorldScreen extends StatefulWidget {
  @override
  _HelloWorldScreenState createState() => _HelloWorldScreenState();
}

class _HelloWorldScreenState extends State<HelloWorldScreen> {
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

  // MODIFICADO: _formatCurrency ahora usa el CurrencyProvider para la conversión y el símbolo
  String _formatCurrency(double value, CurrencyProvider currencyProvider) {
    // Convierte el valor a la moneda de visualización seleccionada
    final convertedValue = currencyProvider.convertAmount(value);
    final currencySymbol = currencyProvider.getCurrencySymbol();

    final formatter = NumberFormat.currency(
      locale:
          'es_CO', // Ajusta el locale si necesitas un formato de número diferente
      symbol: currencySymbol,
      // Muestra 2 decimales para USD, 0 para COP, o según tu preferencia.
      decimalDigits: currencyProvider.selectedDisplayCurrency == 'USD' ? 2 : 0,
    );
    return formatter.format(convertedValue);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Accede al CurrencyProvider para obtener la moneda seleccionada y métodos de conversión
    final currencyProvider = Provider.of<CurrencyProvider>(context);

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
        // ELIMINADO: La propiedad 'leading' del AppBar para el botón de inicio
        // leading: IconButton(
        //   icon: const Icon(Icons.home, color: Colors.white),
        //   onPressed: () {
        //     Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        //   },
        // ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            //_UserInfoSection(userEmail: userEmail),

            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final avatarUrl = data['avatarUrl'] ?? '';

                return Column(
                  children: <Widget>[
                    _UserInfoSection(
                      userEmail: user.email ?? '',
                      avatarUrl: avatarUrl,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: 300,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('agregados')
                    .where('userId', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final docs = snapshot.data!.docs;

                  // Map para agrupar por mes
                  final Map<String, double> montosPorMes = {};

                  double totalMensual = 0;

                  for (var doc in docs) {
                    try {
                      final valorStr = doc['valor_agregado'].toString();
                      final fechaStr = doc['fecha'].toString();

                      final fecha = DateTime.parse(
                        fechaStr.split('/').reversed.join('-'),
                      );

                      final monto = double.tryParse(valorStr) ?? 0;

                      final claveMes = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}';

                      montosPorMes[claveMes] = (montosPorMes[claveMes] ?? 0) + monto;
                      totalMensual += monto;
                    } catch (e) {
                      // Ignorar errores en parseo
                      continue;
                    }
                  }

                  // Convertimos a lista de mapas para enviarla al widget Recuadro
                  final datosMensuales = montosPorMes.entries.map((entry) {
                    final partes = entry.key.split('-'); // ['2025', '03']
                    final nombreMes = _getNombreMes(int.parse(partes[1]));
                    return {
                      'mes': nombreMes,
                      'monto': entry.value,
                    };
                  }).toList();

                  // Ordenar por mes (opcional)
                  datosMensuales.sort((a, b) =>
                      _ordenMes(a['mes'] as String).compareTo(_ordenMes(b['mes'] as String)));

                  return Recuadro(
                    titulo: 'Ahorros Totales',
                    monto: _formatCurrency(totalMensual, currencyProvider),
                    porcentaje: '',
                    datosMensuales: datosMensuales,
                  );
                },
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: 300,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
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

                  // **Aquí agrupamos los montos por mes según achievements y created_at**
                  final Map<String, double> montosPorMesAchievements = {};
                  for (var doc in docsObjetivos) {
                    try {
                      final monto = double.tryParse(doc['monto'].toString()) ?? 0;
                      final Timestamp ts = doc['created_at'];
                      final DateTime fecha = ts.toDate();

                      final claveMes =
                          '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}';

                      montosPorMesAchievements[claveMes] =
                          (montosPorMesAchievements[claveMes] ?? 0) + monto;
                    } catch (e) {
                      continue;
                    }
                  }

                  final datosMensuales = montosPorMesAchievements.entries.map((entry) {
                    final partes = entry.key.split('-');
                    final nombreMes = _getNombreMes(int.parse(partes[1]));
                    return {
                      'mes': nombreMes,
                      'monto': entry.value,
                    };
                  }).toList();

                  datosMensuales.sort((a, b) =>
                      _ordenMes(a['mes'] as String).compareTo(_ordenMes(b['mes'] as String)));

                  // Ahora viene el StreamBuilder para agregados para calcular totalAgregado y porcentaje

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('agregados')
                        .where('userId', isEqualTo: user.uid)
                        .snapshots(),
                    builder: (context, snapshotAgregados) {
                      if (!snapshotAgregados.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final docsAgregados = snapshotAgregados.data!.docs;

                      double totalAgregado = 0;

                      for (var doc in docsAgregados) {
                        try {
                          final valor = doc['valor_agregado'];
                          final valorDouble = double.tryParse(valor.toString()) ?? 0;
                          totalAgregado += valorDouble;
                        } catch (e) {
                          continue;
                        }
                      }

                      double porcentaje = totalObjetivo > 0
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
                            titulo: 'Meta de Ahorro',
                            monto: _formatCurrency(totalObjetivo, currencyProvider),
                            porcentaje: '${(porcentaje * 100).toStringAsFixed(1)}%',
                            datosMensuales: datosMensuales, // datos de achievements agrupados por mes
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
            /*SizedBox(
              width: 300,
              child: Recuadro(
                titulo: 'Gastos',
                // MODIFICADO: Pasa el valor hardcodeado (asumido en COP) y el currencyProvider
                monto: _formatCurrency(1234.56, currencyProvider),
                porcentaje: '+12.34%',
              ),
            ),*/
          ],
        ),
      ),
      // ELIMINADO: bottomNavigationBar

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
class Recuadro extends StatefulWidget {
  final String titulo;
  final String monto;
  final String porcentaje;

  // Lista de montos mensuales: [{'mes': 'Enero', 'monto': 200}, ...]
  final List<Map<String, dynamic>> datosMensuales;

  const Recuadro({
    Key? key,
    required this.titulo,
    required this.monto,
    required this.porcentaje,
    required this.datosMensuales,
  }) : super(key: key);

  @override
  State<Recuadro> createState() => _RecuadroState();
}

class _RecuadroState extends State<Recuadro> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 600,
          decoration: BoxDecoration(
            color: Colors.teal.shade200,
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              // Contenido principal
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.titulo,
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    widget.monto,
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.porcentaje.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            widget.porcentaje,
                            style: const TextStyle(fontSize: 12.0, color: Colors.white),
                          ),
                        )
                      else
                        const SizedBox(),

                      const SizedBox(width: 8.0),

                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _expandido = !_expandido;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                        ),
                        icon: Icon(
                          _expandido ? Icons.expand_less : Icons.expand_more,
                          size: 14,
                        ),
                        label: Text(
                          widget.datosMensuales.isNotEmpty
                              ? _getUltimaFecha(widget.datosMensuales)
                              : 'Ver gráfica',
                          style: const TextStyle(fontSize: 12.0, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // Gráfica expandida
        if (_expandido)
          Container(
            width: 600,
            height: 200,
            margin: EdgeInsets.only(top: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.teal.shade200),
              borderRadius: BorderRadius.circular(10),
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(widget.datosMensuales),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final meses = _getMesesCortos(widget.datosMensuales);
                        if (value.toInt() < meses.length) {
                          return Text(meses[value.toInt()]);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: widget.datosMensuales.asMap().entries.map((entry) {
                  final index = entry.key;
                  final monto = (entry.value['monto'] as num).toDouble();
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: monto,
                        color: Colors.teal,
                        width: 18,
                        borderRadius: BorderRadius.circular(4),
                      )
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  double _getMaxY(List<Map<String, dynamic>> datos) {
    final maxMonto = datos.map((e) => (e['monto'] as num).toDouble()).fold(0.0, (a, b) => a > b ? a : b);
    return maxMonto + (maxMonto * 0.2); // margen arriba
  }

  List<String> _getMesesCortos(List<Map<String, dynamic>> datos) {
    return datos.map((e) => e['mes'].toString().substring(0, 3)).toList();
  }

  String _getUltimaFecha(List<Map<String, dynamic>> datos) {
    if (datos.isEmpty) return '';
    final ultimoMes = datos.last['mes'].toString();
    return ultimoMes;
  }
}

String _getNombreMes(int mes) {
  const meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];
  return meses[mes - 1];
}

// Devuelve el orden correcto de un mes para poder ordenar
int _ordenMes(String nombreMes) {
  const meses = {
    'Enero': 1,
    'Febrero': 2,
    'Marzo': 3,
    'Abril': 4,
    'Mayo': 5,
    'Junio': 6,
    'Julio': 7,
    'Agosto': 8,
    'Septiembre': 9,
    'Octubre': 10,
    'Noviembre': 11,
    'Diciembre': 12
  };
  return meses[nombreMes] ?? 0;
}


// Clase _UserInfoSection definida sin const
class _UserInfoSection extends StatelessWidget {
  final String userEmail;
  final String? avatarUrl; // Puede ser null

  const _UserInfoSection({
    Key? key,
    required this.userEmail,
    this.avatarUrl,
  }) : super(key: key);

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
                backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                    ? NetworkImage(avatarUrl!)
                    : const AssetImage('assets/images/informe.png') as ImageProvider,
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
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              Navigator.pushNamed(context, '/config-usuario');
            },
          ),
          // Botón para ir a la configuración del usuario
        ],
      ),
    );
  }
}
