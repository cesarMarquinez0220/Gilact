import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/ui_entities.dart';

class SplashPageWidget extends StatelessWidget {
  final SplashPage splashPage;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const SplashPageWidget({
    super.key,
    required this.splashPage,
    required this.fadeAnimation,
    required this.slideAnimation,
    this.onNext,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // Deslizar hacia la derecha - página anterior
          onPrevious?.call();
        } else if (details.primaryVelocity! < 0) {
          // Deslizar hacia la izquierda - página siguiente
          onNext?.call();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen principal
            _buildImage(),

            const SizedBox(height: 30),

            // Título principal
            _buildTitle(),

            const SizedBox(height: 20),

            // Subtítulo
            _buildSubtitle(),

            const SizedBox(height: 30),

            // Descripción
            _buildDescription(),

            const SizedBox(height: 30),

            // Texto adicional (si existe)
            if (splashPage.additionalText != null) ...[
              _buildAdditionalText(),
              const SizedBox(height: 40),
            ] else
              const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return FadeIn(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 500),
          child: SlideInUp(
            duration: const Duration(milliseconds: 1200),
            delay: const Duration(milliseconds: 300),
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(splashPage.imagePath, fit: BoxFit.cover),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: slideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: slideAnimation,
          child: FadeInUp(
            duration: const Duration(milliseconds: 1200),
            delay: const Duration(milliseconds: 500),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.quicksand(
                  color: Colors.white70,
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(text: '${splashPage.title}\n'),
                  TextSpan(
                    text: splashPage.subtitle,
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtitle() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      delay: const Duration(milliseconds: 700),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Text(
          splashPage.description,
          style: GoogleFonts.quicksand(
            fontSize: 16,
            color: Colors.white,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      delay: const Duration(milliseconds: 900),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.15),
              Colors.white.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          splashPage.description,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            color: Colors.white,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildAdditionalText() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      delay: const Duration(milliseconds: 1100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Text(
          splashPage.additionalText!,
          style: GoogleFonts.quicksand(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
