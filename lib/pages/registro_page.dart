import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login/alerta_dialoge.dart';
import 'package:flutter_login/pages/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../gradient.dart';

class RegistroAPP extends StatefulWidget {
  const RegistroAPP({Key? key}) : super(key: key);

  @override
  _RegistroAPPState createState() => _RegistroAPPState();
}

class _RegistroAPPState extends State<RegistroAPP> {
  TextEditingController _birthdateController = TextEditingController();
  late FocusNode _birthdateFocusNode;
  @override
  void initState() {
    super.initState();
    _birthdateController = TextEditingController();
    _birthdateFocusNode = FocusNode();
  }

  TextEditingController usuarioController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contrasenaController = TextEditingController();
  TextEditingController nombreMadreController = TextEditingController();
  TextEditingController fechaNacimientoController = TextEditingController();
  TextEditingController edadController = TextEditingController();
  TextEditingController cedulaController = TextEditingController();
  TextEditingController ubicacionController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();

  SwiperController swiperController = SwiperController();
  int currentIndex = 0; //indicador de numeros de puntos

  @override
  void dispose() {
    _birthdateController =
        TextEditingController(); // Agrega esta línea para liberar recursos
    _birthdateFocusNode = FocusNode();
    cedulaController.dispose();
    super.dispose();
  }

// funcion para validar la cedula
  bool isValidCedula(String cedula) {
    RegExp regex = RegExp(
        r'^\d{7}$'); // Formato para personas naturales sin la primera letra
    return regex.hasMatch(cedula);
  }

// funcion para validar correo electronico
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegex.hasMatch(email);
  }

  final Firebase = FirebaseFirestore.instance;
//funcion para enviar los datos a la base de datos
  _registerMDButtonPressed() async {
    // Inicializar Firebase si aún no está inicializado
    if (usuarioController.text.isEmpty ||
        emailController.text.isEmpty ||
        contrasenaController.text.isEmpty ||
        nombreMadreController.text.isEmpty ||
        _birthdateController.text.isEmpty ||
        edadController.text.isEmpty ||
        cedulaController.text.isEmpty ||
        ubicacionController.text.isEmpty ||
        telefonoController.text.isEmpty) {
      DialogExample.showAlertDialog(
        context,
        'Alerta',
        'Todos los campos son obligatorios',
      );
      return false;
    }

    try {
      await Firebase.collection('Users')
          .doc()
          .set(// Crear una referencia a la colección "madres" en Firestore
              {
        // Agregar los datos al documento del usuario
        'usuario': usuarioController.text,
        'email': emailController.text,
        'contrasena': contrasenaController.text,
        'nombre madre': nombreMadreController.text,
        'fechaNacimiento': _birthdateController.text,
        'edad': int.parse(edadController.text),
        'cedula': cedulaController.text,
        'ubicacion': ubicacionController.text,
        'telefono': telefonoController.text
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Exitoso"),
            content: Text("Registro Exitoso"),
          );
        },
      );
      Future.delayed(Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      });
      return true;
    } catch (e) {
      print("ERROR HAAAAAAAA" + e.toString());
    }

    // Realizar acciones posteriores al registro si es necesario

    // Limpiar los controladores después de agregar los datos
    usuarioController.clear();
    emailController.clear();
    contrasenaController.clear();
    nombreMadreController.clear();
    _birthdateController.clear();
    edadController.clear();
    cedulaController.clear();
    ubicacionController.clear();
    telefonoController.clear();
  }

  //////////////////////construcor principal//////////////////////////////
  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: Gradients.myGradient,
      ),
      child: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.10,
          ),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.75,
              child: Swiper(
                controller: swiperController,
                onIndexChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemCount: 2,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return buildFirstCard();
                  } else {
                    return buildSecondCard();
                  }
                },
                viewportFraction: 0.85,
                loop: false,
                layout: SwiperLayout.DEFAULT,
                itemWidth: null,
                itemHeight: null,
                scale: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 15),
          buildIndicatorRow(),
        ],
      ),
    ),
  );
}



