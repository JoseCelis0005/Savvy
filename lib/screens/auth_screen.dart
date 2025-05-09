import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // <-- IMPORTANTE

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isRegistered = false;
  bool isLoggedIn = false;
  String? registeredEmail;
  String? registeredPassword;

  void register() async {
    final result = await Navigator.pushNamed(
      context,
      '/register',
    );
    if (result != null && result is Map<String, String>) {
      setState(() {
        isRegistered = true;
        registeredEmail = result['email'];
        registeredPassword = result['password'];
      });
    }
  }

  void login() async {
    final enteredEmail = emailController.text.trim();
    final enteredPassword = passwordController.text;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: enteredEmail)
          .where('password', isEqualTo: enteredPassword)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          isLoggedIn = true;
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            final l10n = AppLocalizations.of(context)!;
            return AlertDialog(
              title: Text(l10n.loginErrorTitle),
              content: Text(l10n.loginErrorMessage),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.close),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error al intentar iniciar sesión: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text(l10n.error),
            content: Text(l10n.databaseErrorMessage),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(l10n.close),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isLoggedIn) {
      return HelloWorldScreen();
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(6, 145, 154, 1),
          centerTitle: true,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Savvy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.appSlogan,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: InkWell(
                  onTap: () {
                    launchUrl(
                      Uri.parse('https://www.youtube.com/watch?v=1hj7XWHUNd0r'),
                    );
                  },
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: l10n.email),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: l10n.password),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(
                    6,
                    145,
                    154,
                    1,
                  ),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child: Text(l10n.login),
              ),
              TextButton(
                onPressed: register,
                child: Text(l10n.noAccount),
              ),
              TextButton(onPressed: register, child: Text(l10n.registerHere)),
            ],
          ),
        ),
      );
    }
  }
}

class HelloWorldScreen extends StatefulWidget {
  @override
  _HelloWorldScreenState createState() => _HelloWorldScreenState();
}

class _HelloWorldScreenState extends State<HelloWorldScreen> {
  @override
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(6, 145, 154, 1),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.home,
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300,
              child: Recuadro(
                titulo: l10n.monthlySavings,
                monto: '\$1,234.56',
                porcentaje: '+12.34%',
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: Recuadro(
                titulo: l10n.goalSavings,
                monto: '\$1,234.56',
                porcentaje: '+12.34%',
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: Recuadro(
                titulo: l10n.expenses,
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
          BottomNavigationBarItem(icon: Icon(Icons.arrow_back), label: 'Atras'),
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

class Recuadro extends StatelessWidget {
  final String titulo;
  final String monto;
  final String porcentaje;

  const Recuadro({
    required this.titulo,
    required this.monto,
    required this.porcentaje,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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