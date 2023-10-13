import 'package:flutter/material.dart';
import 'package:flutter_login/pages/paginadepruebas.dart';
import 'package:flutter_login/pages/registro_lactancia.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(33.0),
        child: AppBar(
          forceMaterialTransparency: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.centerLeft,
            colors: [
              Color(0xffD9ACF5),
              Color.fromARGB(255, 122, 231, 211),
              Color(0xffF2F2F2),
            ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            // Texto en la esquina superior izquierda
            Positioned(
              top: 35.0,
              left: 20.0,
              child: Text(
                'Lecciones 1',
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              top: 75.0,
              left: 20.0,
              child: Text(
                'Lactancia materna',
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
            Positioned(
              top: 40.0,
              right: 20.0,
              child: GestureDetector(
                onTap: () {
                  // Mostrar un mensaje cuando se presione
                  showDialog(
                    context:
                        context, // Asegúrate de tener acceso al contexto en tu aplicación
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Sección de Lecciones de Videos"),
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
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.question_mark,
                    size: 24,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 100.0,
              right: 80.0,
              child: CircularPercentIndicator(
                radius: 69.0,
                lineWidth: 9.0, // Ancho del borde del porcentaje
                percent: _percentage /
                    75, // Divide por 100 para obtener un valor entre 0 y 1
                center: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Prueba(),
                        ),
                      );
                    },
                    child: Container(
                      width: 120.0,
                      height: 120.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Image.asset('assets/images/Homevideo.png',
                            height: 100, width: 100),
                      ),
                    ),
                  ),
                ),
                circularStrokeCap:
                    CircularStrokeCap.butt, // Tipo de extremo del círculo
                progressColor: Colors.blue, // Color del porcentaje
                backgroundColor: Colors.white, // Color del fondo del círculo
              ),
            ),

            // Contenedor circular 2
            Positioned(
              top: 300.0,
              left: 70.0,
              child: CircularPercentIndicator(
                radius: 69.0,
                lineWidth: 9.0, // Ancho del borde del porcentaje
                percent: _percentage /
                    490, // Divide por 100 para obtener un valor entre 0 y 1
                center: Center(
                  child: Container(
                    width: 120.0,
                    height: 120.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Image.asset('assets/images/Writingvideo.png',
                          height: 100, width: 100),
                    ),
                  ),
                ),
                circularStrokeCap:
                    CircularStrokeCap.butt, // Tipo de extremo del círculo
                progressColor: Colors.blue, // Color del porcentaje
                backgroundColor: Colors.white, // Color del fondo del círculo
              ),
            ),
            // Contenedor circular 3
            Positioned(
              top: 500.0,
              right: 80.0,
              child: CircularPercentIndicator(
                radius: 69.0,
                lineWidth: 9.0, // Ancho del borde del porcentaje
                percent: _percentage /
                    75, // Divide por 100 para obtener un valor entre 0 y 1
                center: Center(
                  child: Container(
                    width: 120.0,
                    height: 120.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Image.asset('assets/images/Softvideo.png',
                          height: 100, width: 100),
                    ),
                  ),
                ),
                circularStrokeCap:
                    CircularStrokeCap.butt, // Tipo de extremo del círculo
                progressColor: const Color.fromARGB(
                    255, 137, 141, 145), // Color del porcentaje
                backgroundColor: Colors.white, // Color del fondo del círculo
              ),
            ),
            Positioned(
                top: 730.0,
                left: 5.0,
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
                      backgroundColor: Color.fromARGB(255, 199, 135, 240),
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
                )),
            Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 60,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 240, 237, 237),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNotificationButton(
                        Icons.home, _selectedIndex == 0, 0),
                    _buildNotificationButton(
                        Icons.bar_chart, _selectedIndex == 1, 1),
                    _buildNotificationButton(
                        Icons.settings, _selectedIndex == 2, 2),
                  ],
                ),
              ),
            ),
          ],
        ),
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
          SizedBox(height: 7),
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
          SizedBox(height: 2),
        ],
      ),
    );
  }
}