// primer card
  Widget buildFirstCard() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey,
        //     blurRadius: 10,
        //     offset: Offset(4, 3), // Shadow position
        //   ),
        // ],
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 5),
          Text(
            'Usuario',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 33,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(162, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 34),
          _buildInputField(
            hintText: "Usuario",
            icon: Icons.person,
            controller: usuarioController,
          ),
          const SizedBox(height: 4),
          _buildInputField(
            hintText: "Email",
            icon: Icons.email_outlined,
            controller: emailController,
          ),
          const SizedBox(height: 4),
          _buildInputField(
            hintText: "Contraseña",
            icon: Icons.work_outline,
            obscureText: true,
            controller: contrasenaController,
          ),
          const SizedBox(height: 35.0),
          ElevatedButton(
            onPressed: () {
              swiperController.next();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(27, 167, 214, 1),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              shadowColor: Colors.black.withOpacity(0.5),
              elevation: 5,
            ),
            child: Text(
              ('Siguiente'),
              style: GoogleFonts.quicksand(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSecondCard() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 15),
            Text(
              'Datos Personales',
              style: GoogleFonts.quicksand(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(162, 0, 0, 0),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            _buildInputField(
              hintText: "Nombre de la madre",
              icon: Icons.pregnant_woman,
              controller: nombreMadreController,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    hintText: "Fecha de nacimiento",
                    icon: Icons.calendar_today,
                    controller: _birthdateController,
                    focusNode: _birthdateFocusNode,
                    onTap: () => _selectDate(context),
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: _buildInputField(
                    hintText: "Edad",
                    icon: Icons.portrait,
                    controller: edadController,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      AgeInputFormatter(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildInputField(
              hintText: "Cédula",
              icon: Icons.credit_card,
              controller: cedulaController,
              inputFormatters: [
                LengthLimitingTextInputFormatter(11),
                CustomCedulaInputFormatter(),
              ],
            ),
            const SizedBox(height: 4),
            _buildInputField(
              hintText: "Ubicación",
              icon: Icons.location_on_outlined,
              controller: ubicacionController,
            ),
            const SizedBox(height: 4),
            _buildInputField(
              hintText: "Teléfono Celular",
              icon: Icons.phone,
              controller: telefonoController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                PhoneInputFormatter(),
              ],
            ),
            const SizedBox(height: 15),
            _buildButton(context, 'Registrar'),
            const SizedBox(height: 15),
            _buildSignUpText(context),
          ],
        ),
      ),
    );
  }

//funcion para el selector de la fecha
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        _birthdateController.text = formattedDate;
      });
    }
  }

  //constructor del indicador
  Widget buildIndicatorRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.0),
          width: 10.0,
          height: 10.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentIndex
                ? Color.fromARGB(255, 13, 156, 0)
                : Color.fromARGB(255, 127, 224, 103),
          ),
        );
      }),
    );
  }

//constructor de los campos
  Widget _buildInputField({
    required String hintText,
    required IconData icon,
    TextEditingController? controller,
    FocusNode? focusNode,
    VoidCallback? onTap,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters, // Agrega este parámetro
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
        validator: validator,
        inputFormatters:
            inputFormatters, // Establece los formateadores de entrada aquí
        style: GoogleFonts.quicksand(
            fontSize: 15, color: Colors.black, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.quicksand(
            fontSize: 15,
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

// constructor del boton de registro
  Widget _buildButton(BuildContext context, String text) {
    return SizedBox(
      width: 320,
      child: ElevatedButton(
        onPressed: () {
          // Lógica del botón de login
          _registerMDButtonPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromRGBO(27, 167, 214, 1),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          shadowColor: Colors.black.withOpacity(0.5),
          elevation: 5,
        ),
        child: Text(
          text,
          style: GoogleFonts.quicksand(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  //constructor para redigir a la pagina de inicio
  Widget _buildSignUpText(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Ya tienes una cuenta?',
            style: GoogleFonts.quicksand(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          Text(
            ' Ingresa',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

//clase para validar datos de cedula
class CustomCedulaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = applyCustomCedulaFormat(newValue.text);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  String applyCustomCedulaFormat(String input) {
    input = input.replaceAll('-', ''); // Elimina guiones existentes
    final length = input.length;

    if (length <= 3) {
      return input;
    } else if (length <= 6) {
      return input.substring(0, 1) + '-' + input.substring(1, length);
    } else if (length <= 9) {
      return input.substring(0, 1) +
          '-' +
          input.substring(1, 4) +
          '-' +
          input.substring(4, length);
    } else if (length <= 12) {
      return input.substring(0, 1) +
          '-' +
          input.substring(1, 4) +
          '-' +
          input.substring(4, 7) +
          '-' +
          input.substring(7, length);
    }
    return input.substring(0, 1) +
        '-' +
        input.substring(1, 4) +
        '-' +
        input.substring(4, 7) +
        '-' +
        input.substring(7, 10);
  }
}

//clase para ajustar la edad
class AgeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = applyAgeFormat(newValue.text);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  String applyAgeFormat(String input) {
    final length = input.length;
    if (length <= 3) {
      final age = int.tryParse(input) ?? 0;
      if (age > 100) {
        return '100';
      }
      return input;
    }
    return input.substring(0, 3); // Limita a 3 dígitos
  }
}

//clase para limitar el campo a 8 digitos
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = applyPhoneFormat(newValue.text);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  String applyPhoneFormat(String input) {
    final length = input.length;
    if (length <= 8) {
      return input;
    }
    return input.substring(0, 8); // Limita a 8 dígitos
  }
}
