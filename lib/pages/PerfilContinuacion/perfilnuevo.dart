import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/PerfilContinuacion/user_data_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Perfilnuevo extends StatefulWidget {
  const Perfilnuevo({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PerfilnuevoState createState() => _PerfilnuevoState();
  static _PerfilnuevoState? of(BuildContext context) {
    return context.findAncestorStateOfType<_PerfilnuevoState>();
  }
}

class _PerfilnuevoState extends State<Perfilnuevo> {
  int _selectedIndex = 0;
  String nombreUsuario = UserDataStorage.getUserName();
  String email = UserDataStorage.getUserEmail();
  // ignore: unused_field
  bool _isEditing = false;
  String nombreMadre = '';
  String cedula = '';
  String fechaNacimiento = '';
  String telefono = '';
  String ubicacion = '';

  final TextEditingController _nombreMadreController = TextEditingController();
  final TextEditingController _fechaNacimientoController =
      TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Recuperar los datos del usuario desde la base de datos
  }

  Future<void> _fetchUserData() async {
    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('usuario',
              isEqualTo: nombreUsuario) // Filtras por el campo 'usuario'
          .limit(1) // Limitas a 1 resultado (asumiendo que debería ser único)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        DocumentSnapshot userSnapshot = usersSnapshot.docs.first;
        setState(() {
          nombreMadre = userSnapshot.get('nombre madre');
          cedula = userSnapshot.get('cedula');
          fechaNacimiento = userSnapshot.get('fechaNacimiento');
          telefono = userSnapshot.get('telefono');
          ubicacion = userSnapshot.get('ubicacion');
        });
        // ignore: avoid_print
        print(userSnapshot.data());
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error al recuperar la información del usuario: $e");
    }
  }

  // ignore: unused_element
  Future<void> _updateUserData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('usuario',
              isEqualTo: nombreUsuario) // Replace with the desired email
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String documentId = querySnapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(documentId)
            .update({
          'nombreMadre': _nombreMadreController.text,
          'fechaNacimiento': _fechaNacimientoController.text,
          'telefono': _telefonoController.text,
          'ubicacion': _ubicacionController.text,
        });

        setState(() {
          _isEditing = false;
        });
        _fetchUserData();
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error al actualizar la información del usuario: $e");
    }
  }

  double? scrolledUnderElevation;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50),
            decoration: const BoxDecoration(
              color: Color.fromARGB(96, 198, 245, 248),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola $nombreUsuario',
                            style: GoogleFonts.quicksand(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff034C8C)),
                          ),
                          Text(
                            'Avanzamos en las lecciones?',
                            style: GoogleFonts.quicksand(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color:
                                    const Color.fromARGB(255, 117, 115, 115)),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.transparent,
                        child: ClipRRect(
                          child: Image.asset("assets/images/solo-logo.png"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureBoxes(
                    'Lecciones',
                    Icons.show_chart,
                    const Color.fromARGB(255, 255, 132, 0),
                    'Mira tu progreso de lecciones',
                    '/lecciones',
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.5,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    shrinkWrap: true,
                    children: [
                      _buildFeatureBox(
                        'Tips',
                        Icons.lightbulb,
                        const Color.fromARGB(255, 221, 62, 179),
                        'Sobre consejos \n alimenticios y más',
                        '/prueba',
                      ),
                      _buildFeatureBox(
                        'Historial de\n Videos',
                        Icons.video_library,
                        //Color.fromARGB(224, 189, 154, 211),
                        const Color.fromARGB(255, 31, 134, 113),
                        'Enfatiza conocimiento',
                        '/secciones',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1500),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                                0.3), // Color y opacidad de la sombra
                            offset: const Offset(
                                0, 8), // Desplazamiento en el eje X y Y
                            blurRadius: 15, // Radio de desenfoque
                            spreadRadius:
                                0, // Radio de propagación de la sombra
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(223, 253, 253, 253),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: _buildProfileInfo(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureBoxes(
                    'Editar Perfil',
                    Icons.edit,
                    const Color.fromARGB(255, 19, 19, 196),
                    'Cambia tu informacion personal',
                    '/edicion',
                  ),
                  const SizedBox(height: 85),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Container(
              height: 66,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNotificationButton(Icons.home, _selectedIndex == 0, 0),
                  _buildNotificationButton(
                      Icons.bar_chart, _selectedIndex == 1, 1),
                  _buildNotificationButton(
                      Icons.settings, _selectedIndex == 2, 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(IconData icon, bool isActive, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        children: [
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive
                  ? Colors.blue
                  : const Color.fromARGB(255, 150, 148, 148),
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "\nDatos personales",
              style: GoogleFonts.quicksand(
                  fontSize: 23,
                  color: const Color(0xff034C8C),
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Nombre de la madre: $nombreMadre\n',
            style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color(0xff034C8C)),
          ),
          Text(
            'Cédula: $cedula\n',
            style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(255, 117, 115, 115)),
          ),
          Text(
            'Fecha de nacimiento: $fechaNacimiento\n',
            style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(255, 117, 115, 115)),
          ),
          Text(
            'Teléfono: $telefono\n',
            style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(255, 117, 115, 115)),
          ),
          Text(
            'Ubicación: $ubicacion',
            style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(255, 117, 115, 115)),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  Widget _buildFeatureBox(
    String title,
    IconData icon,
    Color bgColor,
    String infoText,
    String route,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: FadeInUp(
        duration:
            const Duration(milliseconds: 1500), // Duración de la animación
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: bgColor,
                    size: 15,
                  ),
                ),
              ),
              Positioned(
                bottom: 15,
                left: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.quicksand(
                          fontSize: 18,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.w800), //titulo
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        infoText,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 255, 255, 255)), //cuerpo
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureBoxes(
    String title,
    IconData icon,
    Color bgColor,
    String infoText,
    String route,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: FadeInUp(
        duration:
            const Duration(milliseconds: 1500), // Duración de la animación
        child: Container(
          //parametros para que el cuadro sea responsive
          height: MediaQuery.of(context).size.height * 0.1,
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: bgColor,
                    size: 15,
                  ),
                ),
              ),
              Positioned(
                bottom: 15,
                left: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.quicksand(
                          fontSize: 20,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.w800), //titulo
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        infoText,
                        style: const TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 255, 255, 255)), //cuerpo
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
