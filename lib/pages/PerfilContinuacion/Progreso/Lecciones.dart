import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_login/pages/Videos/VideosPage.dart';
import 'package:flutter_login/pages/paginadepruebas.dart';
import 'package:flutter_login/pages/registro_lactancia.dart';

class lecciones extends StatefulWidget {
  const lecciones({Key? key});

  @override
  State<lecciones> createState() => _leccionesState();
}

class _leccionesState extends State<lecciones> {
  int _selectedIndex = 0;
  double _percentage = 75.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.centerLeft,
            colors: [
              Color(0xffD9ACF5),
              Color.fromARGB(255, 122, 231, 211),
              //Color(0xffF2F2F2),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildAppBar(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Title('Lección 1'),
                      GestureDetector(
                        onTap: () {
                          // Mostrar un mensaje cuando se presione
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title:
                                    const Text("Sección de Lecciones de Videos"),
                                content: const Text(
                                    "En esta sección se encuentran las lecciones de videos a ver."),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text("Cerrar"),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Cerrar el cuadro de diálogo
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          child: const Icon(
                            Icons.help,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _Subtitle('Lactancia materna y sus beneficios'),
                _PercentIndicatorRight(69.0, 'Homevideo.png', Colors.blue),
                _PercentIndicatorLeft(69.0, 'Writingvideo.png', Colors.blue),
                _PercentIndicatorRight(69.0, 'working.png', Colors.blue),
                _PercentIndicatorLeft(69.0, 'food1.png', Colors.blue),
                _Title('Lección 2'),
                _Subtitle('Calostro, leche de transisicon y leche madura'),
                _PercentIndicatorRight(69.0, 'Softvideo.png', Colors.blue),
                _PercentIndicatorLeft(69.0, 'bebemujer1.png', Colors.red),
                _PercentIndicatorRight(69.0, 'bebevientre.png', Colors.yellow),
                _Title('Lección 3'),
                _Subtitle('Medicamentos durante la lactancia materna'),
                _PercentIndicatorLeft(69.0, 'health2.png', Colors.yellow),
                _Title('Lección 4'),
                _Subtitle('Composición Nutricional de la Leche Materna'),
                _PercentIndicatorRight(69.0, 'mujereshablando.png', Colors.green),
                _Title('Lección 5'),
                _Subtitle('¿Cómo saber que el bebé se alimentó lo suficiente?'),
                _PercentIndicatorLeft(69.0, 'food2.png', Colors.blue),
                _PercentIndicatorRight(69.0, 'food3.png', Colors.blue),
                _Title('Lección 6'),
                _Subtitle('Hitos de peso a vigilar'),
                _PercentIndicatorLeft(69.0, 'health1.png', Colors.blue),
                _Title('Lección 7'),
                _Subtitle('Higiene de manos y técnicas de lactancia materna'),
                _PercentIndicatorRight(69.0, 'health3.png', Colors.blue),
                _PercentIndicatorLeft(69.0, 'health4.png', Colors.blue),
                _PercentIndicatorRight(69.0, 'health5.png', Colors.blue),
                _Title('Lección 8'),
                _Subtitle('Signos o Complicaciones en la Lactancia'),
                _PercentIndicatorLeft(69.0, 'problema1.png', Colors.blue),
                _PercentIndicatorRight(69.0, 'problema2.png', Colors.blue),
                _PercentIndicatorLeft(69.0, 'problema3.png', Colors.blue),
                _PercentIndicatorRight(69.0, 'problema4.png', Colors.blue),
                _PercentIndicatorLeft(69.0, 'problema5.png', Colors.blue),
                _Title('Lección 9'),
                _Subtitle('Masajes al seno antes de iniciar la lactancia'),
                _PercentIndicatorRight(69.0, 'cuidadomujer.png', Colors.blue),
                _Title('Lección 10'),
                _Subtitle('Mi banco de leche en casa y su preservacion'),
                _PercentIndicatorLeft(69.0, 'banco1.png', Colors.blue),
                _PercentIndicatorRight(69.0, 'banco2.png', Colors.blue),
                _PercentIndicatorLeft(69.0, 'banco3.png', Colors.blue),
                _Title('Lección 11'),
                _Subtitle('Leyes en Panamá que apoyan la lactancia materna'),
                _PercentIndicatorRight(69.0, 'ley1.png', Colors.blue),
                _PercentIndicatorLeft(69.0, 'ley2.png', Colors.blue),
                _Title('Lección 12'),
                _Subtitle(
                    'Diferencias entre la leche materna y la leche de vaca'),
                _PercentIndicatorRight(69.0, 'milk1.png', Colors.blue),
                _Title('Lección 13'),
                _Subtitle('Mitos de la lactancia materna'),
                _PercentIndicatorLeft(69.0, 'mitos.png', Colors.blue),
                _buildElevatedButton(),
                _buildBottomNavigationBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      forceMaterialTransparency: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _Title(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Text(
          title,
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _Subtitle(String subtitle) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Text(
          subtitle,
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  //circulo indicador de la derecha
  // ignore: non_constant_identifier_names
  Widget _PercentIndicatorRight(double radius, String imageName, Color color) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 40.0, top: 10),
        child: CircularPercentIndicator(
          radius: radius,
          lineWidth: 9.0,
          percent: _percentage / 75,
          center: _buildImageContainer(imageName),
          circularStrokeCap: CircularStrokeCap.butt,
          progressColor: color,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  //circulo indicador de la izquierda
  // ignore: non_constant_identifier_names
  Widget _PercentIndicatorLeft(double radius, String imageName, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 40.0, bottom: 40, top: 10),
        child: CircularPercentIndicator(
          radius: radius,
          lineWidth: 9.0,
          percent: _percentage / 75,
          center: _buildImageContainer(imageName),
          circularStrokeCap: CircularStrokeCap.butt,
          progressColor: color,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildImageContainer(String imageName) {
    return Center(
      child: Container(
        width: 120.0,
        height: 120.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Center(
          child:
              Image.asset('assets/images/$imageName', height: 100, width: 100),
        ),
      ),
    );
  }

  Widget _buildElevatedButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, bottom: 10),
        child: SizedBox(
          width: 210,
          child: ElevatedButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegistroLactancia(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 199, 135, 240),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              shadowColor: Colors.black.withOpacity(0.5),
              elevation: 5,
            ),
            child: Text(
              'Registro Lactancia',
              style: GoogleFonts.quicksand(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 240, 237, 237),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNotificationButton(Icons.home, _selectedIndex == 0, 0),
          _buildNotificationButton(Icons.bar_chart, _selectedIndex == 1, 1),
          _buildNotificationButton(Icons.settings, _selectedIndex == 2, 2),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(IconData icon, bool isActive, int i) {
    return GestureDetector(
      onTap: () {
        setState(() {});
      },
      child: Column(
        children: [
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive
                  ? Colors.blue
                  : const Color.fromARGB(255, 150, 148, 148),
              size: 30,
            ),
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}
