import 'package:flutter/material.dart';

class DialogExample {
  static void showAlertDialog(
      BuildContext context, String title, String message) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          title,
          textAlign: TextAlign.center,
          style:const TextStyle(color: Color.fromARGB(255, 253, 40, 40)),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showUserAlreadyExistsDialog(BuildContext context) {
    showAlertDialog(
      context,
      'Alerta',
      'El usuario ya está registrado.',
    );
  }
}
