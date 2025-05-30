import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  String _selectedDisplayCurrency =
      'COP'; // Moneda de visualización por defecto

  final Map<String, double> _exchangeRates = {
    'COP_to_USD': 0.00025, // Ejemplo: 1 COP = 0.00025 USD
    'USD_to_COP': 4000.0,
  };
  double get usdToCopRate {
    return _exchangeRates['USD_to_COP'] ?? 4000.0;
  }

  String get selectedDisplayCurrency => _selectedDisplayCurrency;

  CurrencyProvider() {
    _loadSelectedCurrency();
  }

  Future<void> _loadSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedDisplayCurrency =
        prefs.getString('selectedDisplayCurrency') ?? 'COP';
    notifyListeners();
  }

  Future<void> setSelectedDisplayCurrency(String currency) async {
    // La lógica de guardar se manejará en el botón de la pantalla.
    // Aquí solo actualizamos el valor temporalmente.
    if (_selectedDisplayCurrency != currency) {
      _selectedDisplayCurrency = currency;
      notifyListeners(); // Notifica a los widgets para que re-dibujen inmediatamente
    }
  }

  // **NUEVO MÉTODO para guardar la configuración de forma persistente**
  Future<void> saveSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedDisplayCurrency', _selectedDisplayCurrency);
  }

  double convertAmount(double amountInBaseCurrency) {
    if (_selectedDisplayCurrency == 'COP') {
      return amountInBaseCurrency;
    } else if (_selectedDisplayCurrency == 'USD') {
      return amountInBaseCurrency * (_exchangeRates['COP_to_USD'] ?? 0.00025);
    }
    return amountInBaseCurrency;
  }

  // **MODIFICADO:** getCurrencySymbol para un símbolo más claro.
  String getCurrencySymbol() {
    if (_selectedDisplayCurrency == 'COP') {
      return 'COP'; // Un símbolo más distintivo para Pesos Colombianos
    } else if (_selectedDisplayCurrency == 'USD') {
      return 'USD'; // Símbolo para Dólares
    }
    return '';
  }
}
