import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savvy/screens/configuracion/currency_provider.dart';

class ConfigMonedaScreen extends StatefulWidget {
  const ConfigMonedaScreen({Key? key}) : super(key: key);

  @override
  _ConfigMonedaScreenState createState() => _ConfigMonedaScreenState();
}

class _ConfigMonedaScreenState extends State<ConfigMonedaScreen> {
  // La moneda seleccionada se gestiona directamente en el CurrencyProvider.

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Moneda'),
        backgroundColor: const Color.fromRGBO(6, 145, 154, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selecciona la moneda principal para mostrar en la aplicación:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: currencyProvider.selectedDisplayCurrency,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items:
                  <String>['COP', 'USD'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  // Solo actualizamos la moneda en el provider, no la guardamos aún.
                  currencyProvider.setSelectedDisplayCurrency(newValue);
                }
              },
            ),
            const SizedBox(height: 30),

            // Botón de Guardar
            ElevatedButton(
              onPressed: () async {
                await currencyProvider
                    .saveSelectedCurrency(); // Guarda la moneda seleccionada
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configuración de moneda guardada!'),
                  ),
                );
                Navigator.of(
                  context,
                ).pop(); // Opcional: Volver a la pantalla anterior
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(6, 145, 154, 1),
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Guardar Configuración',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20), // Espacio adicional
          ],
        ),
      ),
    );
  }
}
