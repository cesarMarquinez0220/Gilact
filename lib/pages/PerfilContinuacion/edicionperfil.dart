import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/PerfilContinuacion/user_data_storage.dart';

class editProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  height: 275,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/prueba.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 5,
                top: 15,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                top: 260,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 92, 66, 66),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),

                  child:
                      EditProfileForm(), // Proporciona un GlobalKey// Agregar el formulario de edición de perfil
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditProfileForm extends StatefulWidget {
  @override
  _EditProfileFormState createState() => _EditProfileFormState();

  static _EditProfileFormState? of(BuildContext context) {
    return context.findAncestorStateOfType<_EditProfileFormState>();
  }
}

class _EditProfileFormState extends State<EditProfileForm> {
  String email = UserDataStorage.getUserEmail();
  String nombreUsuario1 = '';
  String fechaNacimiento = '';
  String telefono = '';
  String ubicacion = '';

  final TextEditingController _nombreUsuarioController =
      TextEditingController();
  final TextEditingController _fechaNacimientoController =
      TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email) // Busca por el campo 'correo'
          .limit(1)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        DocumentSnapshot userSnapshot = usersSnapshot.docs.first;
        setState(() {
          nombreUsuario1 = userSnapshot.get('usuario');
          fechaNacimiento = userSnapshot.get('fechaNacimiento');
          telefono = userSnapshot.get('telefono');
          ubicacion = userSnapshot.get('ubicacion');
        });

        _nombreUsuarioController.text = nombreUsuario1;
        _fechaNacimientoController.text = fechaNacimiento;
        _telefonoController.text = telefono;
        _ubicacionController.text = ubicacion;
      }
    } catch (e) {
      print("Error al recuperar la información del usuario: $e");
    }
  }

  void _onSave() async {
    // Obtén el correo electrónico del usuario
    String email = UserDataStorage.getUserEmail();

    // Realiza una consulta para encontrar el documento que coincida con el correo electrónico
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: email)
        .get();

    // Si hay un documento coincidente, obtén el identificador del usuario
    if (usersSnapshot.docs.isNotEmpty) {
      DocumentSnapshot userSnapshot = usersSnapshot.docs.first;
      String uid = userSnapshot.id;

      // Recopila los datos de los controladores
      String nuevoNombre = _nombreUsuarioController.text;
      String nuevaFechaNacimiento = _fechaNacimientoController.text;
      String nuevoTelefono = _telefonoController.text;
      String nuevaUbicacion = _ubicacionController.text;

      // Crea un mapa con los datos a actualizar
      Map<String, dynamic> datosActualizados = {
        'usuario': nuevoNombre,
        'fechaNacimiento': nuevaFechaNacimiento,
        'telefono': nuevoTelefono,
        'ubicacion': nuevaUbicacion,
        // Agrega más campos de edición según sea necesario
      };

      // Actualiza los datos en la base de datos
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .update(datosActualizados);

      // Cierra el formulario
      Navigator.of(context).pop();
    } else {
      // No se encontró un documento coincidente
      print('No se encontró un documento coincidente');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Edición de perfil',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nombreUsuarioController,
            decoration: const InputDecoration(
              labelText: 'Nombre',
            ),
          ),
          TextFormField(
            controller: _fechaNacimientoController,
            decoration: const InputDecoration(
              labelText: 'fecha de nacimiento',
            ),
          ),
          TextFormField(
            controller: _telefonoController,
            decoration: const InputDecoration(
              labelText: 'Telefono',
            ),
          ),

          TextFormField(
            controller: _ubicacionController,
            decoration: const InputDecoration(
              labelText: 'Ubicacion',
            ),
          ),
          // Agrega más campos de edición según la información del perfil
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _onSave,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
