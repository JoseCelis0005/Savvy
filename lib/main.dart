import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
import 'package:firebase_core/firebase_core.dart'; // Importa la librería de Firebase
import 'routes/app_routes.dart'; // Importa las rutas de la aplicación
import 'package:url_launcher/url_launcher.dart'; // Importa la librería Flutter
import 'package:circular_menu/circular_menu.dart'; //libreria para el menu circular
=======
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:savvy/routes/app_routes.dart';
>>>>>>> 41601a3cd40a2601b0ce19e158a70af05f008574
import 'package:savvy/screens/configuracion/theme_model.dart';
import 'package:savvy/screens/configuracion/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:savvy/notificaciones/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:savvy/screens/configuracion/currency_provider.dart';
import 'package:savvy/screens/configuracion/config_sesion_screen.dart';

// Instancia global de notificaciones
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

late NotificationService notificationService;

void onDidReceiveLocalNotification(
  int id,
  String? title,
  String? body,
  String? payload,
) async {
  debugPrint('Notificación recibida (iOS < 10): $title, $body, $payload');
}

// Callback para respuesta cuando app está en foreground o background
void onDidReceiveNotificationResponse(NotificationResponse response) async {
  final String? payload = response.payload;
  if (payload != null) {
    debugPrint('Payload notificación (foreground/background): $payload');
    // Aquí puedes manejar navegación usando payload si tienes navigatorKey
  }
}

// Callback para respuesta cuando app está terminada (background sin contexto)
@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  final String? payload = response.payload;
  if (payload != null) {
    debugPrint('Payload notificación (background): $payload');
    // Aquí lógica sin navegación directa
  }
}

// Función para solicitar permisos de notificación (Android 13+)
Future<void> solicitarPermisoNotificaciones() async {
  if (await Permission.notification.isDenied ||
      await Permission.notification.isRestricted) {
    await Permission.notification.request();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Inicializar zonas horarias para notificaciones
  tz.initializeTimeZones();

  // Solicitar permiso para notificaciones
  await solicitarPermisoNotificaciones();

  // Configuración para Android
  const initializationSettingsAndroid = AndroidInitializationSettings(
    'app_icon', // Asegúrate que este icono exista en mipmap/drawable
  );

  // Configuración para iOS/macOS
  const initializationSettingsDarwin = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification: onDidReceiveLocalNotification,
  );

  // Configuración general inicialización
  final initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  // Inicializar plugin de notificaciones
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    onDidReceiveBackgroundNotificationResponse:
        onDidReceiveBackgroundNotificationResponse,
  );

  // Inicializar tu servicio de notificaciones personalizado
  notificationService = NotificationService(flutterLocalNotificationsPlugin);
  print('NotificationService inicializado.');

  // Correr la app con Providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModel()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeModel>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'Savvy',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('en')],
      localeResolutionCallback: (locale, supportedLocales) {
        if (localeProvider.locale != null) return localeProvider.locale;
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      initialRoute: '/',
      routes: AppRoutes.routes,
    );
  }
}
