import 'package:flutter/material.dart';
import '../screens/auth_screen.dart';
import '../screens/register_screen.dart';
import '../screens/logros_screen.dart';
import '../screens/informes_screen.dart';
import '../screens/configuracion_screen.dart';
import '../screens/crear_logro_screen.dart';
import '../screens/configuracion/config_tema_screen.dart';
import '../screens/configuracion/config_idioma_screen.dart';

class AppRoutes {
  static const initialRoute = '/';

  static final routes = <String, WidgetBuilder>{
    '/': (context) => AuthScreen(),
    '/register': (context) => RegisterScreen(),
    '/logros': (context) => LogrosScreen(),
    '/informes': (context) => InformesScreen(),
    '/configuracion': (context) => ConfiguracionScreen(),
    '/crear-logro': (context) => crear_logro(),
    '/config-tema': (_) => ConfigTemaScreen(),
    '/config-idioma': (_) => ConfigIdiomaScreen(),
  };
}
