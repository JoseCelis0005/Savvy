import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Importa la librería Flutter
import 'package:circular_menu/circular_menu.dart'; //libreria para el menu circular
import 'package:firebase_core/firebase_core.dart'; // Importa la librería de Firebase
import 'routes/app_routes.dart'; // Importa las rutas de la aplicación

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //const MyApp({super.key});

  // Define una clase llamada MyApp que extiende StatelessWidget.
  @override
  Widget build(BuildContext context) {
    // Define el método build para construir la interfaz de la aplicación.
    return MaterialApp(
      title: 'Savvy', // Título de la aplicación.
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch:
            Colors
                .blue, // Configura el tema de la aplicación con un color azul.
      ),
      initialRoute: '/', // Ruta inicial de la aplicación.
      routes: AppRoutes.routes,
    );
  }
}
