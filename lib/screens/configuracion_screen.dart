import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';

class ConfiguracionScreen extends StatefulWidget {
  @override
  _ConfiguracionScreen createState() => _ConfiguracionScreen();
}

class _ConfiguracionScreen extends State<ConfiguracionScreen> {
  //const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(6, 145, 154, 1),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Configuracion',
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
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            ListTile(
              leading: Icon(Icons.person, color: Colors.teal),
              title: Text('Configuración de Usuario'),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.color_lens, color: Colors.teal),
              title: Text('Configuración de Tema'),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.language, color: Colors.teal),
              title: Text('Configuración de Idioma'),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.attach_money, color: Colors.teal),
              title: Text('Configuración de Moneda'),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.teal),
              title: Text('Cerrar Sesión'),
              onTap: () {},
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
