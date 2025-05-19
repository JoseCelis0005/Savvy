import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla de Prueba'),
        backgroundColor: Color.fromRGBO(6, 145, 154, 1),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('¡Has llegado a la pantalla de prueba!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Volver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(6, 145, 154, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
