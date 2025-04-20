import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatelessWidget {
  //const RegisterScreen({super.key});

  // Define una clase llamada RegisterScreen que extiende StatelessWidget.
  @override
  Widget build(BuildContext context) {
    // Método para construir la interfaz de RegisterScreen.
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
              onPressed: () async  {
                final email = registerEmailController.text.trim(); // Obtiene el correo electrónico ingresado.
                final password  = registerPasswordController.text.trim(); // Obtiene la contraseña ingresada.
                
                await FirebaseFirestore.instance.collection('users').add({
                  'email': email,
                  'password': password, // ¡Recuerda! Nunca guardes contraseñas así en producción
                  'created_at': Timestamp.now(),
                });

                Navigator.pop(context);
                
                /*final result = {
                  'email': email,
                  'password': password ,
                }; // Crea un mapa con los datos de registro.*/

                /*Navigator.pop(
                  context,
                  result,
                );*/
                 // Cierra la pantalla de registro y devuelve los datos al estado anterior.
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