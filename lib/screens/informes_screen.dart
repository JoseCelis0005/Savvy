import 'package:flutter/material.dart';

//pantalla informes
class InformesScreen extends StatelessWidget {
  //const InformesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('INFORMES')),
      body: // Aquí va el código para mostrar la pantalla de logros
      //  ... (Código de la pantalla de logros de la imagen)
      Center(
        child: Text("Pantalla de INFORMES", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}