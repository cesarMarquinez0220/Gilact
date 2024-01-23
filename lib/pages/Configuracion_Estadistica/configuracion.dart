import 'package:flutter/material.dart';
import 'package:flutter_login/gradient.dart';

import 'package:provider/provider.dart';

class ConfiguracionScreen extends StatelessWidget {
  final TextEditingController _comentariosController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text('Configuración'),
        backgroundColor: Colors.transparent, // Fondo transparente

      ),

      body: Container(
         width: double.infinity, // Establece el ancho al máximo
      height: double.infinity, // Establece la altura al máximo
        decoration: BoxDecoration(
          gradient: Gradientslogin.myGradient
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tema',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SwitchListTile(
                  title: Text('Tema Oscuro/Claro'),
                  value: Provider.of<TemaProvider>(context).temaOscuro,
                  onChanged: (value) {
                    Provider.of<TemaProvider>(context, listen: false)
                        .cambiarTema(value);
                  },
                ),
                Divider(),
                Text(
                  'Notificaciones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SwitchListTile(
                  title: Text('Recibir notificaciones'),
                  value: Provider.of<NotificacionesProvider>(context)
                      .recibirNotificaciones,
                  onChanged: (value) {
                    Provider.of<NotificacionesProvider>(context, listen: false)
                        .cambiarNotificaciones(value);
                  },
                ),
                
                Divider(),
                Text(
                  'Cuenta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Enviar un formulario de sugerencias de la aplicación',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                // Formulario de comentarios o sugerencias
                SizedBox(height: 8),
                TextField(
                  controller: _comentariosController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Escribe tus comentarios o sugerencias aquí...',
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _enviarComentarios(context);
                    },
                    child: Text('Enviar'),
                  ),
                ),
                // Fin del formulario
                
                Divider(),
                Text(
                  'Versión de la Aplicación',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Versión 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                // Muestra la versión actual de la aplicación y permite a los usuarios actualizar si hay una versión más reciente disponible
                
                Divider(),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Implementa la lógica para cerrar sesión o realizar acciones adicionales
                      Provider.of<AutenticacionProvider>(context, listen: false)
                          .cerrarSesion();
                    },
                    child: Text('Cerrar sesión'),
                  ),
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
        duration: Duration(seconds: 2),
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
