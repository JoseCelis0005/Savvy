import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  //const AuthScreen({super.key});

  // Define una clase llamada AuthScreen que extiende StatefulWidget.
  @override
  _AuthScreenState createState() => _AuthScreenState(); // Crea el estado para AuthScreen.
}

class _AuthScreenState extends State<AuthScreen> {
  // Define el estado de AuthScreen.
  TextEditingController emailController = TextEditingController(); // Controlador para el campo de correo electrónico.
  TextEditingController passwordController = TextEditingController(); // Controlador para el campo de contraseña.
  bool isRegistered = false; // Variable booleana que indica si el usuario está registrado.
  bool isLoggedIn = false; // Variable booleana que indica si el usuario ha iniciado sesión.
  String? registeredEmail; // Almacena el correo electrónico registrado.
  String? registeredPassword; // Almacena la contraseña registrada.

  void register() async {
    // Función para registrar un usuario.
    final result = await Navigator.pushNamed(
      context,
      '/register',
    ); // Abre la pantalla de registro y espera un resultado.
    if (result != null && result is Map<String, String>) {
      // Comprueba si se recibió un resultado válido.
      setState(() {
        // Actualiza el estado de la aplicación.
        isRegistered = true;
        registeredEmail = result['email']; // Almacena el correo electrónico registrado.
        registeredPassword =  result['password']; // Almacena la contraseña registrada.
        //registeredEmail = "savvy@gmail.com";
        //registeredPassword = "12345";
      });
    }
  }

  void login() async {
    final enteredEmail = emailController.text.trim();
    final enteredPassword = passwordController.text;

    try {
      // Cambiado a 'users', que es el nombre de tu colección
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: enteredEmail)
          .where('password', isEqualTo: enteredPassword)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Usuario encontrado
        setState(() {
          isLoggedIn = true;
        });
      } else {
        // Usuario no encontrado o credenciales incorrectas
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error de inicio de sesión'),
              content: Text('Credenciales incorrectas. Verifica tu correo y contraseña.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cerrar'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error al intentar iniciar sesión: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Hubo un error al conectar con la base de datos.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Método para construir la interfaz de AuthScreen.
    if (isLoggedIn) {
      // Si el usuario ha iniciado sesión, muestra la pantalla HelloWorldScreen.
      return HelloWorldScreen();
    } else {
      // Si no ha iniciado sesión, muestra la pantalla de inicio de sesión o registro.
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(6, 145, 154, 1),
          centerTitle: true,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Savvy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '¡Gasta mejor, Ahorra más!',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: InkWell(
                  onTap: () {
                    launchUrl(
                      Uri.parse('https://www.youtube.com/watch?v=1hj7XWHUNd0r'),
                    ); // URL a abrir
                  },
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 200,
                    height: 200,
                  ),
                ),
              ),

              SizedBox(height: 20),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ),

              SizedBox(height: 20), // Espacio antes del botón

              ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(
                    6,
                    145,
                    154,
                    1,
                  ), // Color #06919A en RGB
                  foregroundColor: Colors.white, // Color del texto
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Bordes cuadrados
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ), // Tamaño del botón
                ),
                child: Text('Iniciar Sesión'),
              ),

              TextButton(
                onPressed: register,
                child: Text('¿No tienes una cuenta?'),
              ),
              TextButton(onPressed: register, child: Text('Regístrate aquí.')),
            ],
          ),
        ),
      );
    }
  }
}

class HelloWorldScreen extends StatefulWidget {
  //const HelloWorldScreen({super.key});

  @override
  _HelloWorldScreenState createState() => _HelloWorldScreenState();
}

class _HelloWorldScreenState extends State<HelloWorldScreen> {
  // Define una clase llamada HelloWorldScreen que extiende StatelessWidget.
  @override
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Método para construir la interfaz de HelloWorldScreen.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(6, 145, 154, 1),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Index',
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

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300,
              child: Recuadro(
                titulo: 'Ahorros Mensuales',
                monto: '\$1,234.56',
                porcentaje: '+12.34%',
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: Recuadro(
                titulo: 'Ahorro Objetivo',
                monto: '\$1,234.56',
                porcentaje: '+12.34%',
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: Recuadro(
                titulo: 'Gastos',
                monto: '\$1,234.56',
                porcentaje: '+12.34%',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(
            icon: SizedBox(width: 24, height: 24),
            label: '',
          ),
        ],
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

//pantalla configuración
//clase recuadro pantalla principal


class Recuadro extends StatelessWidget {
  final String titulo;
  final String monto;
  final String porcentaje;

  const Recuadro({
    //super.key,
    required this.titulo,
    required this.monto,
    required this.porcentaje,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      decoration: BoxDecoration(
        color: Colors.teal.shade200,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8.0),
          Text(
            monto,
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              porcentaje,
              style: TextStyle(fontSize: 12.0, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}




