// ignore_for_file: use_super_parameters, library_private_types_in_public_api, use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../Configuracion_Estadistica/configuracion.dart';
import 'edicionperfil.dart';
import 'user_data_storage.dart';
import '../bottonNavigationBar/bottomBar.dart';
import '../claseGlobal/firestoreService.dart';
import '../proveedor_boleanos/notifire.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Perfilnuevo extends StatefulWidget {
  const Perfilnuevo({Key? key}) : super(key: key);

  @override
  _PerfilnuevoState createState() => _PerfilnuevoState();
  static _PerfilnuevoState? of(BuildContext context) {
    return context.findAncestorStateOfType<_PerfilnuevoState>();
  }
}

class _PerfilnuevoState extends State<Perfilnuevo> with TickerProviderStateMixin {
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
  
  // Animación controllers (simplificados)
  late AnimationController _backgroundController;
  late AnimationController _pulseController;

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

        if (situacion.exists) {
          setState(() {
            nombreBebe = situacion.get('nombre bebe');
            edadGest = situacion.get('edad gestacional');
            fechaNacibebe = situacion.get('fecha nacimiento bebe');
            fechaLact = situacion.get('fecha lactancia');
            horaLact = situacion.get('hora lactancia');
            horaNaci = situacion.get('hora nacimiento');
            lugarNac = situacion.get('lugar nacimiento');
            peso = situacion.get('peso');
          });
        }
      }
    } catch (e) {}
  }

  Future<void> _loadVideosFromFirestore() async {
    try {
      QuerySnapshot videosSnapshot = await _firestore.collection('videos').get();
      List<Video> videos = [];
      for (var doc in videosSnapshot.docs) {
        videos.add(Video.fromDocument(doc));
      }
      setState(() {
        _videos = videos;
      });
    } catch (e) {
      print('Error loading videos: $e');
    }
  }

  Future<void> enviarAvanceAlProvider() async {
    // Esta función se mantiene para compatibilidad pero no hace nada específico
    // ya que el avance se maneja de manera diferente en la nueva implementación
  }

  Future<DocumentReference?> _getUserDocumentReference() async {
    QuerySnapshot usersQuery = await FirebaseFirestore.instance
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

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Limpiar datos locales
      UserDataStorage.setUserName('');
      UserDataStorage.setUserEmail('');
      // Navegar a la pantalla de login
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    
    // Inicializar animaciones PRIMERO
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Animaciones simplificadas - solo inicializar los controladores
    
    _backgroundController.forward();
    
    // Luego inicializar datos
    usuario = UserDataStorage.getUserName();
    _fetchBebeData();
    _fetchUserData(); // Recuperar los datos del usuario desde la base de datos
    _loadVideosFromFirestore();
    _actualizarListaVideosCompletados();
    enviarAvanceAlProvider();
    _verificadorPerfil();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _pulseController.dispose();
    super.dispose();
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Elementos decorativos de fondo
              _buildBackgroundElements(screenWidth, screenHeight),
              
              // Contenido principal
              Column(
                children: [
                  // Header modernizado
                  _buildModernHeader(),
                  
                  // Contenido principal
                  Expanded(
                    child: _buildBody(),
                  ),
                  
                  // BottomBar
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: BottomBar(
                      selectedIndex: _selectedIndex,
                      onIndexChanged: _onItemTapped,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundElements(double width, double height) {
    return Stack(
      children: [
        // Círculos decorativos estáticos
        Positioned(
          top: -height * 0.1,
          right: -width * 0.1,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        
        // Partículas estáticas
        ...List.generate(8, (index) => _buildStaticParticle(index)),
      ],
    );
  }

  Widget _buildStaticParticle(int index) {
    final left = (index * 50.0) % MediaQuery.of(context).size.width;
    final top = (index * 80.0) % MediaQuery.of(context).size.height;
    
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 4 + (index % 3) * 2.0,
        height: 4 + (index % 3) * 2.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.25),
            Colors.white.withValues(alpha: 0.15),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola $nombreUsuario',
                      style: GoogleFonts.quicksand(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '¿Avanzamos en las lecciones?',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  // Avatar modernizado
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        "assets/images/solo-logo.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botón de cerrar sesión
                  GestureDetector(
                    onTap: _signOut,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.withValues(alpha: 0.3),
                            Colors.red.withValues(alpha: 0.1),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Tarjeta de Lecciones modernizada
          _buildModernFeatureCard(
            'Lecciones',
            Icons.show_chart,
            const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
            ),
            'Mira tu progreso de lecciones',
            _navigateToLecciones,
            isLarge: true,
          ),
          
          const SizedBox(height: 20),
          
          // Grid de Tips e Historial
          Row(
            children: [
              Expanded(
                child: _buildModernFeatureCard(
                  'Tips',
                  Icons.lightbulb,
                  const LinearGradient(
                    colors: [Color(0xFFEA26B6), Color(0xFFF06292)],
                  ),
                  'Consejos y más',
                  () => Navigator.pushNamed(context, '/tips'),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildModernFeatureCard(
                  'Historial',
                  Icons.video_library,
                  const LinearGradient(
                    colors: [Color(0xFF16A085), Color(0xFF1ABC9C)],
                  ),
                  'Enfatiza conocimiento',
                  _navigateToHistorial,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Secciones de perfil
          if (pre) _PrepartoProfile(),
          if (post) _PostpartoProfile(),
          
          const SizedBox(height: 100), // Espacio para el bottom bar
        ],
      ),
    );
  }

  Widget _buildModernFeatureCard(
    String title,
    IconData icon,
    LinearGradient gradient,
    String infoText,
    VoidCallback onTap, {
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isLarge ? 120 : 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Icono en la esquina superior derecha
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: gradient.colors.first,
                        size: 20,
                      ),
                    ),
                  ),
                  
                  // Contenido principal
                  Positioned(
                    bottom: 15,
                    left: 15,
                    right: 15,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.quicksand(
                            fontSize: isLarge ? 22 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          infoText,
                          style: GoogleFonts.quicksand(
                            fontSize: isLarge ? 14 : 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _PostpartoProfile() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1500),
      child: Column(
        children: [
          // Toggle switch modernizado
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.25),
                  Colors.white.withValues(alpha: 0.15),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AnimatedToggleSwitch<bool>.dual(
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
                    indicatorColor: b ? const Color(0xFF3BBFB2) : const Color(0xFF1EA4D9),
                  ),
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
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            'Personal',
                            style: GoogleFonts.quicksand(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
            ),
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
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.25),
              Colors.white.withValues(alpha: 0.15),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Datos del Bebé",
                      style: GoogleFonts.quicksand(
                        fontSize: 23,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow('Nombre del bebé', nombreBebe),
                  _buildInfoRow('Edad Gestacional', '${edadGest} semanas'),
                  _buildInfoRow('Fecha de Nacimiento', fechaNacibebe),
                  _buildInfoRow('Lugar de Nacimiento', lugarNac),
                  _buildInfoRow('Peso', '$peso kg'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _PrepartoProfile() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1500),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.25),
              Colors.white.withValues(alpha: 0.15),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Datos Personales",
                      style: GoogleFonts.quicksand(
                        fontSize: 23,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow('Nombre de la madre', nombreMadre),
                  _buildInfoRow('Cédula', cedula),
                  _buildInfoRow('Fecha de nacimiento', fechaNacimiento),
                  _buildInfoRow('Teléfono', telefono),
                  _buildInfoRow('Ubicación', ubicacion),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Mantener las funciones originales para compatibilidad
  Widget _buildFeatureBox(
    String title,
    IconData icon,
    Color bgColor,
    String infoText,
    String route,
  ) {
    return _buildModernFeatureCard(
      title,
      icon,
      LinearGradient(colors: [bgColor, bgColor.withValues(alpha: 0.8)]),
      infoText,
      () => Navigator.pushNamed(context, route),
    );
  }

  Widget _buildFeatureBoxes(
    String title,
    IconData icon,
    Color bgColor,
    String infoText,
    VoidCallback onTap,
  ) {
    return _buildModernFeatureCard(
      title,
      icon,
      LinearGradient(colors: [bgColor, bgColor.withValues(alpha: 0.8)]),
      infoText,
      onTap,
      isLarge: true,
    );
  }
}
