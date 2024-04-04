// ignore_for_file: use_super_parameters, library_private_types_in_public_api, use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/Configuracion_Estadistica/configuracion.dart';
import 'package:flutter_login/pages/PerfilContinuacion/edicionperfil.dart';
import 'package:flutter_login/pages/PerfilContinuacion/user_data_storage.dart';
import 'package:flutter_login/pages/bottonNavigationBar/bottomBar.dart';
import 'package:flutter_login/pages/claseGlobal/firestoreService.dart';
import 'package:flutter_login/pages/proveedor_boleanos/notifire.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class Perfilnuevo extends StatefulWidget {
  const Perfilnuevo({Key? key}) : super(key: key);

  @override
  _PerfilnuevoState createState() => _PerfilnuevoState();
  static _PerfilnuevoState? of(BuildContext context) {
    return context.findAncestorStateOfType<_PerfilnuevoState>();
  }
}

class _PerfilnuevoState extends State<Perfilnuevo> {
  bool pre = false;
  bool post = false;
  int Index = 1;
  int _selectedIndex = 1;
  String nombreUsuario = UserDataStorage.getUserName();
  String email = UserDataStorage.getUserEmail();
  late String usuario;
  bool positive = false;
  String nombreMadre = '';
  String cedula = '';
  String fechaNacimiento = '';
  String telefono = '';
  String ubicacion = '';
  ////////////bebe/////////
  String nombreBebe = '';
  int edadGest = 0;
  String fechaNacibebe = '';
  String fechaLact = '';
  String horaLact = '';
  String horaNaci = '';
  String lugarNac = '';
  String peso = '';
  double? scrolledUnderElevation;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Video> _videos = [];

