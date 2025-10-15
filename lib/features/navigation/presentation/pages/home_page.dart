import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../user/presentation/bloc/user_profile_bloc.dart';
import '../widgets/modern_header.dart';
import '../widgets/home_feature_card.dart';
import '../widgets/countdown_card.dart';
import '../widgets/postparto_profile_widget.dart';
import '../../domain/services/navigation_service.dart';
import '../../domain/services/app_color_service.dart';

/// Página principal de inicio con diseño consistente y arquitectura limpia
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Elementos decorativos de fondo
          _buildBackgroundElements(context),

          // Contenido principal usando BlocBuilder
          BlocBuilder<UserProfileBloc, UserProfileState>(
            builder: (context, state) {
              return _buildHomeContent(context, state);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundElements(BuildContext context) {
    return Stack(
      children: [
        // Círculos decorativos
        Positioned(
          top: -MediaQuery.of(context).size.height * 0.1,
          right: -MediaQuery.of(context).size.width * 0.1,
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

        // Partículas decorativas
        ...List.generate(8, (index) => _buildAnimatedParticle(context, index)),
      ],
    );
  }

  Widget _buildAnimatedParticle(BuildContext context, int index) {
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

  Widget _buildHomeContent(BuildContext context, UserProfileState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Header modernizado movido al contenido scrolleable
          FadeInDown(
            duration: const Duration(milliseconds: 1000),
            child: ModernHeader(
              userName: NavigationService.getUserName(state),
              onNavigateToLessons: () =>
                  NavigationService.navigateToLessons(context),
            ),
          ),
          const SizedBox(height: 20),
          _buildHomeContentSections(context, state),
          const SizedBox(height: 100), // Espacio para el bottom bar
        ],
      ),
    );
  }

  Widget _buildHomeContentSections(
    BuildContext context,
    UserProfileState state,
  ) {
    final isPostPartum = NavigationService.getUserPostPartumStatus(state);

    return Column(
      children: [
        // Tarjeta de Lecciones
        HomeFeatureCard(
          title: 'Lecciones',
          icon: Icons.show_chart,
          description: 'Mira tu progreso de lecciones',
          onTap: () => NavigationService.navigateToLessons(context),
          color: AppColorService.getFeatureColor('Lecciones'),
        ),

        const SizedBox(height: 15),

        // Contador de cuenta regresiva - Solo para usuarios preparto
        if (!isPostPartum) ...[
          _buildCountdownSection(context, state),
          const SizedBox(height: 15),
        ],

        // Grid de funcionalidades basado en el estado del usuario
        _buildFeatureGrid(context, isPostPartum),

        const SizedBox(height: 20),

        // Secciones de perfil específicas
        _buildProfileSections(context, state),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context, bool isPostPartum) {
    if (isPostPartum) {
      // Para postparto: Tips y Calendario en fila
      return Row(
        children: [
          Expanded(
            child: HomeFeatureCard(
              title: 'Tips',
              icon: Icons.lightbulb,
              description: 'Consejos y más',
              onTap: () => NavigationService.navigateToTips(context),
              color: AppColorService.getFeatureColor('Tips'),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: HomeFeatureCard(
              title: 'Calendario',
              icon: Icons.calendar_today,
              description: 'Registro de lactancia',
              onTap: () => NavigationService.navigateToCalendar(context),
              color: AppColorService.getFeatureColor('Calendario'),
            ),
          ),
        ],
      );
    } else {
      // Para preparto: solo Tips
      return HomeFeatureCard(
        title: 'Tips',
        icon: Icons.lightbulb,
        description: 'Consejos y más',
        onTap: () => NavigationService.navigateToTips(context),
        color: AppColorService.getFeatureColor('Tips'),
      );
    }
  }

  Widget _buildProfileSections(BuildContext context, UserProfileState state) {
    return Column(
      children: [
        // Historial siempre visible
        HomeFeatureCard(
          title: 'Historial',
          icon: Icons.video_library,
          description: 'Progreso de videos completados',
          onTap: () => NavigationService.navigateToUserVideos(context),
          color: AppColorService.getFeatureColor('Historial'),
        ),

        const SizedBox(height: 15),

        // Secciones específicas según el estado
        if (state is UserProfileLoaded) ...[
          // Solo mostrar PostpartoProfileWidget para usuarios postparto
          // Los usuarios preparto ya tienen CountdownCard que muestra toda la información necesaria
          if (state.profile.isPostPartum)
            PostpartoProfileWidget(userProfile: state.profile),
        ] else if (state is UserProfileUpdated) ...[
          // Solo mostrar PostpartoProfileWidget para usuarios postparto
          // Los usuarios preparto ya tienen CountdownCard que muestra toda la información necesaria
          if (state.profile.isPostPartum)
            PostpartoProfileWidget(userProfile: state.profile),
        ],
      ],
    );
  }

  /// Extrae la fecha esperada de nacimiento desde los datos del usuario
  String? _getExpectedBirthDate(UserProfileState state) {
    // Buscar en los datos de situación del usuario
    if (state is UserProfileLoaded) {
      final situationData = state.profile.situationData;
      if (situationData != null &&
          situationData.containsKey('expectedBirthDate')) {
        return situationData['expectedBirthDate'] as String;
      }
    } else if (state is UserProfileUpdated) {
      final situationData = state.profile.situationData;
      if (situationData != null &&
          situationData.containsKey('expectedBirthDate')) {
        return situationData['expectedBirthDate'] as String;
      }
    }

    // No hay fecha disponible
    return null;
  }

  /// Construye la sección del contador con manejo de casos
  Widget _buildCountdownSection(BuildContext context, UserProfileState state) {
    final expectedBirthDate = _getExpectedBirthDate(state);

    if (expectedBirthDate != null) {
      // Mostrar CountdownCard con fecha real
      return CountdownCard(expectedBirthDate: expectedBirthDate);
    } else {
      // Mostrar mensaje informativo cuando no hay fecha
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.orange[400]),
            const SizedBox(height: 16),
            Text(
              'Información Pendiente',
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Para mostrar el contador de tu bebé, necesitas completar la información de tu embarazo en el perfil.',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navegar al perfil o onboarding
                Navigator.of(context).pushNamed('/profile');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03A696),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Completar Información',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }
  }
}
