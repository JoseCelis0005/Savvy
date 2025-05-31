import 'package:flutter/material.dart';
import '../screens/auth_screen.dart';
import '../screens/register_screen.dart';
import '../screens/logros_screen.dart';
import '../screens/informes_screen.dart';
import '../screens/configuracion_screen.dart';
import '../screens/crear_logro_screen.dart';
import '../screens/configuracion/config_tema_screen.dart';
import '../screens/configuracion/config_idioma_screen.dart';
import '../screens/home_screen.dart';
import '../screens/test_screen.dart';
import '../screens/configuracion/config_moneda_screen.dart';
import '../screens/configuracion/config_sesion_screen.dart';
import '../screens/configuracion/config_usuario_screen.dart';

class AppRoutes {
  static const initialRoute = '/';

  static final routes = <String, WidgetBuilder>{
    '/': (context) => AuthScreen(),
    '/register': (context) => RegisterScreen(),
    '/home': (context) => HelloWorldScreen(),
    '/test': (context) => TestScreen(),
    '/logros': (context) => LogrosScreen(),
    '/informes': (context) => InformesScreen(),
    '/configuracion': (context) => ConfiguracionScreen(),
    '/crear-logro': (context) => crear_logro(),
    '/config-tema': (_) => ConfigTemaScreen(),
    '/config-idioma': (_) => ConfigIdiomaScreen(),
    '/config-moneda': (_) => const ConfigMonedaScreen(),
    '/config-sesion': (context) => const ConfigSesionScreen(),
    '/config-usuario': (context) => const ConfigUsuarioScreen(),
  };
}