  Future<void> _actualizarListaVideosCompletados() async {
    final obtenerInfoAvance = ObtenerInfoAvance();
    final listaIdsVideosCompletados = await obtenerInfoAvance
        .obtenerIdsVideosCompletadosDesdeFirestore(nombreUsuario);

    // Actualizar la lista en el proveedor Avancesprovider
    context
        .read<Avancesprovider>()
        .actualizarListaIdsVideosCompletados(listaIdsVideosCompletados);
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
      }
    } catch (e) {}
  }

  Future<void> _fetchBebeData() async {
    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('usuario',
              isEqualTo: nombreUsuario) // Filtras por el campo 'usuario'
          .limit(1) // Limitas a 1 resultado (asumiendo que debería ser único)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        // El usuario existe en la base de datos
        DocumentSnapshot userDocument = usersSnapshot.docs.first;
        DocumentReference userRef = userDocument.reference;
        DocumentSnapshot situacion =
            await userRef.collection('situacion').doc('Post-Parto').get();

        // Ahora puedes utilizar los datos obtenidos, por ejemplo:
        nombreBebe = situacion['bebe'];
        edadGest = situacion['edadGestacional'];
        fechaLact = situacion['fechaLactancia'];
        fechaNacibebe = situacion['fechaNacimiento'];
        horaLact = situacion['horaLactancia'];
        horaNaci = situacion['horaNacimiento'];
        lugarNac = situacion['lugarNacimiento'];
        peso = situacion['peso'];
      }
    } catch (e) {
      print("Error al recuperar la información del usuario para el bebe: $e");
    }
  }

  Future<void> _loadVideosFromFirestore() async {
    try {
      // Cargar videos desde Firestore
      List<Video> videos = await FirestoreServiceLecciones().getVideos();

      // Obtener el último ID de lección completada
      int? lastCompletedLesson = await _getUltimaLeccionCompletada();

      // Actualizar la lista de videos vistos en LeccionesProvider
      Provider.of<LeccionesProvider>(context, listen: false)
          .updateVideosVistos(videos.map((video) {
        if (lastCompletedLesson != null &&
            video.videoId <= lastCompletedLesson + 1) {
          // Marcar como visto si la lección es menor o igual al último completado
          return true;
        } else {
          return false;
        }
      }).toList());

      setState(() {
        _videos = videos;
      });
    } catch (e) {
      print('Error cargando videos desde Firestore: $e');
      // Manejar el error
    }
  }

  Future<void> enviarAvanceAlProvider() async {
    try {
      final usuarioDocRef = await _getUsuarioDocumento(usuario);
      if (usuarioDocRef != null) {
        final videosCollectionRef = usuarioDocRef.collection('videos');
        final videosCollection =
            await videosCollectionRef.orderBy(FieldPath.documentId).get();

        if (videosCollection.docs.isNotEmpty) {
          final ultimoVideoDoc = videosCollection.docs.last;
          final avance = ultimoVideoDoc.data()['avance'] ?? 0;
          final avance1 = avance.clamp(0.0, 1.0);
          context.read<Avancesprovider>().guardarProgresoPorId(
              int.parse(ultimoVideoDoc.id), avance1 as double);
        }
      }
    } catch (error) {}
  }

  Future<int?> _getUltimaLeccionCompletada() async {
    try {
      final usuarioDocRef = await _getUsuarioDocumento(usuario);
      if (usuarioDocRef != null) {
        final videosCollectionRef = usuarioDocRef.collection('videos');
        final videosCollection =
            await videosCollectionRef.orderBy(FieldPath.documentId).get();

        if (videosCollection.docs.isNotEmpty) {
          // Filtrar los documentos con contadorVisualizaciones distinto de 0
          final videosCompletados = videosCollection.docs
              .where((videoDoc) =>
                  videoDoc.data().containsKey('completado') &&
                  videoDoc['completado'] == true)
              .toList();

          if (videosCompletados.isNotEmpty) {
            // Ordenar los documentos de menor a mayor (por número de lección)
            videosCompletados
                .sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));

            // Obtener el último documento (mayor número de lección)
            final lastLessonDoc = videosCompletados.last;
            // Obtener el número de lección
            return int.parse(lastLessonDoc.id);
          }
        }
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  Future<DocumentReference?> _getUsuarioDocumento(String usuario) async {
    final usersQuery = await _firestore
        .collection('Users')
        .where('usuario', isEqualTo: usuario)
        .limit(1)
        .get();

    return usersQuery.docs.isNotEmpty ? usersQuery.docs[0].reference : null;
  }

  Future<void> _verificadorPerfil() async {
    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('usuario', isEqualTo: nombreUsuario)
          .limit(1)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        // El usuario ya existe en la base de datos
        DocumentSnapshot userDocument = usersSnapshot.docs.first;

        // Obtener la referencia al documento del usuario
        DocumentReference userRef = userDocument.reference;

        // Crear una referencia al documento dentro de la subcolección con el nombre de la situación
        DocumentSnapshot situationSnapshot =
            await userRef.collection('situacion').doc('Pre-Parto').get();

        if (situationSnapshot.exists) {
          pre = true;
        } else {
          // El documento de la situación 'pre-parto' no existe
        }

        // Repite el mismo proceso para la situación 'post-parto'
        situationSnapshot =
            await userRef.collection('situacion').doc('Post-Parto').get();

        if (situationSnapshot.exists) {
          post = true;
        } else {
          // El documento de la situación 'post-parto' no existe
        }
      } else {
        // El usuario no existe en la base de datos
        print('El usuario no existe en la base de datos.');
      }
    } catch (e) {
      print('Error por parte del verificador: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    usuario = UserDataStorage.getUserName();
    _fetchBebeData();
    _fetchUserData(); // Recuperar los datos del usuario desde la base de datos
    _loadVideosFromFirestore();
    _actualizarListaVideosCompletados();
    enviarAvanceAlProvider();
    _verificadorPerfil();
  }

  void _navigateToLecciones() {
    Navigator.pushNamed(
      context,
      '/lecciones',
      arguments: {'videos': _videos},
    );
  }

  void _navigateToHistorial() {
    Navigator.pushNamed(
      context,
      '/secciones',
      arguments: {'videos': _videos},
    );
  }

  void _onItemTapped(index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.transparent),
            child: Scaffold(
              body: Column(
                children: [
                  SingleChildScrollView(
                    child: _buildBody(),
                  ),
                  // BottomBar(
                  //   selectedIndex: _selectedIndex,
                  //   onIndexChanged: _onItemTapped,
                  // ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: BottomBar(
                selectedIndex: _selectedIndex,
                onIndexChanged: _onItemTapped,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        return _buildPerfilNuevo();
      case 2:
        return ConfiguracionScreen(); // La pantalla de cuenta
      case 3:
        return const editProfile(); // La pantalla de editar perfil
      default:
        return Container(); // Caso por defecto, puede ser un contenedor vacío
    }
  }

  Widget _buildPerfilNuevo() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(color: Colors.white),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hola $nombreUsuario',
                                style: GoogleFonts.quicksand(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.06,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff034C8C),
                                ),
                              ),
                              Text(
                                'Avanzamos en las lecciones?',
                                style: GoogleFonts.quicksand(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.05,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      const Color.fromARGB(255, 117, 115, 115),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height *
                                0.02), // Espaciado entre los textos y el avatar
                        SizedBox(
                          width: MediaQuery.of(context).size.width *
                              0.2, // Ancho del avatar
                          height: MediaQuery.of(context).size.width *
                              0.2, // Altura del avatar
                          child: CircleAvatar(
                            radius: MediaQuery.of(context).size.width *
                                0.1, // Radio del avatar
                            backgroundColor: Colors.transparent,
                            child: ClipRRect(
                              child: Image.asset("assets/images/solo-logo.png"),
                            ),
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
                      _navigateToLecciones, // Pasa la función como argumento
                    ),
                    const SizedBox(height: 15),
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
                          Color.fromARGB(255, 234, 38, 182),
                          'Consejos y más',
                          '/tips',
                        ),
                        _buildFeatureBoxes(
                          'Historial',
                          Icons.video_library,
                          Color.fromARGB(255, 22, 124, 104),
                          'Enfatiza\nconocimiento',
                          _navigateToHistorial,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (pre) _PrepartoProfile(),
                    if (post) _PostpartoProfile(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _PostpartoProfile() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1500),
      child: Column(
        children: [
          AnimatedToggleSwitch<bool>.dual(
            current: positive,
            first: false,
            second: true,
            spacing: 50.0,
            style: const ToggleStyle(
              borderColor: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1.5),
                ),
              ],
            ),
            borderWidth: 5.0,
            height: 55,
            onChanged: (b) => setState(() => positive = b),
            styleBuilder: (b) => ToggleStyle(
                indicatorColor:
                    b ? const Color(0xFF3BBFB2) : const Color(0xFF1EA4D9)),
            iconBuilder: (value) => value
                ? const Icon(Icons.baby_changing_station, color: Colors.white)
                : const Icon(Icons.woman, color: Colors.white),
            textBuilder: (value) => value
                ? Center(
                    child: Text(
                    'Bebé',
                    style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: const Color.fromARGB(255, 117, 115, 115)),
                  ))
                : Center(
                    child: Text(
                    'Personal',
                    style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: const Color.fromARGB(255, 117, 115, 115)),
                  )),
          ),
          const SizedBox(height: 15),
          if (positive == true) _buildBabyInfo(),
          const SizedBox(height: 15),
          if (positive == false) _PrepartoProfile(),
        ],
      ),
    );
  }

  Widget _buildBabyInfo() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1500),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "\nDatos del Bebe",
                            style: GoogleFonts.quicksand(
                                fontSize: 23,
                                color: Color(0xff034C8C),
                                fontWeight: FontWeight.bold),
                          ),
                          // IconButton(
                          //     icon: const Icon(Icons.edit),
                          //     onPressed: () {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) => const editProfile(),
                          //         ),
                          //       );
                          //     })
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Nombre del bebe: $nombreBebe\n',
                      style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: const Color.fromARGB(255, 117, 115, 115)),
                    ),
                    Text(
                      'Edad Gestacional: ${(edadGest)}\n',
                      style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: const Color.fromARGB(255, 117, 115, 115)),
                    ),
                    Text(
                      'Fecha de Nacimiento: $fechaNacibebe\n',
                      style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: const Color.fromARGB(255, 117, 115, 115)),
                    ),
                    Text(
                      'Fecha de Lactancia: $fechaLact\n',
                      style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: const Color.fromARGB(255, 117, 115, 115)),
                    ),
                    Text(
                      'Hora de Lactancia: $horaLact\n',
                      style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: const Color.fromARGB(255, 117, 115, 115)),
                    ),
                    Text(
                      'Hora de Nacimiento: $horaLact\n',
                      style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: const Color.fromARGB(255, 117, 115, 115)),
                    ),
                    Text(
                      'Lugar de Nacimiento: $lugarNac\n',
                      style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: const Color.fromARGB(255, 117, 115, 115)),
                    ),
                    Text(
                      'Peso: $peso\n',
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
              ),
            ),
          ),
          const SizedBox(height: 150)
        ],
      ),
    );
  }

  Widget _PrepartoProfile() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1500),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: _buildProfileInfo(),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.transparent),
            height: 170,
          )
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\nDatos personales",
                  style: GoogleFonts.quicksand(
                      fontSize: 23,
                      color: Color(0xff034C8C),
                      fontWeight: FontWeight.bold),
                ),
                // IconButton(
                //     icon: const Icon(Icons.edit),
                //     onPressed: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => const editProfile()),
                //       );
                //     })
              ],
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Nombre de la madre: $nombreMadre\n',
            style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(255, 117, 115, 115)),
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
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
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
