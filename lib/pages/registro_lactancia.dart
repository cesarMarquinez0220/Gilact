// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../gradient.dart';
import 'PerfilContinuacion/user_data_storage.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:flutter_login/pages/registro_page.dart';

class RegistroLactancia extends StatefulWidget {
  const RegistroLactancia({Key? key}) : super(key: key);

  @override
  _RegistroLactanciaState createState() => _RegistroLactanciaState();
}

class _RegistroLactanciaState extends State<RegistroLactancia> {
  String seleccionVolumenDeExtraccion = 'No';
  String seleccionSuenoUnidad = 'No';
  String seleccionFormula = 'Ninguna';
  TextEditingController volumenExtraccionController = TextEditingController();
  TextEditingController horasSuenotroller = TextEditingController();
  TextEditingController aceptacionPecho = TextEditingController();
  TextEditingController vecesPecho = TextEditingController();
  TextEditingController vecesBiberon = TextEditingController();


  Future<void> _guardarDatos() async {
    final email = UserDataStorage.getUserEmail();

    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      print("aqui esta el user snapshot $usersSnapshot");
      print("aqui esta el email del usuario $email");

      if (usersSnapshot.docs.isNotEmpty) {
        // El usuario existe
        DocumentSnapshot userDocument = usersSnapshot.docs.first;
        String userId = userDocument.id;

        // Referencia al documento de situación del usuario
        DocumentReference situacionDocRef = FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('situacion')
            .doc('Post-Parto');

        // Obtener los datos del documento 'Post-Parto'
        DocumentSnapshot situacionSnapshot = await situacionDocRef.get();

        if (situacionSnapshot.exists) {
          // Documento 'Post-Parto' existe, guardar los datos
          Map<String, dynamic> datosLactancia = {
            'volumen_extraccion':
                _parseNumber(volumenExtraccionController.text),
            'unidad': seleccionVolumenDeExtraccion,
            'veces_biberon': _parseNumber(vecesBiberon.text),
            'veces_pecho': _parseNumber(vecesPecho.text),
            'pecho_dado': seleccionFormula,
            "Horas_sueño_bebe": _parseNumber(horasSuenotroller.text),
            'unidad_horas': seleccionSuenoUnidad,
            'timestamp': Timestamp.now(), // marca de tiempo
          };

          // Guardar los datos
          await situacionDocRef.collection('lactancia').add(datosLactancia);

          _showDialog(
            context,
            'Éxito',
            'Datos de lactancia registrados.',
          );
        } else {
          // Documento 'Post-Parto' no existe, mostrar mensaje
          _showDialog(
            context,
            'Advertencia',
            'Debes cambiar la situación a Post-Parto para registrar la lactancia.',
          );
        }
      } else {
        // El usuario no existe
        _showDialog(
          context,
          'Advertencia',
          'El usuario no existe en la base de datos.',
        );
      }
    } catch (e) {
      // Manejo de errores
      _showDialog(
        context,
        'Error',
        'Error al guardar los datos: $e',
      );
    }
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo requerido';
    }

    final intValue = int.tryParse(value);
    if (intValue == null || intValue < 0 || intValue > 1000) {
      return 'Por favor ingrese un número válido entre 0 y 10000';
    }

    return null;
  }

  int _parseNumber(String text) {
    if (text.isEmpty) {
      return 0;
    }
    final intValue = int.tryParse(text);
    return intValue ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        // Ancho igual al ancho de la pantalla
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(gradient: Gradients.myGradient),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 150),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 156, 155, 155)
                          .withOpacity(0.5),
                      spreadRadius: 0.1,
                      blurRadius: 5,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    const Text(
                      'Registro Lactancia',
                      style: TextStyle(
                        fontSize: 33,
                        fontWeight: FontWeight.w600,
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
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 3, // Ajusta la proporción según sea necesario
                            child: _buildTextField(
                              hintText: "Volumen de extracción",
                              icon: Icons.local_drink,
                              controller: volumenExtraccionController,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            flex: 1, // Ajusta la proporción según sea necesario
                            child: SizedBox(
                              width: double
                                  .infinity, // Asegura que el dropdown ocupe todo el espacio disponible
                              child: _buildDropdownField(
                                "Unidad",
                                ["No", "ml", "oz"],
                                seleccionVolumenDeExtraccion,
                                (newValue) {
                                  setState(() {
                                    seleccionVolumenDeExtraccion = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                      child: _buildTextField(
                          hintText: "Veces que se le dio biberón",
                          icon: Icons.child_care,
                          controller: vecesBiberon),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                      child: _buildTextField(
                          hintText: "Veces que se le dio pecho",
                          icon: Icons.nature_people_sharp,
                          controller: vecesPecho),
                    ),
                    const SizedBox(height: 10), //espacio entremedio
                    //dropdown de formula
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildTextField(
                              hintText: "Horas/minutos de Sueño del bebé",
                              icon: Icons.timer_sharp,
                              controller: horasSuenotroller,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 100, // Ajusta este valor según sea necesario
                            child: _buildDropdownField(
                              "Unidad",
                              ["No", "Hrs", "Min"],
                              seleccionSuenoUnidad,
                              (newValue) {
                                setState(() {
                                  seleccionSuenoUnidad = newValue!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10), //espacio entremedio
                    Text(
                      "Pecho que dio a amamantar",
                      style: GoogleFonts.quicksand(
                          fontSize: 14,
                          color: const Color.fromARGB(169, 1, 3, 3)),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text(
                                  'Izquierdo',
                                  style: GoogleFonts.quicksand(
                                      fontSize: 18, color: Colors.black),
                                ),
                                value: 'Izquierdo',
                                groupValue: seleccionFormula,
                                onChanged: (String? value) {
                                  setState(() {
                                    seleccionFormula = value!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text(
                                  'Derecha',
                                  style: GoogleFonts.quicksand(
                                      fontSize: 18, color: Colors.black),
                                ),
                                value: 'Derecha',
                                groupValue: seleccionFormula,
                                onChanged: (String? value) {
                                  setState(() {
                                    seleccionFormula = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        RadioListTile<String>(
                          title: Text(
                            'Ninguna',
                            style: GoogleFonts.quicksand(
                                fontSize: 18, color: Colors.black),
                          ),
                          value: 'Ninguna',
                          groupValue: seleccionFormula,
                          onChanged: (String? value) {
                            setState(() {
                              seleccionFormula = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10), //espacio entremedio

                    SizedBox(
                      width: 320,
                      child: ElevatedButton(
                        onPressed: _guardarDatos,
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
                          ('Registrar'),
                          style: GoogleFonts.quicksand(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    TextEditingController? controller,
    FocusNode? focusNode,
    VoidCallback? onTap,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 48,
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
        focusNode: focusNode,
        onTap: onTap,
        obscureText: obscureText,
        validator: validator ?? _validateNumber,
        keyboardType: TextInputType.number,
        style: GoogleFonts.quicksand(
            fontSize: 15, color: Colors.black, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.quicksand(
            fontSize: 15,
            color: const Color.fromARGB(255, 204, 202, 202),
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
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }

  Widget _buildDropdownField(
    String hintText,
    List<String> options,
    String selectedValue,
    Function(String?) onChanged,
  ) {
    return Container(
      height: 48,
      width: 320,
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
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: GoogleFonts.quicksand(
                fontSize: 15,
                color: Colors.black, // Ajusta el color del texto aquí
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.quicksand(
            fontSize: 15,
            color: const Color.fromARGB(255, 204, 202, 202),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
        dropdownColor: Colors.white,
      ),
    );
  }
}
