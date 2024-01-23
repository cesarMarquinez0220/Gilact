import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_login/pages/PerfilContinuacion/user_data_storage.dart';

class Prueba extends StatefulWidget {
  @override
  _PruebaState createState() => _PruebaState();
}

class _PruebaState extends State<Prueba> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visualización Personal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Cantidad de Vistas por Video',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder(
                future: obtenerDatos(UserDataStorage.getUserName()),
                builder: (context, AsyncSnapshot<Map<String, int>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error al cargar datos');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No hay datos disponibles');
                  } else {
                    return BarChart(
                      BarChartData(
                        barGroups: obtenerGrupos(snapshot.data!),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) => Text(
                                value.toString(),
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        gridData: FlGridData(show: true),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
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
    return datos.entries
        .map(
          (entry) => BarChartGroupData(
            x: datos.keys.toList().indexOf(entry.key) + 1,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: Colors.blue,
              ),
            ],
          ),
        )
        .toList();
  }
}
