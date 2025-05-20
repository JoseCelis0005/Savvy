import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa la librería de Firebase
import 'routes/app_routes.dart'; // Importa las rutas de la aplicación
import 'package:url_launcher/url_launcher.dart'; // Importa la librería Flutter
import 'package:circular_menu/circular_menu.dart'; //libreria para el menu circular
import 'package:savvy/screens/configuracion/theme_model.dart';
import 'package:savvy/screens/configuracion/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // <-- ¡IMPORTANTE!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModel()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Añadido Key?

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
        // Este callback se llama cuando el sistema operativo proporciona un Locale.
        // Devuelve el Locale que la aplicación debería usar.
        if (localeProvider.locale != null) {
          // Si el usuario ya ha seleccionado un Locale, úsalo.
          return localeProvider.locale;
        }
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            // Si el Locale del sistema coincide con uno soportado, úsalo.
            return supportedLocale;
          }
        }
        // Si no hay coincidencia, usa el primer Locale soportado (o un Locale predeterminado).
        return supportedLocales.first; // O return const Locale('en');
      },
      initialRoute: '/',
      routes: AppRoutes.routes,
    );
  }
}
