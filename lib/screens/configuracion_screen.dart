import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // <-- IMPORTANTE

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
              onTap: () {},
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
