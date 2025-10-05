import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/ui_bloc.dart';
import '../widgets/splash_page_widget.dart';

class SplashScreenPage extends StatefulWidget {
  final int pageIndex;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const SplashScreenPage({
    super.key,
    required this.pageIndex,
    this.onNext,
    this.onPrevious,
  });

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UIBloc, UIState>(
      builder: (context, state) {
        if (state is SplashPagesLoaded) {
          final splashPage = state.splashPages[widget.pageIndex];
          return SplashPageWidget(
            splashPage: splashPage,
            fadeAnimation: _fadeAnimation,
            slideAnimation: _slideAnimation,
            onNext: widget.onNext,
            onPrevious: widget.onPrevious,
          );
        }

        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      },
    );
  }
}

class SplashScreenViewer extends StatefulWidget {
  const SplashScreenViewer({super.key});

  @override
  State<SplashScreenViewer> createState() => _SplashScreenViewerState();
}

class _SplashScreenViewerState extends State<SplashScreenViewer> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoNavigateTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    context.read<UIBloc>().add(const LoadSplashPages());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoNavigateTimer?.cancel();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToHome();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _startAutoNavigate() {
    _autoNavigateTimer?.cancel();
    _autoNavigateTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _navigateToHome();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Indicador de páginas
              _buildPageIndicator(),

              // Contenido de las páginas
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });

                    if (index == 2) {
                      _startAutoNavigate();
                    } else {
                      _autoNavigateTimer?.cancel();
                    }
                  },
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return SplashScreenPage(
                      pageIndex: index,
                      onNext: _nextPage,
                      onPrevious: _previousPage,
                    );
                  },
                ),
              ),

              // Botones de navegación
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón anterior
          if (_currentPage > 0)
            TextButton(
              onPressed: _previousPage,
              child: Text(
                'Anterior',
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            const SizedBox(width: 80),

          // Botón siguiente/saltar
          ElevatedButton(
            onPressed: _currentPage == 2 ? _navigateToHome : _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 5,
            ),
            child: Text(
              _currentPage == 2 ? 'Comenzar' : 'Siguiente',
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
