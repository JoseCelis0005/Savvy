import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Importa la librería Flutter
import 'package:circular_menu/circular_menu.dart'; //libreria para el menu circular

void main() {
  runApp(
    MyApp(),
  ); // Llama a la función runApp para iniciar la aplicación Flutter.
}

class MyApp extends StatelessWidget {
  // Define una clase llamada MyApp que extiende StatelessWidget.
  @override
  Widget build(BuildContext context) {
    // Define el método build para construir la interfaz de la aplicación.
    return MaterialApp(
      title: 'Savvy', // Título de la aplicación.
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch:
            Colors
                .blue, // Configura el tema de la aplicación con un color azul.
      ),
      initialRoute: '/', // Ruta inicial de la aplicación.
      routes: {
        '/':
            (context) =>
                AuthScreen(), // Define una ruta llamada '/' que muestra AuthScreen.
        '/register':
            (context) =>
                RegisterScreen(), // Define una ruta llamada '/register' que muestra RegisterScreen.
        '/logros': (context) => LogrosScreen(), //muestra la pantalla logros

        '/informes':
            (context) => InformesScreen(), //muestra la pantalla informes

        '/configuracion':
            (context) =>
                ConfiguracionScreen(), //muestra la pantalla configuración
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  // Define una clase llamada AuthScreen que extiende StatefulWidget.
  @override
  _AuthScreenState createState() => _AuthScreenState(); // Crea el estado para AuthScreen.
}

class _AuthScreenState extends State<AuthScreen> {
  // Define el estado de AuthScreen.
  TextEditingController emailController =
      TextEditingController(); // Controlador para el campo de correo electrónico.
  TextEditingController passwordController =
      TextEditingController(); // Controlador para el campo de contraseña.
  bool isRegistered =
      false; // Variable booleana que indica si el usuario está registrado.
  bool isLoggedIn =
      false; // Variable booleana que indica si el usuario ha iniciado sesión.
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
        registeredEmail =
            result['email']; // Almacena el correo electrónico registrado.
        registeredPassword =
            result['password']; // Almacena la contraseña registrada.
        //registeredEmail = "savvy@gmail.com";
        //registeredPassword = "12345";
      });
    }
  }

  void login() {
    // Función para iniciar sesión.
    if (isRegistered) {
      // Comprueba si el usuario está registrado.
      final enteredEmail =
          emailController.text; // Obtiene el correo electrónico ingresado.
      final enteredPassword =
          passwordController.text; // Obtiene la contraseña ingresada.
      if (enteredEmail == registeredEmail &&
          enteredPassword == registeredPassword) {
        // Comprueba las credenciales.
        setState(() {
          // Actualiza el estado de la aplicación.
          isLoggedIn = true; // Marca al usuario como autenticado.
        });
      } else {
        // Credenciales incorrectas, muestra un diálogo de error.
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error de inicio de sesión'),
              content: Text(
                'Credenciales incorrectas. Verifica tu correo y contraseña.',
              ),
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
    } else {
      // El usuario no está registrado, muestra un diálogo de error.
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error de inicio de sesión'),
            content: Text('Debes registrarte antes de iniciar sesión.'),
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

class RegisterScreen extends StatelessWidget {
  // Define una clase llamada RegisterScreen que extiende StatelessWidget.
  @override
  Widget build(BuildContext context) {
    // Método para construir la interfaz de RegisterScreen.
    TextEditingController registerEmailController =
        TextEditingController(); // Controlador para el correo electrónico de registro.
    TextEditingController registerPasswordController =
        TextEditingController(); // Controlador para la contraseña de registro.

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(6, 145, 154, 1),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Registro',
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: registerEmailController,
                decoration: InputDecoration(labelText: 'Correo Electrónico'),
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: registerPasswordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true, // Oculta el texto de la contraseña.
              ),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final registerEmail =
                    registerEmailController
                        .text; // Obtiene el correo electrónico ingresado.
                final registerPassword =
                    registerPasswordController
                        .text; // Obtiene la contraseña ingresada.
                final result = {
                  'email': registerEmail,
                  'password': registerPassword,
                }; // Crea un mapa con los datos de registro.
                Navigator.pop(
                  context,
                  result,
                ); // Cierra la pantalla de registro y devuelve los datos al estado anterior.
              },
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
              child: Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}

class HelloWorldScreen extends StatefulWidget {
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
            Container(
              width: 300,
              child: Recuadro(
                titulo: 'Ahorros Mensuales',
                monto: '\$1,234.56',
                porcentaje: '+12.34%',
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 300,
              child: Recuadro(
                titulo: 'Ahorro Objetivo',
                monto: '\$1,234.56',
                porcentaje: '+12.34%',
              ),
            ),
            SizedBox(height: 20),
            Container(
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

//pantalla logros
class LogrosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TUS LOGROS'),
        automaticallyImplyLeading:
            false, // Opcional: Quita la flecha de "volver" automática
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
                // Navegar a la pantalla de inicio (ajusta la ruta según tu app)
                Navigator.pushReplacementNamed(
                  context,
                  '/',
                ); // Ejemplo: '/' es la ruta de inicio
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
    );
  }
}

class LogroItem extends StatelessWidget {
  final String imagen;
  final String titulo;
  final String monto;
  final bool isNew;

  const LogroItem({
    Key? key,
    required this.imagen,
    required this.titulo,
    required this.monto,
    this.isNew = false,
  }) : super(key: key);

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

//pantalla informes
class InformesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('INFORMES')),
      body: // Aquí va el código para mostrar la pantalla de logros
      //  ... (Código de la pantalla de logros de la imagen)
      Center(
        child: Text("Pantalla de INFORMES", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

//pantalla configuración
class ConfiguracionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('configuracion')),
      body: // Aquí va el código para mostrar la pantalla de logros
      //  ... (Código de la pantalla de logros de la imagen)
      Center(
        child: Text(
          "Pantalla de CONFIGURACIÓN",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

//clase recuadro pantalla principal
class Recuadro extends StatelessWidget {
  final String titulo;
  final String monto;
  final String porcentaje;

  const Recuadro({
    Key? key,
    required this.titulo,
    required this.monto,
    required this.porcentaje,
  }) : super(key: key);

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
