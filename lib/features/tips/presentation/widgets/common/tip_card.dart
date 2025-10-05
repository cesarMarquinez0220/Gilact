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

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: size.height * .02),
            SizedBox(
              height: size.height * 0.35,
              width: size.width * 0.47,
              child: image,
            ),
            Container(
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
                  children: [title, const SizedBox(height: 10), ...body],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
