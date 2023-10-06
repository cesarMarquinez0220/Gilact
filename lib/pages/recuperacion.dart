import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/gradient.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class recuperacion extends StatefulWidget {
  const recuperacion({Key? key}) : super(key: key);

  @override
  _RecuperacionState createState() => _RecuperacionState();
}

class _RecuperacionState extends State<recuperacion> {
  TextEditingController email = TextEditingController();
  bool isUserValid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(gradient: Gradients.myGradient),
          child: SingleChildScrollView(
            child: _buildPortraitLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required IconData icon,
    TextEditingController? controller,
    bool obscureText = false,
  }) {
    return Container(
      height: 48,
      width: 300,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color.fromARGB(255, 255, 255, 255),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 156, 155, 155).withOpacity(0.5),
            spreadRadius: 0.1,
            blurRadius: 5,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 18, color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 204, 202, 202),
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.grey,
            size: 24.0,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Container(
      padding: const EdgeInsets.only(top: 260, bottom: 30, left: 20, right: 20),
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 320,
              constraints: const BoxConstraints(maxWidth: 360),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color.fromARGB(251, 255, 255, 255),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 25),
                  const Text(
                    'Restablecer',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(162, 0, 0, 0),
                    ),
                    textAlign: TextAlign.start,
                  ),
                  _buildInputField(
                    hintText: "Email",
                    icon: Icons.email,
                    controller: email,
                  ),
                  const SizedBox(height: 15),
                  _buildButton(
                    context,
                    'Enviar',
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Volver',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 45),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text) {
    return SizedBox(
      width: 300,
      child: ElevatedButton(
        onPressed: () async {
          final emailToFind = email.text;
          final userSnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .where('email', isEqualTo: emailToFind)
              .get();

          if (userSnapshot.size > 0) {
            final user = userSnapshot.docs.first;
            final userEmail = user['email'];
            final userPassword = user['contrasena'];

            final smtpServer =
                gmail('soportemedica.ayuda@gmail.com', 'G!tcesoporte!2023');

            final message = Message()
              ..from = Address('soportemedica.ayuda@gmail.com', 'Soporte App')
              ..recipients.add(userEmail)
              ..subject = 'Recuperación de contraseña'
              ..text = 'Tu contraseña es: $userPassword';

            try {
              final sendReport = await send(message, smtpServer);
              print('Mensaje enviado: ${sendReport.toString()}');
            } catch (e) {
              print('Error al enviar el mensaje: $e');
            }
          } else {
            print('No se encontró ningún usuario con ese correo electrónico.');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 3, 87, 140),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          shadowColor: Colors.black.withOpacity(0.5),
          elevation: 5,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
