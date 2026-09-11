import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import '../../../lactation/presentation/providers/lactation_provider.dart';
import 'home_page.dart';

/// Wrapper que proporciona el LactationProvider a la HomePage
class HomePageWrapper extends StatelessWidget {
  const HomePageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LactationProvider>(
      create: (context) => GetIt.instance<LactationProvider>(),
      child: const HomePage(),
    );
  }
}
