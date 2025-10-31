import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../user/presentation/bloc/user_profile_bloc.dart';
import '../../../lactation/domain/entities/lactation_record.dart';
import '../../../lactation/presentation/providers/lactation_provider.dart';
import '../../../lactation/presentation/widgets/smart_lactation_button.dart';
import '../widgets/modern_header.dart';
import '../widgets/home_feature_card.dart';
import '../widgets/countdown_card.dart';
import '../widgets/postparto_profile_widget.dart';
import '../../domain/services/navigation_service.dart';
import '../../domain/services/app_color_service.dart';

/// Página principal de inicio con diseño consistente y arquitectura limpia
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Cargar datos iniciales usando el Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LactationProvider>();
      provider.loadTodayData();
      provider.loadWeekData();
    });
  }

  /// Maneja el estado cuando no hay registros
  Widget _buildEmptyState(LactationProvider lactationProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.child_care, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '¡Bienvenida!',
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza registrando tu primera sesión de lactancia para ver tu progreso aquí.',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SmartLactationButton(
            onSuccess: () {
              // Refrescar datos después de registrar lactancia
              lactationProvider.refreshTodayData();
              lactationProvider.loadWeekData();
            },
            onCancel: () {
              // Opcional: manejar cancelación
            },
          ),
        ],
      ),
    );
  }

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
              print('🏠 HomePage: Estado recibido: ${state.runtimeType}');
              if (state is UserProfileLoaded) {
                print(
                  '🏠 HomePage: UserProfileLoaded - isPostPartum: ${state.profile.isPostPartum}',
                );
              } else if (state is UserProfileUpdated) {
                print(
                  '🏠 HomePage: UserProfileUpdated - isPostPartum: ${state.profile.isPostPartum}',
                );
              } else if (state is UserProfileFailure) {
                print('🏠 HomePage: UserProfileFailure - ${state.message}');
              } else {
                print('🏠 HomePage: Estado inesperado: $state');
              }
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
    // Mostrar skeleton mientras el perfil está inicializando/cargando para evitar parpadeos de UI
    if (state is UserProfileInitial || state is UserProfileLoading) {
      return _buildHomeSkeleton(context);
    }

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

  /// Skeleton sencillo para cubrir el contenido de Home mientras carga el perfil
  Widget _buildHomeSkeleton(BuildContext context) {
    // Gradiente para el efecto shimmer
    final LinearGradient shimmerGradient = LinearGradient(
      colors: [Colors.grey[200]!, Colors.grey[300]!, Colors.grey[200]!],
      stops: const [0.1, 0.5, 0.9],
      begin: const Alignment(-1.0, -0.3),
      end: const Alignment(1.0, 0.3),
    );

    Widget skeletonCard({double height = 120}) {
      return Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ShimmerLoading(
          isLoading: true,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    }

    return Shimmer(
      linearGradient: shimmerGradient,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header placeholder
            skeletonCard(height: 90),
            const SizedBox(height: 20),
            // Tarjeta principal (countdown o dashboard)
            skeletonCard(height: 220),
            const SizedBox(height: 15),
            // Card Lecciones
            skeletonCard(height: 88),
            const SizedBox(height: 15),
            // Grid/segunda fila
            skeletonCard(height: 88),
            const SizedBox(height: 20),
            // Sección de perfil
            skeletonCard(height: 120),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContentSections(
    BuildContext context,
    UserProfileState state,
  ) {
    final isPostPartum = NavigationService.getUserPostPartumStatus(state);
    print(
      '🏠 HomePage: _buildHomeContentSections - isPostPartum: $isPostPartum',
    );
    print(
      '🏠 HomePage: _buildHomeContentSections - state: ${state.runtimeType}',
    );

    return Column(
      children: [
        // Contenido específico según el tipo de usuario
        if (isPostPartum) ...[
          // Dashboard de lactancia para usuarios postparto
          _buildLactationDashboard(context, state),
          const SizedBox(height: 15),
        ] else ...[
          // Contador de cuenta regresiva para usuarios preparto
          _buildCountdownSection(context, state),
          const SizedBox(height: 15),
        ],

        // Tarjeta de Lecciones (arriba de Tips e Historial)
        HomeFeatureCard(
          title: 'Lecciones',
          icon: Icons.school,
          description: 'Mira tu progreso de lecciones',
          onTap: () => NavigationService.navigateToLessons(context),
          color: AppColorService.getFeatureColor('Lecciones'),
        ),

        const SizedBox(height: 15),

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
      // Para postparto: Tips e Historial en fila
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
              title: 'Historial',
              icon: Icons.video_library,
              description: 'Progreso de videos completados',
              onTap: () => NavigationService.navigateToUserVideos(context),
              color: AppColorService.getFeatureColor('Historial'),
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
        // Secciones específicas según el estado
        _buildPostPartumSection(state),
      ],
    );
  }

  /// Construye la sección de postparto con logs detallados
  Widget _buildPostPartumSection(UserProfileState state) {
    if (state is UserProfileLoaded) {
      print(
        '🏠 HomePage: UserProfileLoaded - isPostPartum: ${state.profile.isPostPartum}',
      );
      // Solo mostrar PostpartoProfileWidget para usuarios postparto
      // Los usuarios preparto ya tienen CountdownCard que muestra toda la información necesaria
      if (state.profile.isPostPartum) {
        print(
          '🏠 HomePage: Mostrando PostpartoProfileWidget para UserProfileLoaded',
        );
        return PostpartoProfileWidget(userProfile: state.profile);
      } else {
        print(
          '🏠 HomePage: NO mostrando PostpartoProfileWidget para UserProfileLoaded (no es postparto)',
        );
        return const SizedBox.shrink();
      }
    } else if (state is UserProfileUpdated) {
      print(
        '🏠 HomePage: UserProfileUpdated - isPostPartum: ${state.profile.isPostPartum}',
      );
      // Solo mostrar PostpartoProfileWidget para usuarios postparto
      // Los usuarios preparto ya tienen CountdownCard que muestra toda la información necesaria
      if (state.profile.isPostPartum) {
        print(
          '🏠 HomePage: Mostrando PostpartoProfileWidget para UserProfileUpdated',
        );
        return PostpartoProfileWidget(userProfile: state.profile);
      } else {
        print(
          '🏠 HomePage: NO mostrando PostpartoProfileWidget para UserProfileUpdated (no es postparto)',
        );
        return const SizedBox.shrink();
      }
    } else {
      print(
        '🏠 HomePage: Estado no reconocido para mostrar PostpartoProfileWidget: ${state.runtimeType}',
      );
      return const SizedBox.shrink();
    }
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
    // Evitar "flash" del mensaje de Información Pendiente:
    // Si el perfil ya está cargado pero aún no tenemos situación (postparto/preparto),
    // mostramos un placeholder en lugar del mensaje final hasta que llegue la situación.
    if (state is UserProfileLoaded || state is UserProfileUpdated) {
      final dynamic profile = (state as dynamic).profile;
      final situationData = profile.situationData;
      final situationUnknown =
          situationData == null ||
          (situationData is Map && situationData.isEmpty);
      if (situationUnknown) {
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
              // Placeholder gris simple (coincide con el diseño general)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 18,
                width: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 40,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        );
      }
    }

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

  /// Dashboard específico para usuarios postparto enfocado en lactancia
  Widget _buildLactationDashboard(
    BuildContext context,
    UserProfileState state,
  ) {
    return Consumer<LactationProvider>(
      builder: (context, lactationProvider, child) {
        // Si está cargando, mostrar loading
        if (lactationProvider.isLoading) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF03A696)),
            ),
          );
        }

        // Si hay error, mostrar error
        if (lactationProvider.errorMessage != null) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error cargando datos',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lactationProvider.errorMessage!,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => lactationProvider.refreshTodayData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03A696),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Reintentar',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        }

        // Si no hay registros, mostrar estado vacío
        if (lactationProvider.todayRecords.isEmpty) {
          return Column(
            children: [
              _buildEmptyState(lactationProvider),
              const SizedBox(height: 20),
            ],
          );
        }

        // Si hay registros, mostrar dashboard normal
        return Column(
          children: [
            // Calendario horizontal con countdown integrado
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: _buildIntegratedCalendarAndCountdown(
                context,
                lactationProvider,
              ),
            ),

            const SizedBox(height: 20),

            // Resumen del día actual (más compacto)
            FadeInUp(
              duration: const Duration(milliseconds: 1400),
              child: _buildCompactTodaySummary(context, lactationProvider),
            ),
          ],
        );
      },
    );
  }

  /// Calendario horizontal con countdown integrado en un solo contenedor
  Widget _buildIntegratedCalendarAndCountdown(
    BuildContext context,
    LactationProvider lactationProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Calendario horizontal
          _buildHorizontalCalendar(context, lactationProvider),

          const SizedBox(height: 24),

          // Divider sutil
          Container(height: 1, color: Colors.grey[200]),

          const SizedBox(height: 20),

          // Countdown integrado
          _buildIntegratedCountdown(context, lactationProvider),
          const SizedBox(height: 30),

          // Botón inteligente de registro de lactancia
          FadeInUp(
            duration: const Duration(milliseconds: 1200),
            child: SmartLactationButton(
              onSuccess: () async {
                print('🔄 onSuccess: Refrescando datos...');
                // Refrescar datos después de registrar lactancia
                await lactationProvider.refreshTodayData();
                await lactationProvider.loadWeekData();
                print('🔄 onSuccess: Datos refrescados');
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Calendario horizontal consistente con el diseño de la app
  Widget _buildHorizontalCalendar(
    BuildContext context,
    LactationProvider lactationProvider,
  ) {
    final now = DateTime.now();
    final todayWeekday = now.weekday; // Lunes=1, Domingo=7
    final weekDays = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];

    // Obtener los días de la semana actual
    final startOfWeek = now.subtract(Duration(days: todayWeekday % 7));
    print(
      '📅 Inicio de semana (DOMINGO): ${startOfWeek.day}/${startOfWeek.month}/${startOfWeek.year}',
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        final isToday = date.day == now.day && date.month == now.month;
        // Verificar si el día tiene registros según la base de datos
        final isMarked = lactationProvider.hasRecordsForDate(date);

        // Debug solo para domingo y lunes para verificar el bug
        if (index == 0 || index == 1) {
          print(
            '📆 ${index == 0 ? "DOMINGO" : "LUNES"}: ${date.day}/${date.month} - Marcado: $isMarked',
          );
        }

        return Expanded(
          child: Column(
            children: [
              // Día de la semana con estilo consistente
              Text(
                isToday ? 'HOY' : weekDays[date.weekday % 7],
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isToday
                      ? const Color(0xFF03A696) // Color primario de la app
                      : const Color(0xFF7F8C8D), // Color secundario consistente
                ),
              ),
              const SizedBox(height: 12),

              // Fecha con diseño consistente
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isToday
                      ? const Color(0xFF03A696) // Color primario para hoy
                      : isMarked
                      ? const Color(0xFF03A696).withValues(
                          alpha: 0.1,
                        ) // Sutil para días marcados
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isToday
                      ? null
                      : isMarked
                      ? Border.all(
                          color: const Color(0xFF03A696).withValues(alpha: 0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isToday
                          ? Colors.white
                          : const Color(
                              0xFF2C3E50,
                            ), // Color de texto consistente
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Indicador de actividad consistente
              if (isMarked)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF03A696),
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(height: 6),
            ],
          ),
        );
      }),
    );
  }

  /// Countdown integrado más compacto
  Widget _buildIntegratedCountdown(
    BuildContext context,
    LactationProvider lactationProvider,
  ) {
    return Column(
      children: [
        Text(
          'Próxima toma en',
          style: GoogleFonts.quicksand(
            fontSize: 16,
            color: const Color(0xFF7F8C8D),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          lactationProvider.isLoading
              ? '...'
              : lactationProvider.getNextFeedTime(),
          style: GoogleFonts.quicksand(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF03A696),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF03A696).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: const Color(0xFF03A696),
              ),
              const SizedBox(width: 4),
              Text(
                lactationProvider.isLoading
                    ? 'Cargando...'
                    : '${lactationProvider.getFeedStatus()}. ${lactationProvider.getDurationInfo()}',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  color: const Color(0xFF03A696),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Resumen compacto del día actual
  Widget _buildCompactTodaySummary(
    BuildContext context,
    LactationProvider lactationProvider,
  ) {
    if (lactationProvider.isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF03A696)),
        ),
      );
    }

    if (lactationProvider.errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 24),
            const SizedBox(height: 8),
            Text(
              'Error cargando datos',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lactationProvider.errorMessage!,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => lactationProvider.refreshTodayData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03A696),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Reintentar',
                style: GoogleFonts.quicksand(fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    final stats =
        lactationProvider.todayStats ??
        LactationStats(
          totalFeeds: 0,
          totalDuration: Duration.zero,
          averageDuration: Duration.zero,
          feedsToday: 0,
          durationToday: Duration.zero,
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCompactSummaryItem(
            '${stats.feedsToday}',
            'Tomas',
            Icons.restaurant,
          ),
          _buildCompactSummaryItem(
            stats.durationToday.inHours > 0
                ? '${stats.durationToday.inHours}h ${stats.durationToday.inMinutes.remainder(60)}m'
                : '${stats.durationToday.inMinutes}m',
            'Total',
            Icons.access_time,
          ),
          _buildCompactSummaryItem(
            lactationProvider.todayRecords.isNotEmpty
                ? lactationProvider.formatLastFeedTime(
                    lactationProvider.todayRecords.last.fechaRegistro,
                  )
                : 'N/A',
            'Última',
            Icons.schedule,
          ),
        ],
      ),
    );
  }

  /// Item compacto del resumen
  Widget _buildCompactSummaryItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF03A696), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.quicksand(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

// ===== Shimmer utilidades (basado en la guía oficial) =====
// Referencia: https://docs.flutter.dev/cookbook/effects/shimmer-loading
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.linearGradient, required this.child});

  final LinearGradient linearGradient;
  final Widget child;

  static ShimmerState? of(BuildContext context) {
    return context.findAncestorStateOfType<ShimmerState>();
  }

  @override
  ShimmerState createState() => ShimmerState();
}

class ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LinearGradient get gradient => LinearGradient(
    colors: widget.linearGradient.colors,
    stops: widget.linearGradient.stops,
    begin: widget.linearGradient.begin,
    end: widget.linearGradient.end,
    transform: _SlidingGradientTransform(slidePercent: _controller.value),
  );

  bool get isSized =>
      (context.findRenderObject() as RenderBox?)?.hasSize ?? false;
  Size get size => (context.findRenderObject() as RenderBox).size;

  Offset getDescendantOffset({
    required RenderBox descendant,
    Offset offset = Offset.zero,
  }) {
    final shimmerBox = context.findRenderObject() as RenderBox?;
    return descendant.localToGlobal(offset, ancestor: shimmerBox);
  }

  Listenable get shimmerChanges => _controller;

  @override
  Widget build(BuildContext context) => widget.child;
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});
  final double slidePercent;
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    required this.isLoading,
    required this.child,
  });
  final bool isLoading;
  final Widget child;
  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> {
  Listenable? _shimmerChanges;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _shimmerChanges?.removeListener(_onShimmerChange);
    _shimmerChanges = Shimmer.of(context)?.shimmerChanges;
    _shimmerChanges?.addListener(_onShimmerChange);
  }

  @override
  void dispose() {
    _shimmerChanges?.removeListener(_onShimmerChange);
    super.dispose();
  }

  void _onShimmerChange() {
    if (widget.isLoading) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    final shimmer = Shimmer.of(context);
    if (shimmer == null || !shimmer.isSized) return const SizedBox();

    final shimmerSize = shimmer.size;
    final gradient = shimmer.gradient;
    final offsetWithinShimmer = shimmer.getDescendantOffset(
      descendant: context.findRenderObject() as RenderBox,
    );

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(
            -offsetWithinShimmer.dx,
            -offsetWithinShimmer.dy,
            shimmerSize.width,
            shimmerSize.height,
          ),
        );
      },
      child: widget.child,
    );
  }
}
