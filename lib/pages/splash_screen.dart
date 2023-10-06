import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/pre_post.dart';
import 'package:lottie/lottie.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(254, 254, 254, 1),
              Color.fromRGBO(254, 254, 254, 1),
              Color.fromRGBO(106, 240, 189, 1),
              Color.fromRGBO(27, 167, 214, 1),
              Color.fromARGB(255, 98, 142, 255),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeIn(
          delay: Duration(milliseconds: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.network(
                "https://lottie.host/91b2ad14-b0d8-4764-8eba-8fef283ec67e/9FK7ekJvjk.json",
                controller: _controller,
                onLoaded: (compos) {
                  _controller
                    ..duration = compos.duration
                    ..forward().then((value) {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 1000),
                          pageBuilder: (BuildContext context,
                              Animation<double> animation,
                              Animation<double> secondaryAnimation) {
                            return FadeTransition(
                              opacity: animation,
                              child: Prepost(),
                            );
                          },
                        ),
                      );
                    });
                },
              ),
              FadeInUp(
                duration: Duration(milliseconds: 1000),
                delay: Duration(milliseconds: 200),
                child: Center(
                  child: Text(
                    "Bienvenidos",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
