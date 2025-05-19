import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(6, 145, 154, 1),
        centerTitle: true,
        title: Text('Registro', style: TextStyle(color: Colors.white)),
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
                obscureText: true,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final email = registerEmailController.text.trim();
                  final password = registerPasswordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Por favor completa todos los campos')),
                    );
                    return;
                  }

                  UserCredential userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(email: email, password: password);

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userCredential.user!.uid)
                      .set({
                    'email': email,
                    'created_at': Timestamp.now(),
                  });

                  if (!mounted) return;

                  // Quitar snackbar temporalmente
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(content: Text('¡Registro exitoso!')),
                  // );

                  print('Registro exitoso. Navegando a /');

                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);

                } on FirebaseAuthException catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.message}')),
                  );
                }
              },
              child: Text('Registrarse'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(6, 145, 154, 1),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
