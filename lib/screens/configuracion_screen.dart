import 'package:flutter/material.dart';

class ConfiguracionScreen extends StatelessWidget {
  //const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('configuracion')),
      body: // Aquí va el código para mostrar la pantalla de logros
      //  ... (Código de la pantalla de logros de la imagen)
      Center(
        child: Text(
          "Pantalla de CONFIGURACIÓN",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
