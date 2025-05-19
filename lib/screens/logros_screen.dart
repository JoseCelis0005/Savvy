import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

//pantalla logros
class LogrosScreen extends StatelessWidget {
  //const LogrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text('Usuario no autenticado'));
    }
    final uid = user.uid;

    return Scaffold(
      /*appBar: AppBar(
        title: Text('TUS LOGROS'),
        automaticallyImplyLeading:
            false, // Opcional: Quita la flecha de "volver" automática
      ),*/
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(6, 145, 154, 1),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tus Logros',
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
                  hintText: 'Buscar',
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
                     stream: FirebaseFirestore.instance
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
                        children: snapshot.data!.docs.map((doc) {
                          final photoUrl = doc['photoUrl'] ?? 'assets/images/logro.png';  // URL de la imagen
                          return Column(
                            children: [
                              LogroItem(
                                userId: uid,
                                id: doc.id,
                                imagenUrl: photoUrl,
                                titulo: _capitalizeFirstLetter(doc['name_logro'] ?? 'Sin Título'),
                                monto: _formatCurrency(doc['monto']?.toString() ?? '0'),
                                // puedes pasar otras cosas como fec_inicio, fec_fin si quieres
                              ),
                              SizedBox(height: 12.0),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                  /*LogroItem(
                    imagen:
                        'assets/images/vacaciones.jpg', // Reemplaza con tus rutas de imágenes
                    titulo: 'VACACIONES',
                    monto: '\$3.200.000',
                  ),
                  SizedBox(height: 12.0),
                  LogroItem(
                    imagen: 'assets/images/casa.jpg',
                    titulo: 'CASA',
                    monto: '\$500.000',
                  ),
                  SizedBox(height: 12.0),
                  LogroItem(
                    imagen: 'assets/images/casa.jpg',
                    titulo: 'NEGOCIO',
                    monto: '\$1.000.000',
                  ),*/
                  SizedBox(height: 12.0),
                  LogroItem(
                    userId: uid,
                    id: '0',
                    imagenUrl: 'assets/images/logro.png',
                    titulo: 'Nuevo Logro',
                    monto: '',
                    isNew: true,
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

      //Circular menú
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
  final String monto;
  final bool isNew;

  const LogroItem({
    Key? key,
    required this.id,
    required this.userId,
    required this.imagenUrl,
    required this.titulo,
    required this.monto,
    this.isNew = false,
  }) : super(key: key);

  @override
  _LogroItemState createState() => _LogroItemState();
}

class _LogroItemState extends State<LogroItem> {
  double progreso = 0.0;

  @override
  void initState() {
    super.initState();
    _calcularProgreso();
  }

  Future<void> _calcularProgreso() async {
   final snapshot = await FirebaseFirestore.instance
    .collection('agregados')
    .where('achievementId', isEqualTo: widget.id)
    .get();

    // Paso 1: Elimina el símbolo de moneda y espacios
      String montoLimpio = widget.monto
          .replaceAll('\$', '')     // elimina el símbolo de pesos si está
          .replaceAll(' ', '');     // elimina espacios

      // Paso 2: Separa por coma y toma la parte entera
      if (montoLimpio.contains(',')) {
        montoLimpio = montoLimpio.split(',')[0]; // "200.000"
      }

      // Paso 3: Elimina los puntos (separadores de miles)
      montoLimpio = montoLimpio.replaceAll('.', ''); // "200000"

      // Paso 4: Convertir a entero
      final montoObjetivo = int.tryParse(montoLimpio) ?? 0;

    int totalAgregado = 0;
    for (var doc in snapshot.docs) {
      totalAgregado += int.tryParse(doc['valor_agregado']?.toString() ?? '0') ?? 0;
    }

    if (montoObjetivo > 0) {
      setState(() {
        progreso = totalAgregado / montoObjetivo;
        if (progreso > 1.0) progreso = 1.0;
      });
    }
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
          return Image.asset(
            widget.imagenUrl,
            width: 80.0,
            height: 80.0,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      imageWidget = Image.asset(
        widget.imagenUrl,
        width: 80.0,
        height: 80.0,
        fit: BoxFit.cover,
      );
    }

    return GestureDetector(
      onTap: widget.isNew
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
                        widget.monto,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 6.0),
                      LinearProgressIndicator(
                        value: progreso,
                        backgroundColor: Colors.grey[300],
                        color: Colors.green,
                        minHeight: 8.0,
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        "${(progreso * 100).toStringAsFixed(0)}% completado",
                        style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
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
                        _mostrarDialogoAgregarMonto(context, widget.id, widget.monto, widget.userId);
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

String _formatCurrency(String amount) {
  try {
    final number = double.parse(amount);
    final formatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    return formatter.format(number);
  } catch (e) {
    return '\$0';
  }
}

void _mostrarDialogoAgregarMonto(
    BuildContext context, String docId, dynamic montoActual, String userId) {
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Agregar monto'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Monto adicional (COP)'),
      ),
      actions: [
        TextButton(
          child: Text('Cancelar'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text('Agregar'),
          onPressed: () async {
            final nuevoMonto = int.tryParse(controller.text) ?? 0;

            final ahora = DateTime.now();
            final fecha = "${ahora.day.toString().padLeft(2, '0')}/${ahora.month.toString().padLeft(2, '0')}/${ahora.year}";
            final hora = "${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}:${ahora.second.toString().padLeft(2, '0')}";

            // Guardar en subcolección "agregados"
            await FirebaseFirestore.instance
              .collection('agregados')  // colección independiente
              .add({
                'valor_agregado': nuevoMonto.toString(),
                'fecha': fecha,
                'hora': hora,
                'userId': userId,
                'achievementId': docId,
                'created_at': ahora,
              });

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
    builder: (context) => AlertDialog(
      title: Text('¿Eliminar logro?'),
      content: Text('¿Estás seguro de que deseas eliminar este logro? Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
          child: Text('Cancelar'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          onPressed: () async {
            await FirebaseFirestore.instance.collection('achievements').doc(docId).delete();
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}



