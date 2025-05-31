import 'package:flutter/material.dart';

class ConfigUsuarioScreen extends StatefulWidget {
  const ConfigUsuarioScreen({Key? key}) : super(key: key);

  @override
  _ConfigUsuarioScreenState createState() => _ConfigUsuarioScreenState();
}

class _ConfigUsuarioScreenState extends State<ConfigUsuarioScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Usuario'), // Título básico
      ),
      body: const Center(
        child: Text(
          'Contenido de la configuración de usuario aquí',
        ), // Texto de placeholder
      ),
    );
  }
}
