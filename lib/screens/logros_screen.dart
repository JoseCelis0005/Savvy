import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:savvy/main.dart'; // Asegúrate de que esta importación sea correcta para notificationService
import 'package:provider/provider.dart'; // Importa Provider
import 'package:savvy/screens/configuracion/currency_provider.dart'; // Importa tu CurrencyProvider

//pantalla logros
class LogrosScreen extends StatelessWidget {
  //const LogrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text('Usuario no autenticado'));
    }
    final uid = user.uid;

    // Accede al CurrencyProvider aquí
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(6, 145, 154, 1),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.achievements,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barra de Búsqueda
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.search,
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),

            // Lista de Logros
            Expanded(
              child: ListView(
                children: [
                  StreamBuilder(
                    stream:
                        FirebaseFirestore.instance
                            .collection('achievements')
                            .where('userId', isEqualTo: uid)
                            .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No achievements found.'));
                      }
                      return Column(
                        children:
                            snapshot.data!.docs.map((doc) {
                              final photoUrl =
                                  doc['photoUrl'] ?? 'assets/images/logro.png';
                              // Asegúrate de que el monto se pase como double para la conversión
                              final double montoObjetivoEnBase =
                                  double.tryParse(
                                    doc['monto']?.toString() ?? '0',
                                  ) ??
                                  0;

                              return Column(
                                children: [
                                  LogroItem(
                                    userId: uid,
                                    id: doc.id,
                                    imagenUrl: photoUrl,
                                    titulo: _capitalizeFirstLetter(
                                      doc['name_logro'] ?? 'Sin Título',
                                    ),
                                    // Pasa el monto base y el currencyProvider al LogroItem
                                    montoBase: montoObjetivoEnBase,
                                    currencyProvider:
                                        currencyProvider, // Pasa el provider
                                  ),
                                  SizedBox(height: 12.0),
                                ],
                              );
                            }).toList(),
                      );
                    },
                  ),
                  SizedBox(height: 12.0),
                  // Para el LogroItem "Nuevo Logro", no necesitas pasar el monto base ni el provider.
                  LogroItem(
                    userId: uid,
                    id: '0',
                    imagenUrl: 'assets/images/logro.png',
                    titulo: l10n.newAchievement,
                    montoBase: 0.0, // Monto base 0 para el nuevo logro
                    isNew: true,
                    currencyProvider:
                        currencyProvider, // Pasa el provider también aquí
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Navegar hacia atrás
              },
            ),
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.pop(context); // Navegar hacia atrás
              },
            ),
            IconButton(
              icon: Icon(Icons.attach_money),
              onPressed: () {
                // Navegar a la pantalla de finanzas (ajusta la ruta según tu app)
                Navigator.pushNamed(
                  context,
                  '/informes',
                ); // Ejemplo: '/informes'
              },
            ),
          ],
        ),
      ),
      floatingActionButton: CircularMenu(
        alignment: Alignment.bottomRight,
        toggleButtonColor: Colors.teal,
        toggleButtonIconColor: Colors.white,
        items: [
          CircularMenuItem(
            icon: Icons.settings,
            color: Colors.teal,
            onTap: () {
              Navigator.pushNamed(context, '/configuracion');
            },
          ),
          CircularMenuItem(
            icon: Icons.bar_chart,
            color: Colors.teal,
            onTap: () {
              Navigator.pushNamed(context, '/informes');
            },
          ),
          CircularMenuItem(
            icon: Icons.emoji_events,
            color: Colors.teal,
            onTap: () {
              Navigator.pushNamed(context, '/logros');
            },
          ),
        ],
      ),
    );
  }
}

class LogroItem extends StatefulWidget {
  final String id;
  final String userId;
  final String imagenUrl;
  final String titulo;
  final double
  montoBase; // Ahora es un double para el monto en la moneda base (COP)
  final bool isNew;
  final CurrencyProvider currencyProvider; // Recibe el CurrencyProvider

