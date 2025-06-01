import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:savvy/l10n/app_localizations.dart'; // este es correcto
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // Importar Provider
import 'package:savvy/screens/configuracion/currency_provider.dart'; // Importar tu CurrencyProvider
import 'package:intl/intl.dart'; // Importar para NumberFormat

//informes
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InformesScreen extends StatelessWidget {
  const InformesScreen({Key? key}) : super(key: key);

  // Helper para formatear la moneda (similar al de home_screen)
  String _formatCurrency(double value, CurrencyProvider currencyProvider) {
    final convertedValue = currencyProvider.convertAmount(value);
    final currencySymbol = currencyProvider.getCurrencySymbol();
    //final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final formatter = NumberFormat.currency(
      locale:
          'es_CO', // Ajusta el locale si necesitas un formato de número diferente
      symbol: currencySymbol, // Usa el símbolo personalizado: COP o US
      decimalDigits:
          currencyProvider.selectedDisplayCurrency == 'USD'
              ? 2
              : 0, // 2 decimales para USD, 0 para COP
    );
    return formatter.format(convertedValue);
  }

  @override
  Widget build(BuildContext context) {
    
    final l10n = AppLocalizations.of(context);

    if (l10n == null) {
      return const Center(child: Text('Error: Localizations not found!'));
    }

    // Obtener el usuario actualmente autenticado
    final user = FirebaseAuth.instance.currentUser;
    final userName =
        user?.email ??
        l10n.userNamePlaceholder; // Usar el email o un placeholder

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Inicio')),
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    // Accede al CurrencyProvider aquí
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    // Valores de ejemplo para los montos (en tu moneda base, COP)
    final double weeklyAmountCOP = 150000.0;
    final double monthlyAmountCOP = 600000.0;
    final double yearlyAmountCOP = 7200000.0;

    Future<Map<String, dynamic>> obtenerSumaYPorcentajeTiempo(String userId) async {
      try {
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(Duration(days: 6));

        final currentMonth = now.month;
        final currentYear = now.year;

        final querySnapshot = await FirebaseFirestore.instance
            .collection('agregados')
            .where('userId', isEqualTo: userId)
            .get();

        double totalGeneral = 0;
        double totalSemanal = 0;
        double totalMensual = 0;
        double totalAnual = 0;

        for (var doc in querySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;

          // Validar y convertir valor
          final valorRaw = data['valor_agregado'];
          double valor;
          if (valorRaw is int) {
            valor = valorRaw.toDouble();
          } else if (valorRaw is double) {
            valor = valorRaw;
          } else if (valorRaw is String) {
            valor = double.tryParse(valorRaw) ?? 0;
          } else {
            continue;
          }

          totalGeneral += valor;

          // Parsear fecha: "30/05/2025"
          final fechaStr = data['fecha'];
          if (fechaStr is! String) continue;

          try {
            final parts = fechaStr.split('/');
            if (parts.length != 3) continue;
            final fecha = DateTime(
              int.parse(parts[2]), // año
              int.parse(parts[1]), // mes
              int.parse(parts[0]), // día
            );

            // Semana actual
            if (fecha.isAfter(startOfWeek.subtract(Duration(seconds: 1))) &&
                fecha.isBefore(endOfWeek.add(Duration(days: 1)))) {
              totalSemanal += valor;
            }

            // Mes actual
            if (fecha.month == currentMonth && fecha.year == currentYear) {
              totalMensual += valor;
            }

            // Año actual
            if (fecha.year == currentYear) {
              totalAnual += valor;
            }
          } catch (_) {
            continue;
          }
        }

        // Calcular porcentajes
        double porcentajeSemanal = totalGeneral > 0 ? (totalSemanal / totalGeneral) * 100 : 0;
        double porcentajeMensual = totalGeneral > 0 ? (totalMensual / totalGeneral) * 100 : 0;
        double porcentajeAnual = totalGeneral > 0 ? (totalAnual / totalGeneral) * 100 : 0;

        return {
          'totalSemanal': totalSemanal,
          'porcentajeSemanal': porcentajeSemanal,
          'totalMensual': totalMensual,
          'porcentajeMensual': porcentajeMensual,
          'totalAnual': totalAnual,
          'porcentajeAnual': porcentajeAnual,
        };
      } catch (e) {
        print('Error al obtener totales y porcentajes: $e');
        return {
          'totalSemanal': 0.0,
          'porcentajeSemanal': 0.0,
          'totalMensual': 0.0,
          'porcentajeMensual': 0.0,
          'totalAnual': 0.0,
          'porcentajeAnual': 0.0,
        };
      }
    }

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reports),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
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
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _generarInformePDF,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                  ),
                  child: const Text(
                    'Generar Informe',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            //const _SearchBar(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  FutureBuilder<Map<String, dynamic>>(
                    future: obtenerSumaYPorcentajeTiempo(userId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();

                      final data = snapshot.data!;
                      final semanal = data['totalSemanal'];
                      final mensual = data['totalMensual'];
                      final anual = data['totalAnual'];

                      final pSemanal = data['porcentajeSemanal'];
                      final pMensual = data['porcentajeMensual'];
                      final pAnual = data['porcentajeAnual'];

                      return Column(
                        children: [
                          _ReportCard(
                            title: l10n.weekly,
                            amountValue: semanal,
                            percentage: '${pSemanal.toStringAsFixed(1)}%',
                            currencyProvider: currencyProvider,
                            imagePath: 'assets/images/informe.png',
                          ),
                          const SizedBox(height: 16),
                          _ReportCard(
                            title: l10n.monthly,
                            amountValue: mensual,
                            percentage: '${pMensual.toStringAsFixed(1)}%',
                            currencyProvider: currencyProvider,
                            imagePath: 'assets/images/informe.png',
                          ),
                          const SizedBox(height: 16),
                          _ReportCard(
                            title: l10n.yearly,
                            amountValue: anual,
                            percentage: '${pAnual.toStringAsFixed(1)}%',
                            currencyProvider: currencyProvider,
                            imagePath: 'assets/images/informe.png',
                          ),
                        ],
                      );
                    },
                  ),
                ],
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: l10n.search,
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final double amountValue; // CAMBIO: Ahora recibe un double para el monto base
  final CurrencyProvider currencyProvider; // CAMBIO: Recibe el CurrencyProvider
  final String percentage;
  final String imagePath;

  const _ReportCard({
    Key? key,
    required this.title,
    required this.amountValue, // CAMBIO
    required this.currencyProvider, // CAMBIO
    required this.percentage,
    required this.imagePath,
  }) : super(key: key);

  // Helper interno para formatear el monto
  String _formatAmount(double value, CurrencyProvider provider) {
    final convertedValue = provider.convertAmount(value);
    final currencySymbol = provider.getCurrencySymbol();
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: currencySymbol,
      decimalDigits: provider.selectedDisplayCurrency == 'USD' ? 2 : 0,
    );
    return formatter.format(convertedValue);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  // Usar el nuevo método _formatAmount
                  _formatAmount(amountValue, currencyProvider), // CAMBIO
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  percentage,
                  style: const TextStyle(fontSize: 14, color: Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Image.asset(imagePath, width: 120, height: 90, fit: BoxFit.cover),
        ],
      ),
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.dollarSign),
            onPressed: () {
              // Si ya estás en /informes, no necesitas navegar de nuevo
              // Puedes usar Navigator.pop() para volver al home si esa es la intención.
              // O simplemente no hacer nada si ya estás aquí.
            },
          ),
        ],
      ),
    );
  }
}

