import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});
//hoola
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RoundedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const BarIcon(
              icon: Icons.home,
            ),
            const BarIcon(
              icon: Icons.settings,
            ),
            FloatingActionButton(onPressed: () {},
            backgroundColor: Color.fromARGB(255, 2, 128, 187),
            child: Icon(
              Icons.edit,
              color: Color.fromARGB(208, 255, 255, 255),
              ),
            ),
          ],
        ),
      ).p24()
    );
  }
}



class BarIcon extends StatelessWidget {
  const BarIcon({
    Key? key,
    required this.icon,
    }) : super(key:key);
    final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: Color.fromARGB(255, 4, 139, 202),
    );
  }
}


class RoundedBox extends StatelessWidget {
  const RoundedBox({
    Key? key,
    required this.child,
    }): super(key:key);
    final Widget child;

  @override
   Widget build(BuildContext context) {
    return VxBox(child: child)
     .color(Vx.gray100)
     .roundedLg
     .p24
     .shadowSm
     .make();
  }
}