  const LogroItem({
    Key? key,
    required this.id,
    required this.userId,
    required this.imagenUrl,
    required this.titulo,
    required this.montoBase, // Cambiado a montoBase
    this.isNew = false,
    required this.currencyProvider, // Hace que sea requerido
  }) : super(key: key);

  @override
  _LogroItemState createState() => _LogroItemState();
}

class _LogroItemState extends State<LogroItem> {
  double progreso = 0.0;
  // String _formattedMonto = ''; // Para almacenar el monto formateado

  @override
  void initState() {
    super.initState();
    _calcularProgreso();
  }

  // Se recalcula el progreso cada vez que el widget se actualiza (e.g. al cambiar la moneda)
  @override
  void didUpdateWidget(covariant LogroItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.id != oldWidget.id ||
        widget.currencyProvider.selectedDisplayCurrency !=
            oldWidget.currencyProvider.selectedDisplayCurrency) {
      _calcularProgreso();
    }
  }

  Future<void> _calcularProgreso() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('agregados')
            .where('achievementId', isEqualTo: widget.id)
            .where(
              'userId',
              isEqualTo: widget.userId,
            ) // Asegúrate de filtrar por userId
            .get();

    double totalAgregadoEnBase = 0; // Acumular en la moneda base (COP)
    for (var doc in snapshot.docs) {
      // Asume que valor_agregado en Firestore SIEMPRE está en la moneda base (COP)
      totalAgregadoEnBase +=
          double.tryParse(doc['valor_agregado']?.toString() ?? '0') ?? 0;
    }

    if (widget.montoBase > 0) {
      setState(() {
        progreso = totalAgregadoEnBase / widget.montoBase;
        if (progreso > 1.0) progreso = 1.0;
      });
    } else {
      setState(() {
        progreso = 0.0;
      });
    }
  }

  // Helper para formatear la moneda, ahora utiliza el currencyProvider
  String _formatCurrency(double value, CurrencyProvider currencyProvider) {
    final convertedValue = currencyProvider.convertAmount(value);
    final currencySymbol =
        currencyProvider.getCurrencySymbol(); // Obtiene "COP" o "US"

    final formatter = NumberFormat.currency(
      locale: 'es_CO', // o 'en_US' si prefieres para dólares
      symbol: currencySymbol, // Usa el símbolo personalizado
      decimalDigits:
          currencyProvider.selectedDisplayCurrency == 'USD'
              ? 2
              : 0, // 2 decimales para USD, 0 para COP
    );
    return formatter.format(convertedValue);
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (widget.imagenUrl.isNotEmpty) {
      imageWidget = Image.network(
        widget.imagenUrl,
        width: 80.0,
        height: 80.0,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Si la URL de red falla, intenta cargar como asset local
          return Image.asset(
            widget.imagenUrl,
            width: 80.0,
            height: 80.0,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      // Si imagenUrl está vacío, usa el asset por defecto
      imageWidget = Image.asset(
        'assets/images/logro.png', // Asegúrate de que esta ruta sea correcta
        width: 80.0,
        height: 80.0,
        fit: BoxFit.cover,
      );
    }

    return GestureDetector(
      onTap:
          widget.isNew
              ? () {
                Navigator.pushNamed(context, '/crear-logro');
              }
              : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              imageWidget,
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.titulo,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!widget.isNew) ...[
                      Text(
                        // Usa el helper para formatear el montoBase
                        _formatCurrency(
                          widget.montoBase,
                          widget.currencyProvider,
                        ),
                        style: TextStyle(fontSize: 16.0, color: Colors.green),
                      ),
                      SizedBox(height: 6.0),
                      LinearProgressIndicator(
                        value: progreso,
                        backgroundColor: Colors.grey[300],
                        color: Colors.green,
                        minHeight: 8.0,
                        borderRadius: BorderRadius.circular(
                          4.0,
                        ), // Añadido para consistencia
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        "${(progreso * 100).toStringAsFixed(0)}% completado",
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.isNew)
                Icon(Icons.add_circle, color: Colors.teal, size: 32.0)
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.add),
                      color: Colors.teal,
                      onPressed: () {
                        _mostrarDialogoAgregarMonto(
                          context,
                          widget.id,
                          widget.montoBase, // Pasa el monto base
                          widget.userId,
                          widget.currencyProvider, // Pasa el currencyProvider
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () {
                        _confirmarEliminarLogro(context, widget.id);
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _capitalizeFirstLetter(String input) {
  if (input.isEmpty) return '';
  return input[0].toUpperCase() + input.substring(1);
}

// **ELIMINAR ESTA FUNCIÓN:** Ya no se usará esta función global, en su lugar se usará el _formatCurrency interno de LogroItem.
/*
String _formatCurrency(String amount) {
  try {
    final number = double.parse(amount);
    final formatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    return formatter.format(number);
  } catch (e) {
    return '\$0';
  }
}
*/

void _mostrarDialogoAgregarMonto(
  BuildContext context,
  String docId,
  double montoObjetivoBase, // Ahora es un double
  String userId,
  CurrencyProvider currencyProvider, // Se pasa el currencyProvider
) {
  final controller = TextEditingController();
  // Obtiene el símbolo de la moneda actual para el hintText
  final currentCurrencySymbol = currencyProvider.getCurrencySymbol();

  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text('Agregar monto'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            // HintText con el símbolo de la moneda actual
            decoration: InputDecoration(
              labelText: 'Monto adicional ($currentCurrencySymbol)',
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Agregar'),
              onPressed: () async {
                // El monto ingresado por el usuario debe ser tratado como si estuviera en la moneda de visualización actual
                // y luego convertido a la moneda base (COP) para almacenar en Firestore.
                double montoIngresado = double.tryParse(controller.text) ?? 0;

                // Convierte el monto ingresado de la moneda de visualización a la moneda base (COP)
                // Usamos la inversa de la tasa de COP_to_USD si la moneda de visualización es USD.
                double montoParaGuardarEnBase;
                if (currencyProvider.selectedDisplayCurrency == 'USD') {
                  // Asume que la tasa USD_to_COP está disponible en _exchangeRates
                  montoParaGuardarEnBase =
                      montoIngresado * currencyProvider.usdToCopRate;
                } else {
                  montoParaGuardarEnBase = montoIngresado; // Ya está en COP
                }

                final ahora = DateTime.now();
                final fecha =
                    "${ahora.day.toString().padLeft(2, '0')}/${ahora.month.toString().padLeft(2, '0')}/${ahora.year}";
                final hora =
                    "${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}:${ahora.second.toString().padLeft(2, '0')}";

                // Guardar en subcolección "agregados"
                await FirebaseFirestore.instance.collection('agregados').add({
                  'valor_agregado': montoParaGuardarEnBase.toStringAsFixed(
                    0,
                  ), // Guardar como String o double sin decimales si es entero
                  'fecha': fecha,
                  'hora': hora,
                  'userId': userId,
                  'achievementId': docId,
                  'created_at': ahora,
                });

                DocumentSnapshot? achievementDoc;
                try {
                  achievementDoc =
                      await FirebaseFirestore.instance
                          .collection('achievements')
                          .doc(docId)
                          .get();
                } catch (e) {
                  debugPrint(
                    'Error al obtener el logro para la notificación: $e',
                  );
                }

                final nombreLogro = achievementDoc?['name_logro'] ?? 'tu meta';

                notificationService.showInstantNotification(
                  id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  title: '¡Excelente progreso! 🎉',
                  body: '¡Sigue ahorrando para tu meta $nombreLogro!',
                  payload: 'monto_agregado_incentivo',
                );

                Navigator.pop(context);
              },
            ),
          ],
        ),
  );
}

void _confirmarEliminarLogro(BuildContext context, String docId) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text('¿Eliminar logro?'),
          content: Text(
            '¿Estás seguro de que deseas eliminar este logro? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('achievements')
                    .doc(docId)
                    .delete();
                Navigator.pop(context);
              },
            ),
          ],
        ),
  );
}
