import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar Firebase Auth
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Para las traducciones

class ConfigSesionScreen extends StatelessWidget {
  const ConfigSesionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final userEmail =
        user?.email ??
        l10n.unknownUser; // Obtener el email del usuario o un placeholder

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.sessionSettings,
        ), // Puedes crear una clave para esto en tu arb.
        backgroundColor: const Color.fromRGBO(6, 145, 154, 1),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 80, color: Colors.teal),
            const SizedBox(height: 20),
            Text(
              '${l10n.loggedInAs}: $userEmail', // "Sesión iniciada como: [email]"
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  // Navegar a la pantalla de inicio (generalmente la de login)
                  // y eliminar todas las rutas anteriores de la pila.
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/', // Asume que '/' es tu ruta inicial/de login
                    (Route<dynamic> route) => false,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.logoutSuccess),
                    ), // "Sesión cerrada con éxito"
                  );
                } catch (e) {
                  // Manejar cualquier error durante el cierre de sesión
                  print("Error al cerrar sesión: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l10n.logoutError}: $e'),
                    ), // "Error al cerrar sesión"
                  );
                }
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: Text(
                l10n.logoutButton, // "Cerrar sesión" para el botón
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red.shade600, // Color rojo para acción de logout
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                ); // Volver a la pantalla anterior (Configuración)
              },
              child: Text(
                l10n.cancel, // "Cancelar"
                style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