Future<void> _generarInformePDF() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final pdf = pw.Document();
  final dateFormatter = DateFormat('dd/MM/yyyy');
  final timeFormatter = DateFormat('HH:mm');
  final stringDateFormat = DateFormat('dd/MM/yyyy');

  double totalMontos = 0;
  double totalAbonado = 0;

  final archievementsSnapshot = await FirebaseFirestore.instance
      .collection('achievements')
      .where('userId', isEqualTo: user.uid)
      .get();

  List<pw.Widget> contenidoPDF = [
    pw.Text('Informe de Logros', style: pw.TextStyle(fontSize: 24)),
    pw.SizedBox(height: 20),
  ];

  for (var logro in archievementsSnapshot.docs) {
    contenidoPDF.addAll([
      pw.Divider(),
      pw.Text('Nombre: ${logro['name_logro']}',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      pw.Text('Monto objetivo: \$${logro['monto']}'),
      pw.Text(
        'Fecha inicio: ${_parseSafeDate(logro['fec_inicio'], stringDateFormat)}',
      ),
      pw.Text(
        'Fecha fin: ${_parseSafeDate(logro['fec_fin'], stringDateFormat)}',
      ),
      pw.Text('Creado: ${dateFormatter.format(_parseTimestamp(logro['created_at']))}'),
      pw.SizedBox(height: 8),
      pw.Text('Abonos:', style: pw.TextStyle(decoration: pw.TextDecoration.underline)),
    ]);

    // Obtener y construir sección de abonos (ya no usamos await dentro del build)
    final abonosWidget = await _buildAbonosSection(
      logro.id,
      logro['monto'],
      user.uid,
      dateFormatter,
      timeFormatter,
      (monto, abonado) {
        totalMontos += monto;
        totalAbonado += abonado;
      },
    );

    contenidoPDF.add(abonosWidget);
    contenidoPDF.add(pw.SizedBox(height: 12));
  }

  // Agregar resumen final
  contenidoPDF.addAll([
    pw.Divider(),
    pw.Text('Resumen Final', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
    pw.Text('Total de Metas: \$${totalMontos.toStringAsFixed(2)}'),
    pw.Text('Total Ahorrado: \$${totalAbonado.toStringAsFixed(2)}'),
    pw.Text(
      'Porcentaje Global: ${(totalAbonado / totalMontos * 100).clamp(0, 100).toStringAsFixed(1)}%',
    ),
  ]);

  pdf.addPage(pw.MultiPage(build: (context) => contenidoPDF));

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}

String _parseSafeDate(dynamic value, DateFormat formatter) {
  try {
    if (value is String) {
      return formatter.format(formatter.parse(value));
    } else if (value is Timestamp) {
      return formatter.format(value.toDate());
    }
  } catch (e) {
    return 'Fecha inválida';
  }
  return 'No disponible';
}

DateTime _parseTimestamp(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  } else if (value is DateTime) {
    return value;
  } else {
    return DateTime.now(); // fallback
  }
}

