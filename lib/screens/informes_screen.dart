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

class InformesScreen extends StatelessWidget {
  const InformesScreen({Key? key}) : super(key: key);

  // Helper para formatear la moneda (similar al de home_screen)
  String _formatCurrency(double value, CurrencyProvider currencyProvider) {
    final convertedValue = currencyProvider.convertAmount(value);
    final currencySymbol = currencyProvider.getCurrencySymbol();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

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
            _UserInfoSection(userName: userName),
            const SizedBox(height: 20),
            const _SearchBar(),
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

class _UserInfoSection extends StatelessWidget {
  final String userName;
  const _UserInfoSection({Key? key, required this.userName}) : super(key: key);

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
              const CircleAvatar(
                backgroundImage: AssetImage('assets/images/informe.png'),
                radius: 25,
              ),
              const SizedBox(width: 10),
              Text(
                userName,
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
