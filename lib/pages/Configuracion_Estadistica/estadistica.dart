import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_login/gradient.dart';
import 'package:flutter_login/pages/PerfilContinuacion/user_data_storage.dart';
import 'package:flutter_login/pages/claseGlobal/colores.dart';

class Estadistica extends StatefulWidget {
  @override
  _EstadisticaState createState() => _EstadisticaState();
}

LinearGradient get _barsGradient => LinearGradient(
      colors: [
        AppColors.contentColorBlue.darken(20),
        AppColors.contentColorCyan,
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

class _EstadisticaState extends State<Estadistica>
    with SingleTickerProviderStateMixin {
  final _selectedIndex = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualización Personal'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: double.infinity, // Establece el ancho al máximo
        height: double.infinity, // Establece la altura al máximo
        decoration: const BoxDecoration(gradient: Gradientslogin.myGradient),
        child: Column(
          children: <Widget>[
            const Text(
              'Cantidad de Vistas por Video',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Color.fromRGBO(25, 33, 49, 30),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: FutureBuilder(
                future: obtenerDatos(UserDataStorage.getUserName()),
                builder: (context, AsyncSnapshot<Map<String, int>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Text('Error al cargar datos');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Column(
                      children: [
                        Text('No hay datos disponibles'),
                        Text('\nEmpezamos a ver las lecciones!')
                      ],
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: BarChart(
                        BarChartData(
                          barGroups: obtenerGrupos(snapshot.data!),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toString(),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toString(),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: Colors.grey,
                              width: 2.0,
                            ),
                          ),
                          gridData: const FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            drawHorizontalLine: false,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Future<Map<String, int>> obtenerDatos(String usuario) async {
    try {
      final usuarioDocRef = await _getUsuarioDocumento(usuario);

      if (usuarioDocRef != null) {
        final videosCollectionRef = usuarioDocRef.collection('videos');
        QuerySnapshot<Map<String, dynamic>> videosSnapshot =
            await videosCollectionRef.get();

        Map<String, int> datos = {};

        for (QueryDocumentSnapshot<Map<String, dynamic>> videoDocument
            in videosSnapshot.docs) {
          // Agrega los datos al mapa
          datos[videoDocument.id] = videoDocument['contadorVisualizaciones'];
        }

        return datos;
      } else {
        print('No se encontró un usuario con el nombre: $usuario');
        return {};
      }
    } catch (e) {
      print('Error al obtener datos: $e');
      return {};
    }
  }

  Future<DocumentReference?> _getUsuarioDocumento(String usuario) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final usersQuery = await firestore
        .collection('Users')
        .where('usuario', isEqualTo: usuario)
        .limit(1)
        .get();

    return usersQuery.docs.isNotEmpty ? usersQuery.docs[0].reference : null;
  }

  List<BarChartGroupData> obtenerGrupos(Map<String, int> datos) {
    return datos.entries.map((entry) {
      return BarChartGroupData(
        x: datos.keys.toList().indexOf(entry.key) + 1,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.white
          ),
        ],
      );
    }).toList();
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
