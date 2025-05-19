import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void register() async {
    final result = await Navigator.pushNamed(context, '/register');
    if (result != null && result is Map<String, String>) {
      // Aquí puedes usar los datos si quieres, aunque el login no depende de ellos
    }
  }

  void login() async {
    final enteredEmail = emailController.text.trim();
    final enteredPassword = passwordController.text.trim();
    
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: enteredEmail,
        password: enteredPassword,
      );
      print('Login exitoso para usuario: ${userCredential.user?.email}');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
      print('Navegación a /test ejecutada');
    } on FirebaseAuthException catch (e) {
      print('Error FirebaseAuthException: ${e.message}');
      _mostrarAlerta('Error Firebase: ${e.message}');
    } catch (e) {
      print('Error inesperado: $e');
      _mostrarAlerta('Error inesperado: $e');
    }
  }

  void _mostrarAlerta(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Autenticación'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView( // para que no falle en pantallas pequeñas
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: () {
                  launchUrl(Uri.parse('https://www.youtube.com/watch?v=1hj7XWHUNd0r'));
                },
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 200,
                  height: 200,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(6, 145, 154, 1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text('Iniciar Sesión'),
              ),
              TextButton(
                onPressed: register,
                child: Text('¿No tienes una cuenta? Regístrate aquí.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
