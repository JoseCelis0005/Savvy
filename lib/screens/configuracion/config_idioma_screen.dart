import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'locale_provider.dart'; // Asegúrate de que la ruta sea correcta
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Importante!

class ConfigIdiomaScreen extends StatefulWidget {
  @override
  _ConfigIdiomaScreenState createState() => _ConfigIdiomaScreenState();
}

class _ConfigIdiomaScreenState extends State<ConfigIdiomaScreen> {
  String _selectedLanguage = 'es';

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final l10n =
        AppLocalizations.of(context)!; // Obtener instancia de AppLocalizations

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.languageSettings), // Usar la clave traducida
        backgroundColor: Color.fromRGBO(6, 145, 154, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Español'),
              leading: Radio<String>(
                value: 'es',
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  localeProvider.setLocale(Locale(value!));
                },
              ),
            ),
            ListTile(
              title: Text('Inglés'),
              leading: Radio<String>(
                value: 'en',
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  localeProvider.setLocale(Locale(value!));
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Idioma cambiado a $_selectedLanguage'),
                  ),
                );
                Navigator.pop(context);
              },
              child: Text(l10n.save), // Usar la clave traducida
            ),
          ],
        ),
      ),
    );
  }
}
