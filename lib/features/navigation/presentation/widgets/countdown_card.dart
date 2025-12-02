import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../user/presentation/bloc/user_profile_bloc.dart';

/// Widget para el contador de cuenta regresiva del embarazo
class CountdownCard extends StatefulWidget {
  final String expectedBirthDate;
  final VoidCallback? onCountdownReached;
  final VoidCallback? onUpdateToPostpartum;

  const CountdownCard({
    super.key,
    this.expectedBirthDate = '2026-01-12T00:00:00.000',
    this.onCountdownReached,
    this.onUpdateToPostpartum,
  });

  @override
  State<CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<CountdownCard> {
  Timer? _timer;
  Duration? _currentDifference;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    // Actualizar cada segundo para que el contador sea funcional
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateCountdown();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    try {
      final birthDate = DateTime.parse(widget.expectedBirthDate);
      final now = DateTime.now();
      final difference = birthDate.difference(now);
      
      setState(() {
        _currentDifference = difference;
      });

      // Si el contador llegó a 0 o pasó, llamar al callback
      if (difference.isNegative || difference.inSeconds <= 0) {
        if (widget.onCountdownReached != null) {
          widget.onCountdownReached!();
        }
      }
    } catch (e) {
      // Error al parsear fecha
      setState(() {
        _currentDifference = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          _buildCountdownHeader(),
          const SizedBox(height: 25),
          _buildCountdownDisplay(),
          const SizedBox(height: 20),
          _buildProgressBar(),
          const SizedBox(height: 20),
          _buildMotivationalMessage(),
        ],
      ),
    );
  }

  Widget _buildCountdownHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFf093fb).withValues(alpha: 0.1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFf093fb).withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.favorite, color: Color(0xFFf093fb), size: 22),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'countdown.myBabyArrives'.tr(),
                style: GoogleFonts.quicksand(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              Text(
                'countdown.specialCountdown'.tr(),
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  color: const Color(0xFF7F8C8D),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownDisplay() {
    if (_currentDifference == null) {
      return _buildErrorDisplay();
    }

    final daysLeft = _currentDifference!.inDays;
    final hoursLeft = _currentDifference!.inHours;

    if (daysLeft < 0) {
      return _buildPastDueDisplay();
    } else if (daysLeft == 0 && hoursLeft <= 0) {
      return _buildTodayDisplay();
    } else if (daysLeft <= 5) {
      // Mostrar botón cuando faltan 4-5 días o menos
      return _buildActiveCountdownWithButton(_currentDifference!);
    } else {
      return _buildActiveCountdown(_currentDifference!);
    }
  }

  Widget _buildPastDueDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
      decoration: BoxDecoration(
        color: const Color(0xFF27AE60).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF27AE60).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.celebration, color: Color(0xFF27AE60), size: 32),
          const SizedBox(height: 10),
          Text(
            'countdown.dayArrived'.tr(),
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF27AE60),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'countdown.completePostpartumInfo'.tr(),
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              color: const Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 15),
          if (widget.onUpdateToPostpartum != null)
            ElevatedButton.icon(
              onPressed: widget.onUpdateToPostpartum,
              icon: const Icon(Icons.update, size: 18),
              label: Text('countdown.updateToPostpartum'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTodayDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
      decoration: BoxDecoration(
        color: const Color(0xFFE74C3C).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE74C3C).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.favorite, color: Color(0xFFE74C3C), size: 40),
          const SizedBox(height: 15),
          Text(
            '¡HOY!',
            style: GoogleFonts.quicksand(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE74C3C),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¡El gran día ha llegado!',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: const Color(0xFF7F8C8D),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCountdown(Duration difference) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFf093fb).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFf093fb).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimeUnit(
            difference.inDays.toString(),
            'countdown.days'.tr(),
            const Color(0xFFf093fb),
          ),
          const SizedBox(width: 30),
          Container(
            width: 1,
            height: 50,
            color: const Color(0xFFf093fb).withValues(alpha: 0.2),
          ),
          const SizedBox(width: 30),
          _buildTimeUnit(
            difference.inHours % 24 < 10
                ? '0${difference.inHours % 24}'
                : '${difference.inHours % 24}',
            'countdown.hours'.tr(),
            const Color(0xFFf093fb),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCountdownWithButton(Duration difference) {
    return Column(
      children: [
        _buildActiveCountdown(difference),
        const SizedBox(height: 15),
        if (widget.onUpdateToPostpartum != null)
          ElevatedButton.icon(
            onPressed: widget.onUpdateToPostpartum,
            icon: const Icon(Icons.update, size: 18),
            label: Text('countdown.updateToPostpartum'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
      decoration: BoxDecoration(
        color: const Color(0xFF95A5A6).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Icon(Icons.schedule, color: Color(0xFF95A5A6), size: 32),
          const SizedBox(height: 10),
          Text(
            'countdown.preparingCountdown'.tr(),
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: const Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            value,
            style: GoogleFonts.quicksand(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 12,
            color: const Color(0xFF7F8C8D),
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    try {
      final birthDate = DateTime.parse(widget.expectedBirthDate);
      final now = DateTime.now();
      const totalDays = 280; // 40 semanas promedio
      final daysPassed = now
          .difference(birthDate.subtract(const Duration(days: totalDays)))
          .inDays;
      final progress = (daysPassed / totalDays).clamp(0.0, 1.0);

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'countdown.pregnancyProgress'.tr(),
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: const Color(0xFF7F8C8D),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: const Color(0xFFf093fb),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFECF0F1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFf093fb), Color(0xFF667eea)],
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFf093fb).withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildMotivationalMessage() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFf093fb).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite_border, color: Color(0xFFf093fb), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _getMotivationalMessage(),
              style: GoogleFonts.quicksand(
                fontSize: 13,
                color: const Color(0xFF2C3E50),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage() {
    if (_currentDifference == null) {
      return 'countdown.stayStrong'.tr();
    }

    final daysLeft = _currentDifference!.inDays;

    if (daysLeft < 0) {
      return 'countdown.newAdventure'.tr();
    } else if (daysLeft == 0) {
      return 'countdown.greatDayArrived'.tr();
    } else if (daysLeft <= 7) {
      return 'countdown.verySoon'.tr();
    } else if (daysLeft <= 30) {
      return 'countdown.oneMonthLeft'.tr();
    } else {
      return 'countdown.motivationalMessage'.tr();
    }
  }
}
