import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import 'dart:ui'; // Necesario para el efecto de desenfoque (opcional)

import '../../../lactation/data/services/lactation_service.dart';
import '../../../lactation/data/services/lactation_notification_service.dart';
import '../../../lactation/presentation/widgets/lactation_record_dialog.dart';

class PostpartoLactationDashboard extends StatefulWidget {
  const PostpartoLactationDashboard({super.key});

  @override
  State<PostpartoLactationDashboard> createState() =>
      _PostpartoLactationDashboardState();
}

class _PostpartoLactationDashboardState
    extends State<PostpartoLactationDashboard> {
  final LactationService _lactationService = GetIt.instance<LactationService>();
  final LactationNotificationService _notificationService =
      LactationNotificationService();

  // Estado del dashboard
  int _todayFeeds = 0;
  Duration _todayTotalDuration = Duration.zero;
  DateTime? _lastFeedTime;

  @override
  void initState() {
    super.initState();
    _loadTodayData();
    _checkForNotifications();
  }

  Future<void> _loadTodayData() async {
    try {
      final today = DateTime.now();
      final records = await _lactationService.getRecordsForDate(today);

      if (!mounted) return;

      setState(() {
        _todayFeeds = records.length;
        _todayTotalDuration = records.fold(
          Duration.zero,
          (total, record) => total + record.duracion,
        );

        if (records.isNotEmpty) {
          _lastFeedTime = records.last.fechaRegistro;
        }
      });
    } catch (e) {
      print('Error cargando datos del día: $e');
    }
  }

  Future<void> _checkForNotifications() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      await _notificationService.showMotivationalNotification(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // MODIFICADO: Usamos un color de fondo base para toda la pantalla
    return Scaffold(
      backgroundColor: const Color(
        0xFFFAF6F8,
      ), // Un rosa muy pálido, como el de Flo
      // MODIFICADO: Hacemos el AppBar transparente para que se fusione con el fondo
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        // Mantenemos el scroll por si el contenido crece
        child: Column(
          children: [
            // NUEVO: Usamos un Stack para el diseño en capas
            Stack(
              alignment: Alignment.topCenter,
              children: [
                // 1. El fondo curvado
                _buildCurvedBackground(),

                // 2. El contenido que va encima del fondo
                _buildContentOnTop(),
              ],
            ),

            // 3. El resto del contenido que va debajo de la sección curvada
            const SizedBox(height: 24),
            _buildOriginalCards(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      // Puedes mantener o quitar el FloatingActionButton según tu preferencia de diseño
      // floatingActionButton: _buildFloatingActionButton(context),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // MODIFICADO: AppBar transparente
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent, // Fondo transparente
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.person_outline, color: Color(0xFF2C3E50)),
        onPressed: () {},
      ),
      title: Text(
        '${DateTime.now().day} de ${_getMonthName(DateTime.now().month)}',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2C3E50),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.calendar_today_outlined,
            color: Color(0xFF2C3E50),
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  // NUEVO: Widget para el fondo curvado
  Widget _buildCurvedBackground() {
    return Container(
      height: 450, // Altura del fondo
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
    );
  }

  // NUEVO: Widget para agrupar el contenido que va sobre el fondo
  Widget _buildContentOnTop() {
    return Padding(
      padding: const EdgeInsets.only(top: 100), // Espacio para el AppBar
      child: Column(
        children: [
          _buildFloCalendar(),
          const SizedBox(height: 30),
          _buildMotivationalMessage(),
          const SizedBox(height: 30),
          _buildRegisterButton(), // El botón ahora está aquí
        ],
      ),
    );
  }

  // MODIFICADO: Calendario sin su propio fondo, adaptado al nuevo diseño
  Widget _buildFloCalendar() {
    final now = DateTime.now();
    final todayWeekday = now.weekday; // Lunes=1, Domingo=7
    final weekDays = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];

    // Obtener los días de la semana actual
    final startOfWeek = now.subtract(Duration(days: todayWeekday % 7));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        final isToday = date.day == now.day && date.month == now.month;
        // Asumiendo que los días 12 y 13 deberían estar marcados
        final isMarked = date.day == 12 || date.day == 13;

        return Column(
          children: [
            Text(
              isToday ? 'HOY' : weekDays[date.weekday % 7],
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isToday ? const Color(0xFF2C3E50) : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isToday
                    ? const Color(0xFF343A40) // Círculo gris oscuro para hoy
                    : isMarked
                    ? const Color(0xFFFCE4EC) // Círculo rosa para días marcados
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${date.day}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isToday
                      ? Colors
                            .white // Texto blanco para hoy
                      : const Color(0xFF2C3E50),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // MODIFICADO: Mensaje sin su propio fondo
  Widget _buildMotivationalMessage() {
    return Column(
      children: [
        Text(
          'Próxima toma en',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getNextFeedTime(),
          style: GoogleFonts.poppins(
            fontSize: 48, // Texto más grande para mayor impacto
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${_getFeedStatus()}. ${_getDurationInfo()}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // MODIFICADO: Botón con estilo "píldora" y sin ancho completo
  Widget _buildRegisterButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) => const LactationRecordDialog(),
        );
        _loadTodayData();
      },
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        'Registrar Lactancia',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE91E63),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: const StadiumBorder(), // Esto crea la forma de píldora
        elevation: 5,
        shadowColor: const Color(0xFFE91E63).withOpacity(0.4),
      ),
    );
  }

  // SIN CAMBIOS a partir de aquí...
  // ... (El resto de tus métodos como _buildOriginalCards, _getNextFeedTime, etc. se mantienen igual)

  /// Cards originales (Tips, Lecciones, Historial, etc.)
  Widget _buildOriginalCards() {
    // Este widget se muestra debajo del Stack curvado
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Card de mensaje motivacional
          _buildMotivationalCard(),
          const SizedBox(height: 16),

          // Card de Lecciones
          _buildOriginalCard(
            title: 'Lecciones',
            subtitle: 'Mira tu progreso de lecciones',
            icon: Icons.school,
            iconColor: const Color(0xFF2196F3),
            onTap: () {},
          ),
          const SizedBox(height: 16),

          // Card de Tips
          _buildOriginalCard(
            title: 'Tips',
            subtitle: 'Consejos y más',
            icon: Icons.lightbulb_outline,
            iconColor: const Color(0xFFFF9800),
            onTap: () {},
          ),
          const SizedBox(height: 16),

          // Card de historial
          _buildHistoryCard(),
          const SizedBox(height: 16),

          // Card de información del bebé (al final)
          _buildBabyInfoCard(),
        ],
      ),
    );
  }

  Widget _buildOriginalCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  String _getNextFeedTime() {
    if (_lastFeedTime == null) {
      return 'Ahora';
    }
    final now = DateTime.now();
    final suggestedInterval = const Duration(hours: 2, minutes: 30);
    final nextFeedTime = _lastFeedTime!.add(suggestedInterval);
    if (now.isAfter(nextFeedTime)) {
      return 'Ahora';
    }
    final timeUntilNext = nextFeedTime.difference(now);
    final hours = timeUntilNext.inHours;
    final minutes = timeUntilNext.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _getFeedStatus() {
    if (_todayFeeds == 0) {
      return 'Inicia tu registro';
    } else if (_todayFeeds < 6) {
      return 'Buen progreso';
    } else {
      return '¡Excelente ritmo!';
    }
  }

  String _getDurationInfo() {
    if (_todayTotalDuration.inHours > 0) {
      return '${_todayTotalDuration.inHours}h ${_todayTotalDuration.inMinutes.remainder(60)}m hoy';
    } else {
      return '${_todayTotalDuration.inMinutes}m hoy';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return months[month - 1];
  }

  /// Card de mensaje motivacional (como en la imagen)
  Widget _buildMotivationalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Recuerda hidratarte bien para mantener una buena producción',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card de información del bebé (como en la segunda imagen)
  Widget _buildBabyInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E0FF), // Color púrpura claro como en la imagen
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Datos del Bebé',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Nombre de bebé',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            'dgsdgfsd', // Placeholder como en la imagen
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Card de historial
  Widget _buildHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historial',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Progreso de videos completados',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.history,
              color: const Color(0xFF4CAF50),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
