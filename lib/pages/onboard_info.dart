import 'package:flutter/material.dart';
import 'package:flutter_login/gradient.dart';
import 'package:flutter_login/pages/splashinfo/page1.dart';
import 'package:flutter_login/pages/splashinfo/page2.dart';
import 'package:flutter_login/pages/splashinfo/page3.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onboar_Info extends StatelessWidget {
  final _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            gradient: Gradients.myGradient
          ),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  children: [
                    Page1(),
                    Page2(),
                    Page3(),
                  ],
                ),
              ),
              SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: JumpingDotEffect(
                  activeDotColor: Color.fromRGBO(19, 180, 153, 1),
                  dotColor: Colors.white,
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 16,
                  //verticalOffset: 50,
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
