import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../tips/presentation/pages/tips_page.dart';
import '../../../lessons/presentation/pages/lessons_page.dart';
import '../../../lessons/presentation/pages/lesson_videos_page.dart';
import '../../../lactation/presentation/pages/lactation_calendar_demo.dart';
import '../../../auth/domain/services/credentials_cache_service.dart';
import '../../../user/presentation/bloc/user_profile_bloc.dart' as user_bloc;
import '../../../user/domain/entities/user_profile_entities.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;

  // Estado local para UI
  bool positive = false; // Para el toggle switch

  // Animación controllers
  late AnimationController _backgroundController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // Inicializar animaciones
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _backgroundController.forward();

    // Cargar datos del usuario usando Clean Architecture
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final email = await CredentialsCacheService.loadCredentialsFromCache();
      if (email.isNotEmpty) {
        // Usar el BLoC para cargar datos del usuario
        context.read<user_bloc.UserProfileBloc>().add(
          user_bloc.GetUserProfileRequested(userId: email),
        );
      }
    } catch (e) {
      print('Error cargando datos del usuario: $e');
    }
  }

  Future<void> _signOut() async {
    try {
      // Usar el UseCase para cerrar sesión
      context.read<user_bloc.UserProfileBloc>().add(
        user_bloc.SignOutRequested(),
      );
      await CredentialsCacheService.clearCredentials();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradiente de fondo que ocupa toda la pantalla
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                _buildPerfilNuevoPage(),
                _buildHealthPage(),
                _buildProfilePage(),
              ],
            ),
          ),
          // Navegación flotante sobre el contenido
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildPerfilNuevoPage() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Stack(
        children: [
          // Elementos decorativos de fondo
          _buildBackgroundElements(screenWidth, screenHeight),

          // Contenido principal usando BlocBuilder
          BlocBuilder<user_bloc.UserProfileBloc, user_bloc.UserProfileState>(
            builder: (context, state) {
              return Column(
                children: [
                  // Header modernizado
                  FadeInDown(
                    duration: const Duration(milliseconds: 1000),
                    child: _buildModernHeader(state),
                  ),

                  // Contenido principal
                  Expanded(child: _buildPerfilNuevoContent(state)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundElements(double width, double height) {
    return Stack(
      children: [
        // Círculos decorativos con animación
        Positioned(
          top: -height * 0.1,
          right: -width * 0.1,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
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
              );
            },
          ),
        ),

        // Partículas con animación sutil
        ...List.generate(8, (index) => _buildAnimatedParticle(index)),
      ],
    );
  }

  Widget _buildAnimatedParticle(int index) {
    final left = (index * 50.0) % MediaQuery.of(context).size.width;
    final top = (index * 80.0) % MediaQuery.of(context).size.height;

    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final animationValue = _pulseController.value;
          return Transform.translate(
            offset: Offset(
              (animationValue * 10 * (index % 2 == 0 ? 1 : -1)),
              (animationValue * 5 * (index % 3 == 0 ? 1 : -1)),
            ),
            child: Opacity(
              opacity: 0.6 + (animationValue * 0.4),
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernHeader(user_bloc.UserProfileState state) {
    String nombreUsuario = '';

    if (state is user_bloc.UserProfileLoaded) {
      nombreUsuario = state.profile.username;
    } else if (state is user_bloc.UserProfileUpdated) {
      nombreUsuario = state.profile.username;
    }

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
                        "assets/images/logo-completo.png",
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

  Widget _buildPerfilNuevoContent(user_bloc.UserProfileState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Tarjeta de Lecciones modernizada
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 200),
            child: _buildModernFeatureCard(
              'Lecciones',
              Icons.show_chart,
              const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
              ),
              'Mira tu progreso de lecciones',
              _navigateToLecciones,
              isLarge: true,
            ),
          ),

          const SizedBox(height: 20),

          // Grid de Tips, Calendario e Historial
          Row(
            children: [
              Expanded(
                child: FadeInLeft(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 400),
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
              ),
              const SizedBox(width: 15),
              Expanded(
                child: FadeInRight(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 400),
                  child: _buildModernFeatureCard(
                    'Calendario',
                    Icons.calendar_today,
                    const LinearGradient(
                      colors: [Color(0xFF16A085), Color(0xFF1ABC9C)],
                    ),
                    'Registro de lactancia',
                    _navigateToCalendar,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Historial
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 600),
            child: _buildModernFeatureCard(
              'Historial',
              Icons.video_library,
              const LinearGradient(
                colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
              ),
              'Enfatiza conocimiento',
              _navigateToHistorial,
            ),
          ),

          const SizedBox(height: 20),

          // Secciones de perfil basadas en el estado
          if (state is user_bloc.UserProfileLoaded) ...[
            if (state.profile.isPrePartum) _buildPrepartoProfile(state.profile),
            if (state.profile.isPostPartum)
              _buildPostpartoProfile(state.profile),
          ] else if (state is user_bloc.UserProfileUpdated) ...[
            if (state.profile.isPrePartum) _buildPrepartoProfile(state.profile),
            if (state.profile.isPostPartum)
              _buildPostpartoProfile(state.profile),
          ],

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
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
                      child: Icon(icon, color: gradient.colors.first, size: 20),
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

  void _navigateToLecciones() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LessonVideosPage(
          videos: [], // Se cargarán desde el servicio
        ),
      ),
    );
  }

  void _navigateToCalendar() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const LactationCalendarDemo(),
      ),
    );
  }

  void _navigateToHistorial() {
    Navigator.pushNamed(context, '/historial');
  }

  Widget _buildPostpartoProfile(UserProfile userProfile) {
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
                    indicatorColor: b
                        ? const Color(0xFF3BBFB2)
                        : const Color(0xFF1EA4D9),
                  ),
                  iconBuilder: (value) => value
                      ? const Icon(
                          Icons.baby_changing_station,
                          color: Colors.white,
                        )
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
          if (positive == true) _buildBabyInfo(userProfile),
          const SizedBox(height: 15),
          if (positive == false) _buildPrepartoProfile(userProfile),
        ],
      ),
    );
  }

  Widget _buildBabyInfo(UserProfile userProfile) {
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
                  if (userProfile.babyInfo != null) ...[
                    _buildInfoRow(
                      'Nombre del bebé',
                      userProfile.babyInfo!.name,
                    ),
                    _buildInfoRow(
                      'Edad Gestacional',
                      '${userProfile.babyInfo!.gestationalAge} semanas',
                    ),
                    _buildInfoRow(
                      'Fecha de Nacimiento',
                      userProfile.babyInfo!.birthDate,
                    ),
                    _buildInfoRow(
                      'Lugar de Nacimiento',
                      userProfile.babyInfo!.birthPlace,
                    ),
                    _buildInfoRow('Peso', '${userProfile.babyInfo!.weight} kg'),
                  ] else ...[
                    const Center(
                      child: Text(
                        'No hay información del bebé disponible',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
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

  Widget _buildPrepartoProfile(UserProfile userProfile) {
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
                  _buildInfoRow('Nombre de la madre', userProfile.motherName),
                  _buildInfoRow('Cédula', userProfile.cedula),
                  _buildInfoRow('Fecha de nacimiento', userProfile.birthDate),
                  _buildInfoRow('Teléfono', userProfile.phone),
                  _buildInfoRow('Ubicación', userProfile.location),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthPage() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header personalizado
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Salud del Bebé',
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // Mostrar estadísticas de salud
                    },
                    icon: const Icon(Icons.analytics, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Tarjetas de funcionalidades de salud
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Seguimiento de peso
                  _buildHealthCard(
                    'Peso del Bebé',
                    'Registra el peso diario',
                    Icons.monitor_weight,
                    const Color(0xFF4CAF50),
                    () {
                      // Navegar a registro de peso
                    },
                  ),
                  const SizedBox(height: 16),

                  // Registro de temperatura
                  _buildHealthCard(
                    'Temperatura',
                    'Control de fiebre',
                    Icons.thermostat,
                    const Color(0xFFFF9800),
                    () {
                      // Navegar a registro de temperatura
                    },
                  ),
                  const SizedBox(height: 16),

                  // Medicamentos
                  _buildHealthCard(
                    'Medicamentos',
                    'Recordatorios de medicinas',
                    Icons.medication,
                    const Color(0xFF2196F3),
                    () {
                      // Navegar a medicamentos
                    },
                  ),
                  const SizedBox(height: 16),

                  // Citas médicas
                  _buildHealthCard(
                    'Citas Médicas',
                    'Próximas consultas',
                    Icons.calendar_today,
                    const Color(0xFF9C27B0),
                    () {
                      // Navegar a citas médicas
                    },
                  ),
                  const SizedBox(height: 16),

                  // Emergencias
                  _buildHealthCard(
                    'Emergencias',
                    'Contactos de emergencia',
                    Icons.emergency,
                    const Color(0xFFF44336),
                    () {
                      // Mostrar contactos de emergencia
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePage() {
    return SafeArea(
      child: Column(
        children: [
          // Header personalizado
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Perfil',
                  style: GoogleFonts.quicksand(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showEditProfile(context),
                  icon: const Icon(Icons.edit, color: Colors.white),
                ),
              ],
            ),
          ),
          // Contenido del perfil
          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return _buildProfileContent(context, state.user);
                } else {
                  return const Center(
                    child: Text(
                      'No hay usuario autenticado',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, user) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFF03A696),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Información del usuario
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: const TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
          ),
          const SizedBox(height: 40),

          // Opciones del perfil
          Expanded(
            child: ListView(
              children: [
                _buildProfileOption(
                  context,
                  'Editar Perfil',
                  Icons.edit,
                  () => _showEditProfile(context),
                ),
                _buildProfileOption(
                  context,
                  'Configuración',
                  Icons.settings,
                  () => _showSettings(context),
                ),
                _buildProfileOption(
                  context,
                  'Ayuda',
                  Icons.help,
                  () => _showHelp(context),
                ),
                _buildProfileOption(
                  context,
                  'Cerrar Sesión',
                  Icons.logout,
                  () => _signOut(),
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF03A696),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : const Color(0xFF2C3E50),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad de edición en desarrollo')),
    );
  }

  void _showSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de configuración en desarrollo'),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda'),
        content: const Text(
          'Gilact es tu compañera en la lactancia materna.\n\n'
          'Aquí encontrarás:\n'
          '• Lecciones educativas\n'
          '• Consejos prácticos\n'
          '• Videos informativos\n'
          '• Seguimiento de progreso\n\n'
          '¿Necesitas ayuda? Contacta a soporte@gilact.com',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.25),
            Colors.white.withValues(alpha: 0.15),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 25),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildModernNavItem(0, Icons.home_outlined, Icons.home, 'Inicio'),
              _buildModernNavItem(
                1,
                Icons.favorite_outline,
                Icons.favorite,
                'Salud',
              ),
              _buildModernNavItem(
                2,
                Icons.person_outline,
                Icons.person,
                'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernNavItem(
    int index,
    IconData inactiveIcon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        width: isSelected ? 80 : 60,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF03A696).withValues(alpha: 0.8),
                    const Color(0xFF03A696).withValues(alpha: 0.6),
                  ],
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF03A696).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: const Color(0xFF03A696).withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Efecto de brillo para elemento activo
            if (isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3, 1.0],
                    ),
                  ),
                ),
              ),

            // Contenido del botón
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: isSelected
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            child: Icon(
                              activeIcon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            child: Icon(
                              inactiveIcon,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: GoogleFonts.quicksand(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
