import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Importa la librería Flutter
void main() {
  runApp(MyApp()); // Llama a la función runApp para iniciar la aplicación Flutter.
}


class MyApp extends StatelessWidget { // Define una clase llamada MyApp que extiende StatelessWidget.
  @override
  Widget build(BuildContext context) { // Define el método build para construir la interfaz de la aplicación.
    return MaterialApp(
      title: 'Savvy', // Título de la aplicación.
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue, // Configura el tema de la aplicación con un color azul.
      ),
      initialRoute: '/', // Ruta inicial de la aplicación.
      routes: {
        '/': (context) => AuthScreen(), // Define una ruta llamada '/' que muestra AuthScreen.
        '/register': (context) => RegisterScreen(), // Define una ruta llamada '/register' que muestra RegisterScreen.
      },
    );
  }
}
class AuthScreen extends StatefulWidget { // Define una clase llamada AuthScreen que extiende StatefulWidget.
  @override
  _AuthScreenState createState() => _AuthScreenState(); // Crea el estado para AuthScreen.
}

class _AuthScreenState extends State<AuthScreen> { // Define el estado de AuthScreen.
  TextEditingController emailController = TextEditingController(); // Controlador para el campo de correo electrónico.
  TextEditingController passwordController = TextEditingController(); // Controlador para el campo de contraseña.
  bool isRegistered = false; // Variable booleana que indica si el usuario está registrado.
  bool isLoggedIn = false; // Variable booleana que indica si el usuario ha iniciado sesión.
  String? registeredEmail; // Almacena el correo electrónico registrado.
  String? registeredPassword; // Almacena la contraseña registrada.

  void register() async { // Función para registrar un usuario.
    final result = await Navigator.pushNamed(context, '/register'); // Abre la pantalla de registro y espera un resultado.
    if (result != null && result is Map<String, String>) { // Comprueba si se recibió un resultado válido.
      setState(() { // Actualiza el estado de la aplicación.
        isRegistered = true;
        registeredEmail = result['email']; // Almacena el correo electrónico registrado.
        registeredPassword = result['password']; // Almacena la contraseña registrada.
        //registeredEmail = "savvy@gmail.com";
        //registeredPassword = "12345";
      });
    }
  }

  void login() { // Función para iniciar sesión.
    if (isRegistered) { // Comprueba si el usuario está registrado.
      final enteredEmail = emailController.text; // Obtiene el correo electrónico ingresado.
      final enteredPassword = passwordController.text; // Obtiene la contraseña ingresada.
      if (enteredEmail == registeredEmail && enteredPassword == registeredPassword) { // Comprueba las credenciales.
        setState(() { // Actualiza el estado de la aplicación.
          isLoggedIn = true; // Marca al usuario como autenticado.
        });
      } else { // Credenciales incorrectas, muestra un diálogo de error.
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
    } else { // El usuario no está registrado, muestra un diálogo de error.
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
  Widget build(BuildContext context) { // Método para construir la interfaz de AuthScreen.
    if (isLoggedIn) { // Si el usuario ha iniciado sesión, muestra la pantalla HelloWorldScreen.
      return HelloWorldScreen();
    } else { // Si no ha iniciado sesión, muestra la pantalla de inicio de sesión o registro.
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
                style: TextStyle(
                  color: Colors.white70, 
                  fontSize: 14,
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
                child: InkWell(
                  onTap: () {
                    launchUrl(Uri.parse('https://www.youtube.com/watch?v=1hj7XWHUNd0r')); // URL a abrir
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
                  backgroundColor: Color.fromRGBO(6, 145, 154, 1), // Color #06919A en RGB
                  foregroundColor: Colors.white, // Color del texto
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // Bordes cuadrados
                  ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Tamaño del botón
                ),
                child: Text('Iniciar Sesión'),
              ),

              TextButton(
                onPressed: register, 
                child: Text('¿No tienes una cuenta?'),
              ),
              TextButton(
                onPressed: register, 
                child: Text('Regístrate aquí.'),
              ),
            ],
          ),
        )
      );
    }
  }
}

class RegisterScreen extends StatelessWidget { // Define una clase llamada RegisterScreen que extiende StatelessWidget.
  @override
  Widget build(BuildContext context) { // Método para construir la interfaz de RegisterScreen.
    TextEditingController registerEmailController = TextEditingController(); // Controlador para el correo electrónico de registro.
    TextEditingController registerPasswordController = TextEditingController(); // Controlador para la contraseña de registro.

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
                final registerEmail = registerEmailController.text; // Obtiene el correo electrónico ingresado.
                final registerPassword = registerPasswordController.text; // Obtiene la contraseña ingresada.
                final result = {'email': registerEmail, 'password': registerPassword}; // Crea un mapa con los datos de registro.
                Navigator.pop(context, result); // Cierra la pantalla de registro y devuelve los datos al estado anterior.
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(6, 145, 154, 1), // Color #06919A en RGB
                  foregroundColor: Colors.white, // Color del texto
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // Bordes cuadrados
                  ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Tamaño del botón
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


class _HelloWorldScreenState extends State<HelloWorldScreen> { // Define una clase llamada HelloWorldScreen que extiende StatelessWidget.
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

      /*body: Center(
        child: Text(
          '¡Bienvenido! Has iniciado sesión exitosamente.',
          style: TextStyle(fontSize: 24),
        ),
      ),*/
       body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            

            Center(
              child: Container(
                width: 250,
                height: 150,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 11), 
                      child: InkWell(
                        onTap: () {
                          launchUrl(Uri.parse('https://www.instagram.com/reel/DHXj1ASulli/?utm_source=ig_web_copy_link')); // URL a abrir
                        },
                        child: Image.asset(
                          "assets/images/insta.jpeg",
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 11), 
                      child: InkWell(
                        onTap: () {
                          launchUrl(Uri.parse('https://www.facebook.com/photo/?fbid=1046150224207969&set=a.549251397231190')); // URL a abrir
                        },
                        child: Image.asset(
                          "assets/images/face.jpg",
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Center(
              child: Container(
                width: 250,
                height: 150,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 11), 
                      child: InkWell(
                        onTap: () {
                          launchUrl(Uri.parse('https://co.pinterest.com/pin/5136987069893143/')); // URL a abrir
                        },
                        child: Image.asset(
                          'assets/images/wpp.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 11), 
                      child: InkWell(
                        onTap: () {
                          launchUrl(Uri.parse('https://co.pinterest.com/pin/2814818511868237/')); // URL a abrir
                        },
                        child: Image.asset(
                          "assets/images/yutu.png",
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => AuthScreen()), 
                  (route) => false, 
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(6, 145, 154, 1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, 
                  ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Tamaño del botón
              ),
              child: Text('Volver'),
            ),
            

          ],
        ),
       ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Buscar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      
    );
  }
}