Future<pw.Widget> _buildAbonosSection(
  String achievementId,
  dynamic monto,
  String userId,
  DateFormat dateFormatter,
  DateFormat timeFormatter,
  void Function(double monto, double abonado) onResumen,
) async {
  final abonosSnapshot = await FirebaseFirestore.instance
      .collection('agregados')
      .where('userId', isEqualTo: userId)
      .where('achievementId', isEqualTo: achievementId)
      .get();

  double totalAbono = 0;

  final rows = <pw.Widget>[];

  for (var abono in abonosSnapshot.docs) {
    final fecha = abono['created_at'].toDate();
    final valor = double.tryParse(abono['valor_agregado'].toString()) ?? 0;
    totalAbono += valor;

    rows.add(
      pw.Bullet(
        text:
            '${dateFormatter.format(fecha)} ${timeFormatter.format(fecha)} - \$${valor.toStringAsFixed(2)}',
      ),
    );
  }

  final montoDouble = double.tryParse(monto.toString()) ?? 0;
  final restante = montoDouble - totalAbono;

  rows.add(pw.SizedBox(height: 6));
  rows.add(pw.Text('Total abonado: \$${totalAbono.toStringAsFixed(2)}'));
  rows.add(pw.Text('Falta por ahorrar: \$${restante.toStringAsFixed(2)}'));

  onResumen(montoDouble, totalAbono);

  return pw.Column(children: rows);
}
