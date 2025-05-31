import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:savvy/l10n/app_localizations.dart'; // este es correcto
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
      // Usamos Stack para posicionar múltiples widgets flotantes
      floatingActionButton: Stack(
        children: [
          // Botón de la casita flotante a la izquierda
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 35.0,
                bottom: 20.0,
              ), // Ajusta el padding según necesites
              child: FloatingActionButton(
                heroTag: 'homeBtn', // Es importante para múltiples FABs
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
                backgroundColor: Colors.teal,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.home,
                  color: Colors.white,
                ), // Icono de la casita
              ),
            ),
          ),
          // Menú Circular (se mantiene igual, a la derecha)
          CircularMenu(
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
  final double montoBase;
  final bool isNew;
  final CurrencyProvider currencyProvider;

  const LogroItem({
    Key? key,
    required this.id,
    required this.userId,
    required this.imagenUrl,
    required this.titulo,
    required this.montoBase,
    this.isNew = false,
    required this.currencyProvider,
  }) : super(key: key);

  @override
  State<LogroItem> createState() => _LogroItemState();
}

class _LogroItemState extends State<LogroItem> {
  double progreso = 0.0;

  @override
  void initState() {
    super.initState();
    _calcularProgreso();
  }

  @override
  void didUpdateWidget(covariant LogroItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.id != oldWidget.id ||
        widget.currencyProvider.selectedDisplayCurrency != oldWidget.currencyProvider.selectedDisplayCurrency) {
      _calcularProgreso();
    }
  }

  Future<void> _calcularProgreso() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('agregados')
        .where('achievementId', isEqualTo: widget.id)
        .where('userId', isEqualTo: widget.userId)
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      total += double.tryParse(doc['valor_agregado'].toString()) ?? 0;
    }

    final nuevoProgreso = widget.montoBase > 0 ? (total / widget.montoBase).clamp(0.0, 1.0) : 0.0;

    if (mounted) {
      setState(() {
        progreso = nuevoProgreso;
      });
    }
  }

  String _formatCurrency(double value) {
    final converted = widget.currencyProvider.convertAmount(value);
    final symbol = widget.currencyProvider.getCurrencySymbol();
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: symbol,
      decimalDigits: symbol == 'US' ? 2 : 0,
    );
    return formatter.format(converted);
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.imagenUrl.isNotEmpty
        ? Image.network(
            widget.imagenUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _defaultImage(),
          )
        : _defaultImage();

    return GestureDetector(
      onTap: widget.isNew ? () => Navigator.pushNamed(context, '/crear-logro') : null,
      child: _buildCard(image),
    );
  }

  Widget _defaultImage() {
    return Image.asset(
      'assets/images/logro.png',
      width: 80,
      height: 80,
      fit: BoxFit.cover,
    );
  }

  Widget _buildCard(Widget image) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 3, offset: Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            image,
            SizedBox(width: 16),
            Expanded(child: _buildInfo()),
            widget.isNew ? Icon(Icons.add_circle, color: Colors.teal, size: 32) : _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.titulo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (!widget.isNew) ...[
          Text(_formatCurrency(widget.montoBase), style: TextStyle(fontSize: 16, color: Colors.green)),
          SizedBox(height: 6),
          LinearProgressIndicator(
            value: progreso,
            backgroundColor: Colors.grey[300],
            color: Colors.green,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          SizedBox(height: 4),
          Text('${(progreso * 100).toStringAsFixed(0)}% completado', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.add),
          color: Colors.teal,
          onPressed: () => _mostrarDialogoAgregarMonto(
            context,
            widget.id,
            widget.montoBase,
            widget.userId,
            widget.currencyProvider,
          ),
        ),
        IconButton(
          icon: Icon(Icons.edit),
          color: Colors.blue,
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/crear-logro',
              arguments: {'logroId': widget.id},
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.delete),
          color: Colors.red,
          onPressed: () => _confirmarEliminarLogro(context, widget.id),
        ),
      ],
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
                // Eliminar el achievement
                await FirebaseFirestore.instance
                    .collection('achievements')
                    .doc(docId)
                    .delete();

                // Eliminar los agregados que tengan el mismo achievementId
                final agregadosSnapshot = await FirebaseFirestore.instance
                    .collection('agregados')
                    .where('achievementId', isEqualTo: docId)
                    .get();

                for (final doc in agregadosSnapshot.docs) {
                  await doc.reference.delete();
                }

                // Volver atrás en la navegación
                Navigator.pop(context);
              },
            ),
          ],
        ),
  );
}
