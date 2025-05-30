import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
<<<<<<< HEAD
=======
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // Importar Provider
import 'package:savvy/screens/configuracion/currency_provider.dart'; // Importar tu CurrencyProvider
import 'package:intl/intl.dart'; // Importar para NumberFormat
>>>>>>> 41601a3cd40a2601b0ce19e158a70af05f008574

class InformesScreen extends StatefulWidget {
  @override
  _InformesScreen createState() => _InformesScreen();
}

//pantalla informes
class _InformesScreen extends State<InformesScreen> {
  //const InformesScreen({super.key});

  // Helper para formatear la moneda (similar al de home_screen)
  String _formatCurrency(double value, CurrencyProvider currencyProvider) {
    final convertedValue = currencyProvider.convertAmount(value);
    final currencySymbol = currencyProvider.getCurrencySymbol();

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
<<<<<<< HEAD
=======
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

>>>>>>> 41601a3cd40a2601b0ce19e158a70af05f008574
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(6, 145, 154, 1),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
<<<<<<< HEAD
            Text(
              'Informes',
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
      body: // Aquí va el código para mostrar la pantalla de logros
      //  ... (Código de la pantalla de logros de la imagen)
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 30),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                'Mis Informes',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade900,
                ),
              ),
            ),
            SizedBox(
              width: 300,
              child: Recuadro(
                titulo: 'Semanal',
                monto: '\$0',
                porcentaje: '+0%',
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: Recuadro(
                titulo: 'Mensual',
                monto: '\$0',
                porcentaje: '+0%',
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: Recuadro(
                titulo: 'Anual',
                monto: '\$0',
                porcentaje: '+0%',
=======
            _UserInfoSection(userName: userName),
            const SizedBox(height: 20),
            const _SearchBar(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _ReportCard(
                    title: l10n.weekly,
                    // Pasa el monto base y el CurrencyProvider
                    amountValue: weeklyAmountCOP,
                    currencyProvider: currencyProvider,
                    percentage:
                        '+5%', // Puedes ajustar el porcentaje si es dinámico
                    imagePath: 'assets/images/informe.png',
                  ),
                  const SizedBox(height: 16),
                  _ReportCard(
                    title: l10n.monthly,
                    // Pasa el monto base y el CurrencyProvider
                    amountValue: monthlyAmountCOP,
                    currencyProvider: currencyProvider,
                    percentage: '+10%',
                    imagePath: 'assets/images/informe.png',
                  ),
                  const SizedBox(height: 16),
                  _ReportCard(
                    title: l10n.yearly,
                    // Pasa el monto base y el CurrencyProvider
                    amountValue: yearlyAmountCOP,
                    currencyProvider: currencyProvider,
                    percentage: '+15%',
                    imagePath: 'assets/images/informe.png',
                  ),
                ],
>>>>>>> 41601a3cd40a2601b0ce19e158a70af05f008574
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

<<<<<<< HEAD
class Recuadro extends StatelessWidget {
  final String titulo;
  final String monto;
  final String porcentaje;

  const Recuadro({
    //super.key,
    required this.titulo,
    required this.monto,
    required this.porcentaje,
  });
=======
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
>>>>>>> 41601a3cd40a2601b0ce19e158a70af05f008574

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
      width: 600,
      decoration: BoxDecoration(
        color: Colors.teal.shade200,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
<<<<<<< HEAD
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
=======
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
>>>>>>> 41601a3cd40a2601b0ce19e158a70af05f008574
        ],
      ),
    );
  }
}
