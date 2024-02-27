// ignore_for_file: file_names
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/completeinfo/shape_decoration/clip.dart';

class BezierContainer extends StatelessWidget {
  const BezierContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -pi / 3.5,
      child: ClipPath(
        clipper: ClipPainter(),
        child: Container(
          height: MediaQuery.of(context).size.height * .3,
          width: MediaQuery.of(context).size.width * .4,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomCenter,
                  colors: [
                Color.fromARGB(255, 98, 142, 255),
                Color.fromRGBO(27, 167, 214, 1),
                Color.fromRGBO(27, 214, 183, 1),
                Color.fromRGBO(106, 240, 189, 1),
                Color.fromRGBO(254, 254, 254, 1),
              ])),
        ),
      ),
    );
  }
}

class OvalContainer extends StatelessWidget {
  const OvalContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: pi / 2,
      child: ClipPath(
        clipper: ClipPainter(),
        child: Container(
          height: MediaQuery.of(context).size.height * .5,
          width: MediaQuery.of(context).size.width * .2,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomCenter,
                  colors: [
                Color.fromRGBO(254, 254, 254, 1),
                Color.fromRGBO(106, 240, 189, 1),
                Color.fromRGBO(27, 214, 183, 1),
                Color.fromRGBO(27, 167, 214, 1),
                Color.fromARGB(255, 98, 142, 255),
              ])),
        ),
      ),
    );
  }
}

class Ovalstatic extends StatelessWidget {
  const Ovalstatic({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: pi / 2,
      child: ClipPath(
        clipper: ClipPainter(),
        child: Container(
          height: MediaQuery.of(context).size.height * .5,
          width: MediaQuery.of(context).size.width * .2,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomCenter,
                  colors: [
                Color.fromRGBO(254, 254, 254, 1),
                Color.fromRGBO(106, 240, 189, 1),
                Color.fromRGBO(27, 214, 183, 1),
                Color.fromRGBO(27, 167, 214, 1),
                Color.fromARGB(255, 98, 142, 255),
              ])),
        ),
      ),
    );
  }
}
