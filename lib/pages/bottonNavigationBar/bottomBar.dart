// ignore_for_file: file_names, library_private_types_in_public_api, use_super_parameters

import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class BottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const BottomBar({
    Key? key,
    required this.selectedIndex,
    required this.onIndexChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoundedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            heroTag: "btnHome",
            onPressed: () {
              onIndexChanged(1);
            },
            elevation: selectedIndex == 1 ? 0 : 0,
            backgroundColor: selectedIndex == 1
                ? const Color.fromARGB(255, 2, 128, 187)
                : Colors.transparent,
            child: Icon(
              Icons.home,
              color: selectedIndex == 1
                  ? const Color.fromARGB(208, 255, 255, 255)
                  : const Color.fromARGB(255, 2, 128, 187),
            ),
          ),
          FloatingActionButton(
            heroTag: "btnConfig",
            onPressed: () {
              onIndexChanged(2);
            },
            elevation: selectedIndex == 2 ? 0 : 0,
            backgroundColor: selectedIndex == 2
                ? const Color.fromARGB(255, 2, 128, 187)
                : Colors.transparent,
            child: Icon(
              Icons.settings,
              color: selectedIndex == 2
                  ? const Color.fromARGB(208, 255, 255, 255)
                  : const Color.fromARGB(255, 2, 128, 187),
            ),
          ),
          FloatingActionButton(
            heroTag: "btnEdit",
            onPressed: () {
              onIndexChanged(3);
            },
            elevation: selectedIndex == 3 ? 0 : 0,
            backgroundColor: selectedIndex == 3
                ? const Color.fromARGB(255, 2, 128, 187)
                : Colors.transparent,
            child: Icon(
              Icons.edit,
              color: selectedIndex == 3
                  ? const Color.fromARGB(208, 255, 255, 255)
                  : const Color.fromARGB(255, 2, 128, 187),
            ),
          ),
        ],
      ),
    ).p12();
  }
}

class BarIcon extends StatelessWidget {
  const BarIcon({
    Key? key,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      color: isSelected ? Colors.blue : Colors.grey,
      onPressed: onPressed,
    );
  }
}

class RoundedBox extends StatelessWidget {
  const RoundedBox({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return VxBox(child: child)
        .color(Vx.gray100)
        .roundedLg
        .height(75)
        .width(70)
        .p12
        .margin(EdgeInsets.only(bottom: 20.0))
        .shadowMd
        .make();
  }
}
