// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, camel_case_types

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_login/gradient.dart';
import 'package:flutter_login/pages/splashinfo/page1.dart';
import 'package:flutter_login/pages/splashinfo/page2.dart';
import 'package:flutter_login/pages/splashinfo/page3.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onboar_Info extends StatefulWidget {
  @override
  _Onboar_InfoState createState() => _Onboar_InfoState();
}

class _Onboar_InfoState extends State<Onboar_Info> {
  final _controller = PageController();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      // Pass to the next page
      if (_controller.page != 2) {
        _controller.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            gradient: Gradients.myGradient,
          ),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  children:const [
                    Page1(),
                    Page2(),
                    Page3(),
                  ],
                ),
              ),
              SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: const JumpingDotEffect(
                  activeDotColor: Color.fromRGBO(19, 180, 153, 1),
                  dotColor: Colors.white,
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 16,
                  jumpScale: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
