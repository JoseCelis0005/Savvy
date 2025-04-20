import 'package:flutter/material.dart';
import '../screens/auth_screen.dart';
import '../screens/register_screen.dart';
import '../screens/logros_screen.dart';
import '../screens/informes_screen.dart';
import '../screens/configuracion_screen.dart';

class AppRoutes {
  static const initialRoute = '/';

  static final routes = <String, WidgetBuilder>{
    '/': (context) => AuthScreen(),
    '/register': (context) => RegisterScreen(),
    '/logros': (context) => LogrosScreen(),
    '/informes': (context) => InformesScreen(),
    '/configuracion': (context) => ConfiguracionScreen(),
  };
}