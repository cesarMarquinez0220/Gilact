import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/PerfilContinuacion/user_data_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Perfilnuevo extends StatefulWidget {
  const Perfilnuevo({Key? key}) : super(key: key);

  @override
  _PerfilnuevoState createState() => _PerfilnuevoState();
}

class _PerfilnuevoState extends State<Perfilnuevo> {
  int _selectedIndex = 0;
  String nombreUsuario = UserDataStorage.getUserName();
  bool _isEditing = false;
  String nombreMadre = '';
  String cedula = '';
  String fechaNacimiento = '';
  String telefono = '';
  String ubicacion = '';

  TextEditingController _nombreMadreController = TextEditingController();
  TextEditingController _fechaNacimientoController = TextEditingController();
  TextEditingController _telefonoController = TextEditingController();
  TextEditingController _ubicacionController = TextEditingController();

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
        print(userSnapshot.data());
      }
    } catch (e) {
      print("Error al recuperar la información del usuario: $e");
    }
  }

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
      }
    } catch (e) {
      print("Error al actualizar la información del usuario: $e");
    }
  }

  double? scrolledUnderElevation;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50),
            decoration: const BoxDecoration(color: Colors.white),
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
                            'Hola, $nombreUsuario',
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
                                color: Color.fromARGB(255, 255, 255, 255)),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            AssetImage('assets/images/mujerperfil.png'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    shrinkWrap: true,
                    children: [
                      _buildFeatureBox(
                        'Tips',
                        Icons.lightbulb,
                        Color.fromARGB(255, 221, 62, 179),
                        'Consejos alimenticios',
                        '/lecciones',
                      ),
                      _buildFeatureBox(
                        'Videos',
                        Icons.video_library,
                        //Color.fromARGB(224, 189, 154, 211),
                        Color.fromARGB(255, 31, 134, 113),
                        'Aprende mas',
                        '/secciones',
                      ),
                      _buildFeatureBox(
                        'Editar Perfil',
                        Icons.edit,
                        Color.fromARGB(255, 19, 19, 196),
                        'Cambia tu informacion\n personal',
                        '/lecciones',
                      ),
                      _buildFeatureBox(
                        'Progreso',
                        Icons.show_chart,
                        Color.fromARGB(255, 255, 132, 0),
                        'Mira tu progreso de \nlecciones',
                        '/lecciones',
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  FadeInUp(
                    duration: Duration(milliseconds: 1500),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                                0.3), // Color y opacidad de la sombra
                            offset:
                                Offset(0, 8), // Desplazamiento en el eje X y Y
                            blurRadius: 15, // Radio de desenfoque
                            spreadRadius:
                                0, // Radio de propagación de la sombra
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(223, 253, 253, 253),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: _buildProfileInfo(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 85),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     _buildNotificationButton(Icons.home, _selectedIndex == 0, 0),
                  //     _buildNotificationButton(
                  //         Icons.bar_chart, _selectedIndex == 1, 1),
                  //     _buildNotificationButton(
                  //         Icons.settings, _selectedIndex == 2, 2),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 66,
              decoration: BoxDecoration(
                color: Color(0xffF2F2F2),
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
          SizedBox(height: 7),
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
          SizedBox(height: 2),
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
                  color: Color(0xff034C8C),
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 15),
          Text(
            'Nombre de la madre: $nombreMadre\n',
            style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xff034C8C)),
          ),
          Text(
            'Cédula: $cedula\n',
            style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 117, 115, 115)),
          ),
          Text(
            'Fecha de nacimiento: $fechaNacimiento\n',
            style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 117, 115, 115)),
          ),
          Text(
            'Teléfono: $telefono\n',
            style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 117, 115, 115)),
          ),
          Text(
            'Ubicación: $ubicacion',
            style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 117, 115, 115)),
          ),
          _isEditing ? _buildEditButton() : _buildEditIcon(),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  Widget _buildEditIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isEditing = true;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(0, 192, 16, 16),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.transparent,

                  offset: Offset(0, 3), // Cambia la dirección de la sombra
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              // child: Icon(
              //   Icons.edit,
              //   color: Color.fromARGB(255, 43, 42, 42),
              //   size: 24,
              // ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () {
            _updateUserData();
          },
          child: Text('Guardar'),
        ),
      ],
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
        duration: Duration(milliseconds: 1500), // Duración de la animación
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
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: bgColor,
                    size: 30,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.roboto(
                          fontSize: 22,
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.w800), //titulo
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
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
}
