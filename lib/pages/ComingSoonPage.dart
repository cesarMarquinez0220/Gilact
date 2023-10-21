// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ComingSoonPage extends StatefulWidget {
  const ComingSoonPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ComingSoonPageState createState() => _ComingSoonPageState();
}

class _ComingSoonPageState extends State<ComingSoonPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this, // Usar "this" como vsync
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Fondo de la página (puedes cambiar la imagen)
          Image.asset(
            'assets/images/iluminacion_reparacion.jpeg',
            fit: BoxFit.cover,
          ),
          // Contenido del centro de la página
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Puedes agregar un logo o imagen aquí y hacer que rote
                RotationTransition(
                  turns: _controller,
                  child: Image.asset(
                    'assets/images/engranaje.png',
                    width: 150,
                    height: 150,
                  ),
                ),
                const SizedBox(height: 20),
                // Mensaje "Próximamente"
                const Text(
                  'Próximamente',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
