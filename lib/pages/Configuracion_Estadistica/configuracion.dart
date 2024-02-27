import 'package:flutter/material.dart';
import 'package:flutter_login/pages/completeinfo/shape_decoration/shape.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: use_key_in_widget_constructors
class ConfiguracionScreen extends StatelessWidget {
  final TextEditingController _comentariosController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Container(
            child: Stack(
              children: [
                Positioned(
                  top: -height * .12,
                  right: width * .05,
                  child: const BezierContainer(),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Configuración',
                        style: GoogleFonts.quicksand(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // SizedBox(height: MediaQuery.of(context).size.height * .05),
                    Text(
                      'Cuenta',
                      style: GoogleFonts.quicksand(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        'Enviar un formulario de sugerencias de la aplicación',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // Formulario de comentarios o sugerencias
                    const SizedBox(height: 8),
                    Container(
                      height: MediaQuery.sizeOf(context).height * 0.2,
                      width: MediaQuery.sizeOf(context).width * 0.9,
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset:
                              const Offset(2, 5), // changes position of hadow
                        ),
                      ], color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: TextField(
                          controller: _comentariosController,
                          maxLines: 5,
                          maxLength: 250,
                          decoration: InputDecoration(
                              hintText:
                                  'Escribe tus comentarios o sugerencias aquí...',
                              hintStyle: GoogleFonts.quicksand()),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.4,
                        height: MediaQuery.sizeOf(context).height * 0.07,
                        child: ElevatedButton(
                          onPressed: () {
                            _enviarComentarios(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(27, 167, 214, 1),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            shadowColor: Colors.black.withOpacity(0.5),
                            elevation: 5,
                          ),
                          child: Text(
                            'Enviar',
                            style: GoogleFonts.quicksand(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    // Fin del formulario

                    const Divider(),
                    Text(
                      'Versión de la Aplicación',
                      style: GoogleFonts.quicksand(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        'Versión 0.0.1',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // Muestra la versión actual de la aplicación y permite a los usuarios actualizar si hay una versión más reciente disponible

                    const Divider(),
                    GestureDetector(
                      onTap: () {
                        print('Cerrando sesión...');
                      },
                      child: Center(
                        child: Text(
                          'Cerrar sesión',
                          style: GoogleFonts.quicksand(
                              fontSize: 18,
                              color: Colors.red,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.1 - 270,
                  right: MediaQuery.of(context).size.width * 0.1 + 120,
                  child: const Ovalstatic(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _enviarComentarios(BuildContext context) {
    final String comentarios = _comentariosController.text;
    // Aquí puedes implementar la lógica para enviar los comentarios.
    // Puedes enviarlos a un servidor, almacenarlos localmente, etc.

    // Después de enviar, puedes limpiar el campo de comentarios
    _comentariosController.clear();

    // Puedes mostrar un mensaje al usuario indicando que los comentarios se enviaron correctamente.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Comentarios enviados: $comentarios'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Proveedores

class TemaProvider extends ChangeNotifier {
  bool _temaOscuro = false;

  bool get temaOscuro => _temaOscuro;

  void cambiarTema(bool nuevoTema) {
    _temaOscuro = nuevoTema;
    notifyListeners();
  }
}

class NotificacionesProvider extends ChangeNotifier {
  bool _recibirNotificaciones = true;

  bool get recibirNotificaciones => _recibirNotificaciones;

  void cambiarNotificaciones(bool nuevoValor) {
    _recibirNotificaciones = nuevoValor;
    notifyListeners();
  }
}

class AutenticacionProvider extends ChangeNotifier {
  // Agrega aquí la lógica para cerrar sesión
  void cerrarSesion() {
    // Implementa la lógica necesaria para cerrar sesión
    // Esto puede incluir la eliminación de tokens, limpiar datos de usuario, etc.
    notifyListeners();
  }
}
