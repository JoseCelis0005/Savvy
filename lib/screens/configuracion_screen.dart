import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // <-- IMPORTANTE
import 'package:savvy/l10n/app_localizations.dart'; // este es correcto

class ConfiguracionScreen extends StatefulWidget {
  @override
  _ConfiguracionScreen createState() => _ConfiguracionScreen();
}

class _ConfiguracionScreen extends State<ConfiguracionScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // <-- OBTÉN LA INSTANCIA

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(6, 145, 154, 1),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.settings, // <-- USA LA CLAVE
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
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            ListTile(
              leading: Icon(Icons.person, color: Colors.teal),
              title: Text(l10n.userSettings), // <-- USA LA CLAVE
              onTap: () {
                Navigator.pushNamed(context, '/config-usuario');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.color_lens, color: Colors.teal),
              title: Text(l10n.themeSettings), // <-- USA LA CLAVE
              onTap: () {
                Navigator.pushNamed(context, '/config-tema');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.language, color: Colors.teal),
              title: Text(l10n.languageSettings), // <-- USA LA CLAVE
              onTap: () {
                Navigator.pushNamed(context, '/config-idioma');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.attach_money, color: Colors.teal),
              title: Text(l10n.currencySettings), // <-- USA LA CLAVE
              onTap: () {
                Navigator.pushNamed(context, '/config-moneda');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.teal),
              title: Text(l10n.logout), // <-- USA LA CLAVE
              onTap: () {
                Navigator.pushNamed(context, '/config-sesion');
              },
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
