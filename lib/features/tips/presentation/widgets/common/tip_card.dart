import 'package:flutter/material.dart';

class TipCard extends StatelessWidget {
  final Widget image;
  final Widget title;
  final List<Widget> body;

  const TipCard({
    super.key,
    required this.image,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double availableHeight =
        size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        200; // Espacio para header y navegación

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: size.height * .02),
          // Imagen con altura fija proporcional
          SizedBox(
            height: size.height * 0.25, // Reducido de 0.35 a 0.25
            width: size.width * 0.47,
            child: image,
          ),
          // Contenido que se ajusta al espacio restante
          Expanded(
            child: Container(
              width: size.width * .9,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.5),
                    spreadRadius: 4,
                    blurRadius: 6,
                    offset: const Offset(2, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    // Título con altura mínima
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 40,
                        maxHeight: availableHeight * 0.15,
                      ),
                      child: title,
                    ),
                    const SizedBox(height: 10),
                    // Contenido que se expande para llenar el espacio restante
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(children: body),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
