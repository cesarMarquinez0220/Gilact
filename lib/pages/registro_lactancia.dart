import 'package:flutter/material.dart';
import 'package:flutter_login/gradient.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:flutter_login/pages/registro_page.dart';

class RegistroLactancia extends StatefulWidget {
  const RegistroLactancia({Key? key}) : super(key: key);

  @override
  _RegistroLactanciaState createState() => _RegistroLactanciaState();
}

class _RegistroLactanciaState extends State<RegistroLactancia> {
  String seleccionVolumenDeExtraccion = 'Opción 1';
  String seleccionMaterna = 'Opción 1';
  String seleccionFormula = 'Opción 1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Ancho igual al ancho de la pantalla
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(gradient: Gradients.myGradient),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 150),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Color.fromARGB(255, 156, 155, 155).withOpacity(0.5),
                      spreadRadius: 0.1,
                      blurRadius: 5,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Text(
                      'Registro Lactancia',
                      style: GoogleFonts.quicksand(
                        fontSize: 33,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(162, 0, 0, 0),
                        shadows: [
                          Shadow(
                            color: Color.fromARGB(115, 148, 144, 144),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildDropdownField(
                      "Volumen de extracción de leche",
                      ["Opción 1", "Opción 2", "Opción 3"],
                      seleccionVolumenDeExtraccion,
                      (newValue) {
                        setState(() {
                          seleccionVolumenDeExtraccion = newValue!;
                        });
                      },
                      Icons.format_color_fill,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      child: Text(
                        "Veces que se le dio biberón:",
                        style: GoogleFonts.quicksand(
                            color: Color.fromRGBO(1, 3, 3, 200)),
                      ),
                    ),
                    //dropdown de materna
                    _buildDropdownField(
                      "Materna",
                      ["Opción 1", "Opción 2", "Opción 3"],
                      seleccionMaterna,
                      (newValue) {
                        setState(() {
                          seleccionMaterna = newValue!;
                        });
                      },
                      Icons.child_friendly,
                    ),
                    const SizedBox(height: 10), //espacio entremedio
                    //dropdown de formula
                    _buildDropdownField(
                      "Fórmula",
                      ["Opción 1", "Opción 2", "Opción 3"],
                      seleccionFormula,
                      (newValue) {
                        setState(() {
                          seleccionFormula = newValue!;
                        });
                      },
                      Icons.local_drink,
                    ),
                    const SizedBox(height: 10), //espacio entremedio
                    _buildTextField("Horas de Sueño", Icons.timer_sharp),
                    const SizedBox(height: 10), //espacio entremedio
                    _buildTextField("Aceptación de pecho", Icons.child_care),
                    const SizedBox(height: 15), //espacio entremedio
                    ElevatedButton(
                      onPressed: () {
                        // Lógica del botón de registro
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 3, 87, 140),
                        fixedSize: const Size(320, 42),
                        shape: const StadiumBorder(),
                        shadowColor: Colors.black.withOpacity(0.5),
                        elevation: 5,
                      ),
                      child: Text(
                        'Registrar',
                        style: GoogleFonts.quicksand(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Color.fromARGB(117, 209, 204, 205),
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        // Lógica para redirigir a la pantalla anterior
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Volver',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox(height: 45), //espacio entremedio
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, IconData icon) {
    return Container(
      height: 42,
      width: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 156, 155, 155).withOpacity(0.5),
            spreadRadius: 0.1,
            blurRadius: 5,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.quicksand(
            fontSize: 17,
            color: Color.fromARGB(255, 204, 202, 202),
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.grey,
            size: 24.0,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String hintText,
    List<String> options,
    String selectedValue,
    Function(String?) onChanged,
    IconData icon,
  ) {
    return Container(
      height: 42,
      width: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 156, 155, 155).withOpacity(0.5),
            spreadRadius: 0.1,
            blurRadius: 5,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: DropdownButtonFormField(
        value: selectedValue,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.quicksand(
            fontSize: 17,
            color: Colors.grey,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.grey,
            size: 24.0,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}