import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_model.dart'; // ajusta el path según tu estructura

class ConfigTemaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración de Tema'),
        backgroundColor: Color.fromRGBO(6, 145, 154, 1),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => themeProvider.toggleTheme(),
          child: Text(themeProvider.isDarkMode ? 'Modo Claro' : 'Modo Oscuro'),
        ),
      ),
    );
  }
}
