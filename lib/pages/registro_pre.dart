// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/PerfilContinuacion/user_data_storage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_login/gradient.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistroPre extends StatefulWidget {
  const RegistroPre({super.key});

  @override
  _RegistroPreFormState createState() => _RegistroPreFormState();
}

class _RegistroPreFormState extends State<RegistroPre> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: Gradientslogin.myGradient),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360, maxHeight: 550),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: const Color.fromARGB(251, 255, 255, 255),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Fecha Pre-Parto',
                    style: GoogleFonts.quicksand(
                      fontSize: 33,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(162, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TableCalendar(
                    firstDay: DateTime.utc(2022, 1, 1),
                    lastDay: DateTime.utc(2040, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Mes',
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      formatButtonTextStyle: const TextStyle().copyWith(
                        color: Colors.black,
                        fontSize: 15.0,
                      ),
                      formatButtonVisible: false,
                      titleTextStyle: const TextStyle().copyWith(
                        color: Colors.black,
                        fontSize: 20.0,
                      ),
                      leftChevronIcon: const Icon(
                        Icons.chevron_left,
                        color: Colors.black,
                      ),
                      rightChevronIcon: const Icon(
                        Icons.chevron_right,
                        color: Colors.black,
                      ),
                      leftChevronMargin: EdgeInsets.zero,
                      rightChevronMargin: EdgeInsets.zero,
                    ),
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 320,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(27, 167, 214, 1),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadowColor: Colors.black.withOpacity(0.5),
                        elevation: 5,
                      ),
                      onPressed: _selectedDay != null ? _onSave : null,
                      child: Text(
                        'Guardar',
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    String email = UserDataStorage.getUserEmail();
    try {
      // Construir la referencia al documento del usuario
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        // El usuario ya existe en la base de datos
        DocumentSnapshot userDocument = usersSnapshot.docs.first;

        // Obtener la referencia al documento del usuario
        DocumentReference userRef = userDocument.reference;

        // Crear una referencia al documento dentro de la subcolección con el nombre de la situación
        DocumentReference prepartoRef =
            userRef.collection('situacion').doc('Pre-Parto');

        // Añadir un nuevo documento a la subcolección con la información de la situación
        await prepartoRef.set({'fecha_aprox': _selectedDay});
        print(
            'Fecha $_selectedDay guardada con éxito en el documento Pre-Parto para el usuario: $email');

        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Éxito'),
              content: const Text('Fecha guardada exitosamente.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar el diálogo
                    Navigator.pushReplacementNamed(context,
                        '/Onboar_Info'); // Navegar a la pantalla Onboar_Info
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // El usuario no existe en la base de datos
        print('El usuario no existe en la base de datos.');
      }
    } catch (e) {
      print('Error: $e');
    }

    print('Fecha seleccionada: $_selectedDay');
  }
}
