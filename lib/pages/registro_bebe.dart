import 'package:flutter/material.dart';
import 'package:flutter_login/gradient.dart';
import 'package:flutter_login/pages/PerfilContinuacion/perfilnuevo.dart';

class RegistroBebe extends StatefulWidget {
  const RegistroBebe({Key? key}) : super(key: key);
  @override
  _RegistroBebeState createState() => _RegistroBebeState();
}

class _RegistroBebeState extends State<RegistroBebe> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(gradient: Gradients.myGradient),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.only(
                                top: 110), // Agregar margen inferior
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 156, 155, 155)
                                      .withOpacity(0.5),
                                  spreadRadius: 0.1,
                                  blurRadius: 5,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Registro del Bebé',
                                  style: TextStyle(
                                    fontSize: 33,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(162, 0, 0, 0),
                                    shadows: [
                                      Shadow(
                                        color:
                                            Color.fromARGB(115, 148, 144, 144),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                                _buildTextField("Nombre", Icons.child_care),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Flexible(
                                      flex: 2, // Ajustar la flexibilidad
                                      child: _buildTextField(
                                          "Fecha de Nacimiento",
                                          Icons.date_range),
                                    ),
                                    SizedBox(
                                        width: 10), // Espacio entre los campos
                                    Flexible(
                                      flex: 1, // Ajustar la flexibilidad
                                      child: _buildTextField(
                                          "Hora", Icons.hourglass_empty),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                    "Lugar de Nacimiento", Icons.place),
                                const SizedBox(height: 20),
                                _buildTextField(
                                    "Peso al nacer", Icons.accessibility_new),
                                const SizedBox(height: 20),
                                _buildTextField(
                                    "Edad Gestacional", Icons.child_care),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Flexible(
                                      flex: 2, // Ajustar la flexibilidad
                                      child: _buildTextField(
                                          "Fecha de Lactancia",
                                          Icons.date_range),
                                    ),
                                    SizedBox(
                                        width: 10), // Espacio entre los campos
                                    Flexible(
                                      flex: 1, // Ajustar la flexibilidad
                                      child: _buildTextField(
                                          "Hora", Icons.hourglass_empty),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Perfilnuevo()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 3, 87, 140),
                                    fixedSize: const Size(320, 42),
                                    shape: const StadiumBorder(),
                                    shadowColor: Colors.black.withOpacity(0.5),
                                    elevation: 5,
                                  ),
                                  child: const Text(
                                    'Registrar',
                                    style: TextStyle(
                                        fontSize: 25, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Container(
                                  width: double.infinity,
                                  height: 1,
                                  color: Color.fromARGB(117, 209, 204, 204),
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ),
                          const SizedBox(height: 45),
                        ],
                      ),
                      Positioned(
                        top: 3,
                        left: 290,
                        right: 1,
                        child: Image.asset(
                          'assets/images/doctor.png',
                          height: 150,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, IconData icon) {
    return Container(
      height: 48,
      width: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
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
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 19,
            color: Color.fromARGB(255, 204, 202, 202),
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.grey,
            size: 24.0,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
