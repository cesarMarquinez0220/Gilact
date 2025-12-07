import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/tip_widgets.dart';
import '../widgets/decorations/shape.dart';

import '../bloc/tip_bloc.dart';

class TipsPage extends StatefulWidget {
  const TipsPage({super.key});

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    context.read<TipBloc>().add(const GetAllTipsRequested());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocBuilder<TipBloc, TipState>(
        builder: (context, state) {
          final tips = (state is TipsLoaded) ? state.tips : const [];
          return _buildTipsCarousel(tips);
        },
      ),
    );
  }

  Widget _buildTipsCarousel(List<dynamic> tips) {
    const List<Widget> staticTipWidgets = [
      AlimentacionComplementariaInfo(),
      SuplementoHierroInfo(),
      BeneficiosBebeInfo(),
      BeneficiosMamaInfo(),
      PosturaAgarreInfo(),
      CalostroInfo(),
      ConsejosLactanciaInfo(),
      ExtraccionAlmacenamientoInfo(),
      ContinuacionExtraccionInfo(),
      HigieneLactanciaInfo(),
      ContinuacionHigieneLactanciaInfo(),
      LactanciaExitosa(),
      RolPadreLactanciaInfo(),
      ProblemasLactanciaInfo(),
    ];

    final int pageCount = staticTipWidgets.length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: Stack(
        children: [
          // Elementos decorativos de fondo (círculo y partículas)
          _buildBackgroundElements(context),

          // Visel/forma turquesa (Bezier y óvalo) del diseño original
          Positioned(
            top: -MediaQuery.of(context).size.height * .13,
            right: MediaQuery.of(context).size.width * .05,
            child: const BezierContainer(),
          ),
          Positioned(
            bottom: -MediaQuery.of(context).size.height * .15,
            left: 0,
            right: 0,
            child: const Align(
              alignment: Alignment.bottomCenter,
              child: Ovalstatic1(),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar/Encabezado
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón volver con glassmorphism
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.2),
                              Colors.white.withValues(alpha: 0.1),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Text(
                        'tips.title'.tr(),
                        style: GoogleFonts.quicksand(
                          color: Colors.white,
                          fontSize: 20,
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
                      IconButton(
                        onPressed: () => _showFavoriteTips(),
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),

                // Header con progreso (glassmorphism)
                _buildProgressHeader(
                  current: _currentPage + 1,
                  total: pageCount,
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pageCount,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final tip = (tips.length > index) ? tips[index] : null;
                      return _buildTipCard(
                        tip,
                        index,
                        tipContent: staticTipWidgets[index],
                      );
                    },
                  ),
                ),

                // Indicador de páginas modernizado
                _buildModernPageIndicator(pageCount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(dynamic tip, int index, {Widget? tipContent}) {
    // Si tenemos un widget estático (diseño original), lo mostramos tal cual
    if (tipContent != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: tipContent,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
          // Imagen del tip
          Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        image: DecorationImage(
                          image: AssetImage(_resolveImageAsset(tip, index)),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Overlay para mejor legibilidad
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.3),
                                ],
                              ),
                            ),
                          ),

                          // Botón de favorito
                          Positioned(
                            top: 16,
                            right: 16,
                            child: IconButton(
                              onPressed: tip == null
                                  ? null
                                  : () => _toggleFavorite(tip.id),
                              icon: Icon(
                                (tip != null && (tip.isFavorite == true))
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    (tip != null &&
                                        (tip.isFavorite == true))
                                    ? Colors.red
                                    : Colors.white,
                                size: 28,
                              ),
                            ),
                          ),

                          // Categoría
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF03A696),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _resolveCategory(tip, index),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
          ),

          // Contenido del tip
          Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _resolveTitle(tip, index),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: tipContent != null
                                ? DefaultTextStyle(
                                    style: GoogleFonts.quicksand(
                                      fontSize: 16,
                                      color: const Color(0xFF2D3748),
                                      height: 1.6,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    child: tipContent,
                                  )
                                : Text(
                                    _resolveDescription(tip),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF7F8C8D),
                                      height: 1.5,
                                    ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  String _resolveImageAsset(dynamic tip, int index) {
    try {
      final url = tip?.imageUrl?.toString();
      if (url != null && url.isNotEmpty) return 'assets/tips/$url';
    } catch (_) {}
    const assets = [
      '1_ALIMENTACION.png',
      '2_LACTANCIA.png',
      '3_BENEFICIOS.png',
      '4_POSTURA.png',
      '5_CALOSTRO.png',
      '6_CONSEJOS.png',
      '6_CONSEJOS.png',
      '7_EXTRACCION.png',
      '7.1_EXTRACCION.png',
      '8_HIGIENE.png',
      '9_CONSEJO_LACTANCIA.png',
      '10_PADRE.png',
      '11_PROBLEMAS.png',
      '12_LIKE.png',
    ];
    if (index >= 0 && index < assets.length) {
      return 'assets/tips/${assets[index]}';
    }
    return 'assets/tips/1_ALIMENTACION.png';
  }

  String _resolveTitle(dynamic tip, int index) {
    try {
      final t = tip?.title?.toString();
      if (t != null && t.isNotEmpty) return t;
    } catch (_) {}
    final titles = [
      'tips.titles.complementaryFeeding'.tr(),
      'tips.titles.ironSupplementation'.tr(),
      'tips.titles.benefitsBaby'.tr(),
      'tips.titles.benefitsMom'.tr(),
      'tips.titles.postureLatch'.tr(),
      'tips.titles.colostrum'.tr(),
      'tips.titles.breastfeedingTips'.tr(),
      'tips.titles.extractionStorage'.tr(),
      'tips.titles.extractionContinuation'.tr(),
      'tips.titles.hygiene'.tr(),
      'tips.titles.hygieneContinuation'.tr(),
      'tips.titles.successfulBreastfeeding'.tr(),
      'tips.titles.fatherRole'.tr(),
      'tips.titles.commonProblems'.tr(),
    ];
    return (index >= 0 && index < titles.length)
        ? titles[index]
        : 'tips.tip'.tr();
  }

  String _resolveCategory(dynamic tip, int index) {
    try {
      final c = tip?.category?.toString();
      if (c != null && c.isNotEmpty) return c;
    } catch (_) {}
    return 'tips.tip'.tr();
  }

  String _resolveDescription(dynamic tip) {
    try {
      final d = tip?.description?.toString();
      if (d != null && d.isNotEmpty) return d;
    } catch (_) {}
    return '';
  }

  // Fondo decorativo similar al diseño anterior
  Widget _buildBackgroundElements(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Stack(
      children: [
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
        ...List.generate(6, (index) => _buildFloatingParticle(context, index)),
      ],
    );
  }

  Widget _buildFloatingParticle(BuildContext context, int index) {
    final left = (index * 60.0) % MediaQuery.of(context).size.width;
    final top = (index * 100.0) % MediaQuery.of(context).size.height;
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 6 + (index % 3) * 2.0,
        height: 6 + (index % 3) * 2.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader({int current = 1, int total = 14}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'tips.progress'.tr(),
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '$current / $total',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Barra de progreso inferior al título
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: current / total,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPageIndicator(int count) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
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
      child: SmoothPageIndicator(
        controller: _pageController,
        count: count,
        effect: const WormEffect(
          activeDotColor: Colors.white,
          dotColor: Colors.white54,
          dotHeight: 8,
          dotWidth: 8,
          spacing: 8,
          strokeWidth: 24,
          type: WormType.thin,
        ),
      ),
    );
  }

  void _toggleFavorite(String tipId) {
    // Aquí implementarías la lógica para marcar/desmarcar como favorito
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('tips.favoritesInDevelopment'.tr())));
  }

  void _showFavoriteTips() {
    context.read<TipBloc>().add(const GetFavoriteTipsRequested());

    showDialog(
      context: context,
      builder: (context) => BlocBuilder<TipBloc, TipState>(
        builder: (context, state) {
          if (state is FavoriteTipsLoaded) {
            return AlertDialog(
              title: Text('tips.favorites'.tr()),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: state.favoriteTips.length,
                  itemBuilder: (context, index) {
                    final tip = state.favoriteTips[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/tips/${tip.imageUrl}',
                        ),
                      ),
                      title: Text(tip.title),
                      subtitle: Text(tip.category),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('common.close'.tr()),
                ),
              ],
            );
          } else {
            return const AlertDialog(content: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
