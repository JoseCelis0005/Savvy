import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';

//pantalla logros
class LogrosScreen extends StatelessWidget {
  //const LogrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  LogroItem(
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
                  ),
                  SizedBox(height: 12.0),
                  LogroItem(
                    imagen: 'assets/images/casa.jpg',
                    titulo: 'NUEVO LOGRO',
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

class LogroItem extends StatelessWidget {
  final String imagen;
  final String titulo;
  final String monto;
  final bool isNew;

  const LogroItem({
    super.key,
    required this.imagen,
    required this.titulo,
    required this.monto,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            Image.asset(imagen, width: 80.0, height: 80.0, fit: BoxFit.cover),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isNew) // Mostrar el monto solo si no es "NUEVO LOGRO"
                    Text(
                      monto,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.green, // O ajusta el color
                      ),
                    ),
                ],
              ),
            ),
            if (isNew) // Mostrar el ícono "+" para "NUEVO LOGRO"
              Icon(Icons.add_circle, color: Colors.teal, size: 32.0),
          ],
        ),
      ),
    );
  }
}