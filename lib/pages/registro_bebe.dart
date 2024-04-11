// ignore_for_file: library_private_types_in_public_api, use_super_parameters

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login/alerta_dialoge.dart';
import 'package:flutter_login/gradient.dart';
import 'package:flutter_login/pages/PerfilContinuacion/perfilnuevo.dart';
import 'package:flutter_login/pages/PerfilContinuacion/user_data_storage.dart';
import 'package:intl/intl.dart';

class RegistroBebe extends StatefulWidget {
  const RegistroBebe({Key? key}) : super(key: key);
  @override
  _RegistroBebeState createState() => _RegistroBebeState();
}

class _RegistroBebeState extends State<RegistroBebe> {
  TextEditingController bebeController = TextEditingController();
  TextEditingController fechaNacimientobebeController = TextEditingController();
  TextEditingController horaNacimientoController = TextEditingController();
  TextEditingController lugarnacimientoController = TextEditingController();
  TextEditingController pesoController = TextEditingController();
  TextEditingController edadController = TextEditingController();
  TextEditingController fechaLactanciaController = TextEditingController();
  TextEditingController menstruacionController = TextEditingController();
  TextEditingController horalactanciaController = TextEditingController();
  late FocusNode fechaNacimientobebeFocusnode,
      menstruacionFocusnode,
      fechaLactanciaFocusnode;

  final Firebase = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fechaNacimientobebeController = TextEditingController();
    menstruacionController = TextEditingController();
    fechaLactanciaController = TextEditingController();
    fechaNacimientobebeFocusnode = FocusNode();
    menstruacionFocusnode = FocusNode();
    fechaLactanciaFocusnode = FocusNode();
    //listeners
    fechaNacimientobebeController.addListener(_calcularEdadGestacional);
    menstruacionController.addListener(_calcularEdadGestacional);
  }

  @override
  void dispose() {
    fechaNacimientobebeController = TextEditingController();
    menstruacionController = TextEditingController();
    fechaLactanciaController = TextEditingController();
    fechaNacimientobebeFocusnode = FocusNode();
    menstruacionFocusnode = FocusNode();
    fechaLactanciaFocusnode = FocusNode();

    // Remover los listeners
    fechaNacimientobebeController.removeListener(_calcularEdadGestacional);
    menstruacionController.removeListener(_calcularEdadGestacional);
    super.dispose();
  }

//funcion para el selector de la fecha
  void _selectFechaNacimiento(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(3000),
    );
    if (picked != null) {
      setState(() {
        fechaNacimientobebeController.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

//funcion para calculo de edad gestacional
  void _calcularEdadGestacional() {
    // Verificar si ambos campos tienen datos
    if (fechaNacimientobebeController.text.isNotEmpty &&
        menstruacionController.text.isNotEmpty) {
      // Parsear las fechas
      DateTime fechaNacimiento =
          DateFormat('yyyy-MM-dd').parse(fechaNacimientobebeController.text);
      DateTime fechaMenstruacion =
          DateFormat('yyyy-MM-dd').parse(menstruacionController.text);

      // Calcular la diferencia en días
      Duration diferencia = fechaNacimiento.difference(fechaMenstruacion);

      // Calcular la edad gestacional en semanas
      int edadGestacionalSemanas = diferencia.inDays ~/ 7;

      // Mostrar la edad gestacional en el campo de texto correspondiente
      setState(() {
        edadController.text = edadGestacionalSemanas.toString();
      });
    }
  }

  void _selectMenstruacion(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(3000),
    );
    if (picked != null) {
      setState(() {
        menstruacionController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void calcGestacional(menstruacionController, fechaNacimientobebeController) {
    final DateTime? edadGestacional;
    edadGestacional = fechaNacimientobebeController - menstruacionController;
    print('La edad del nene es $edadGestacional');
  }

  _registerMDButtonPressed() async {
    String email = UserDataStorage.getUserEmail();

    // Inicializar Firebase si aún no está inicializado
    if (bebeController.text.isEmpty ||
        fechaNacimientobebeController.text.isEmpty ||
        lugarnacimientoController.text.isEmpty ||
        pesoController.text.isEmpty ||
        edadController.text.isEmpty ||
        menstruacionController.text.isEmpty) {
      DialogExample.showAlertDialog(
        context,
        'Alerta',
        'Todos los campos son obligatorios',
      );
      return false;
    }

    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        // El usuario ya existe en la base de datos
        DocumentSnapshot userDocument = usersSnapshot.docs.first;

        // Obtener la referencia al documento del usuario
        DocumentReference userRef = userDocument.reference;

        // Crear una referencia al documento dentro de la subcolección con el nombre de la situación
        DocumentReference postpartoRef =
            userRef.collection('situacion').doc('Post-Parto');

        // Añadir un nuevo documento a la subcolección con la información de la situación
        await postpartoRef.set
            // Agregar los datos al documento del usuario
            ({
          'bebe': bebeController.text,
          'fechaNacimiento': fechaNacimientobebeController.text,
          'lugarNacimiento': lugarnacimientoController.text,
          'peso': pesoController.text,
          'edadGestacional': int.parse(edadController.text),
          'fechaMenstruacion': menstruacionController.text,
        });
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text("Exitoso"),
              content: Text("Registro Exitoso"),
            );
          },
        );
         Future.delayed(const Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Perfilnuevo(),
            ),
          );
        });
      } else {
        // El usuario no existe en la base de datos
        print('El usuario no existe en la base de datos.');
      }
    } catch (e) {
      print("ERROR HAAAAAAAA" + e.toString());
    }

    // Realizar acciones posteriores al registro si es necesario

    // Limpiar los controladores después de agregar los datos
    bebeController.clear();
    fechaNacimientobebeController.clear();
    lugarnacimientoController.clear();
    pesoController.clear();
    edadController.clear();
    menstruacionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding:
            const EdgeInsets.only(top: 40, bottom: 20, left: 20, right: 20),
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
                              const Text(
                                'Registro del Bebé',
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
                              _buildTextField(
                                  hintText: "Nombre",
                                  icon: Icons.child_care,
                                  controller: bebeController),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Flexible(
                                    flex: 2, // Ajustar la flexibilidad
                                    child: _buildTextField(
                                      hintText: "Fecha de Nacimiento",
                                      icon: Icons.date_range,
                                      controller: fechaNacimientobebeController,
                                      focusNode: fechaNacimientobebeFocusnode,
                                      onTap: () =>
                                          _selectFechaNacimiento(context),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                hintText: "Lugar de Nacimiento",
                                icon: Icons.place,
                                controller: lugarnacimientoController,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                hintText: "Peso al nacer en kg",
                                icon: Icons.accessibility_new,
                                controller: pesoController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]')),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                hintText: "Última Menstruacion",
                                icon: Icons.edit_calendar_outlined,
                                controller: menstruacionController,
                                focusNode: menstruacionFocusnode,
                                onTap: () => _selectMenstruacion(context),
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                hintText: "Edad Gestacional",
                                icon: Icons.calendar_view_week,
                                controller: edadController,
                                enabled: true,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  _registerMDButtonPressed();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(27, 167, 214, 1),
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
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    TextEditingController? controller,
    VoidCallback? onTap,
    FocusNode? focusNode,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
  }) {
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
        controller: controller,
        focusNode: focusNode,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        onTap: onTap,
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
