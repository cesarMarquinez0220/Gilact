// ignore_for_file: library_private_types_in_public_api, camel_case_types, use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_login/gradient.dart';

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
}
