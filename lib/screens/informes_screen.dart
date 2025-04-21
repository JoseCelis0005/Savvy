import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';

class InformesScreen extends StatefulWidget {
  @override
  _InformesScreen createState() => _InformesScreen();
}

//pantalla informes
class _InformesScreen extends State<InformesScreen> {
  //const InformesScreen({super.key});

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
