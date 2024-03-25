// ignore_for_file: avoid_print

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/gradient.dart';
import 'package:flutter_login/pages/PerfilContinuacion/user_data_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ignore: camel_case_types
class editProfile extends StatefulWidget {
  const editProfile({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EditProfileFormState createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<editProfile> {
  String email = UserDataStorage.getUserEmail();
  String nombreUsuario1 = '';
  String fechaNacimiento = '';
  String telefono = '';
  String ubicacion = '';
  TextEditingController _birthdateController = TextEditingController();
  late FocusNode _birthdateFocusNode;

  final TextEditingController _nombreUsuarioController =
      TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();

  @override
  void initState() {
    _birthdateController = TextEditingController();
    _birthdateFocusNode = FocusNode();
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _birthdateController =
        TextEditingController(); // Agrega esta línea para liberar recursos
    _birthdateFocusNode = FocusNode();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email) // Busca por el campo 'correo'
          .limit(1)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        DocumentSnapshot userSnapshot = usersSnapshot.docs.first;
        setState(() {
          nombreUsuario1 = userSnapshot.get('usuario');
          fechaNacimiento = DateFormat('yyyy-MM-dd').format(
              DateFormat('MM/dd/yyyy')
                  .parse(userSnapshot.get('fechaNacimiento')));

          telefono = userSnapshot.get('telefono');
          ubicacion = userSnapshot.get('ubicacion');
        });

        _nombreUsuarioController.text = nombreUsuario1;
        _birthdateController.text = fechaNacimiento;
        _telefonoController.text = telefono;
        _ubicacionController.text = ubicacion;
      }
    } catch (e) {
      print("Error al recuperar la información del usuario: $e");
    }
  }

  void _onSave() async {
    // Obtén el correo electrónico del usuario
    String email = UserDataStorage.getUserEmail();

    // Realiza una consulta para encontrar el documento que coincida con el correo electrónico
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: email)
        .get();

    // Si hay un documento coincidente, obtén el identificador del usuario
    if (usersSnapshot.docs.isNotEmpty) {
      DocumentSnapshot userSnapshot = usersSnapshot.docs.first;
      String uid = userSnapshot.id;

      // Recopila los datos de los controladores
      String nuevoNombre = _nombreUsuarioController.text;
      String nuevaFechaNacimiento = _birthdateController.text;
      String nuevoTelefono = _telefonoController.text;
      String nuevaUbicacion = _ubicacionController.text;

      // Crea un mapa con los datos a actualizar
      Map<String, dynamic> datosActualizados = {
        'usuario': nuevoNombre,
        'fechaNacimiento': nuevaFechaNacimiento,
        'telefono': nuevoTelefono,
        'ubicacion': nuevaUbicacion,
        // Agrega más campos de edición según sea necesario
      };

      // Actualiza los datos en la base de datos
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .update(datosActualizados);

      // Cierra el formulario
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    } else {
      // No se encontró un documento coincidente
      print('No se encontró un documento coincidente');
    }
  }

  void _selectDate(BuildContext context) async {
    print("Tapped on date field");

    DateTime initialDate = DateTime.now();
    if (_birthdateController.text.isNotEmpty) {
      initialDate = DateTime.parse(_birthdateController.text);
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final formattedDate = DateFormat('MM/dd/yyyy').format(picked);
      setState(() {
        _birthdateController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   floatingActionButton: Padding(
    //     padding: const EdgeInsets.all(0.3),
    //     child: FloatingActionButton(
    //       onPressed: () {
    //         Navigator.pop(context);
    //       },
    //       backgroundColor: Colors.transparent,
    //       elevation: 0,
    //       child: const Icon(Icons.arrow_back, color: Colors.black),
    //     ),
    //   ),
    //   floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
    //   body:
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        gradient: Gradientslogin.myGradient,
      ),
      child: Center(
          child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
     
              height: MediaQuery.of(context).size.height * 0.25,
              width: MediaQuery.of(context).size.width * 0.47,
              child: FadeInRight(
                duration: const Duration(milliseconds: 1000),
                delay: const Duration(milliseconds: 500),
                child: Image.asset(
                  "assets/tips/9_CONSEJO_LACTANCIA.png",
                ),
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 360, maxHeight: 480),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color.fromARGB(251, 255, 255, 255),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Perfil de Madre',
                    style: GoogleFonts.quicksand(
                      fontSize: 33,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(162, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    controller: _nombreUsuarioController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                    ),
                    icon: Icons.person,
                  ),
                  _buildInputField(
                    controller: _birthdateController,
                    focusNode: _birthdateFocusNode,
                    decoration: const InputDecoration(),
                    icon: Icons.calendar_month,
                    onTap: () => _selectDate(context),
                  ),
                  _buildInputField(
                    controller: _telefonoController,
                    decoration: const InputDecoration(
                      labelText: 'Telefono',
                    ),
                    icon: Icons.phone,
                  ),
                  _buildInputField(
                    controller: _ubicacionController,
                    decoration: const InputDecoration(
                      labelText: 'Ubicacion',
                    ),
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 320,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(27, 167, 214, 1),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadowColor: Colors.black.withOpacity(0.5),
                        elevation: 5,
                      ),
                      onPressed: _onSave,
                      child: Text(
                        'Guardar',
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.transparent),
              height: 160,
            )
          ],
        ),
      )),
    );
    //)
  }

  Widget _buildInputField({
    FocusNode? focusNode,
    required IconData icon,
    TextEditingController? controller,
    bool obscureText = false,
    required InputDecoration decoration,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      child: Container(
        height: 48,
        width: 320,
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
          onTap: onTap,
          obscureText: obscureText,
          style: GoogleFonts.quicksand(fontSize: 18, color: Colors.black),
          decoration: InputDecoration(
            hintStyle: GoogleFonts.quicksand(
              fontSize: 18,
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
        ),
      ),
    );
  }
}
