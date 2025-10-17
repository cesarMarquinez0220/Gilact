import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../alerta_dialoge.dart';

class LactationRecordDialog extends StatefulWidget {
  const LactationRecordDialog({Key? key}) : super(key: key);

  @override
  State<LactationRecordDialog> createState() => _LactationRecordDialogState();
}

class _LactationRecordDialogState extends State<LactationRecordDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _volumenExtraccionController = TextEditingController();
  final _horasSuenoController = TextEditingController();
  final _vecesPechoController = TextEditingController();
  final _vecesBiberonController = TextEditingController();

  // Variables de estado
  String _seleccionVolumenUnidad = 'No';
  String _seleccionSuenoUnidad = 'No';
  String _seleccionPecho = 'Ninguna';

  bool _isLoading = false;

  // Controladores de animación
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Iniciar animaciones
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _volumenExtraccionController.dispose();
    _horasSuenoController.dispose();
    _vecesPechoController.dispose();
    _vecesBiberonController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header con título y botón de cerrar
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.15),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.child_care,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Registro de Lactancia',
                              style: GoogleFonts.quicksand(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    offset: const Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    // Contenido del formulario
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _slideAnimation.value),
                              child: Opacity(
                                opacity: _fadeAnimation.value,
                                child: Column(
                                  children: [
                                    // Volumen de extracción
                                    _buildVolumenExtraccionSection(),
                                    const SizedBox(height: 16),

                                    // Veces que se le dio biberón
                                    _buildTextField(
                                      hintText: "Veces que se le dio biberón",
                                      icon: Icons.child_care,
                                      controller: _vecesBiberonController,
                                    ),
                                    const SizedBox(height: 16),

                                    // Veces que se le dio pecho
                                    _buildTextField(
                                      hintText: "Veces que se le dio pecho",
                                      icon: Icons.nature_people,
                                      controller: _vecesPechoController,
                                    ),
                                    const SizedBox(height: 16),

                                    // Horas de sueño
                                    _buildHorasSuenoSection(),
                                    const SizedBox(height: 20),

                                    // Selección de pecho
                                    _buildPechoSelection(),
                                    const SizedBox(height: 24),

                                    // Botón de registro
                                    _buildRegisterButton(),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVolumenExtraccionSection() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildTextField(
            hintText: "Volumen de extracción",
            icon: Icons.local_drink,
            controller: _volumenExtraccionController,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: _buildDropdownField(
            "Unidad",
            ["No", "ml", "oz"],
            _seleccionVolumenUnidad,
            (newValue) {
              setState(() {
                _seleccionVolumenUnidad = newValue!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHorasSuenoSection() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildTextField(
            hintText: "Horas/minutos de sueño",
            icon: Icons.timer,
            controller: _horasSuenoController,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: _buildDropdownField(
            "Unidad",
            ["No", "Hrs", "Min"],
            _seleccionSuenoUnidad,
            (newValue) {
              setState(() {
                _seleccionSuenoUnidad = newValue!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPechoSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pecho que dio a amamantar",
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text(
                        'Izquierdo',
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      value: 'Izquierdo',
                      groupValue: _seleccionPecho,
                      onChanged: (String? value) {
                        setState(() {
                          _seleccionPecho = value!;
                        });
                      },
                      activeColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text(
                        'Derecho',
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      value: 'Derecho',
                      groupValue: _seleccionPecho,
                      onChanged: (String? value) {
                        setState(() {
                          _seleccionPecho = value!;
                        });
                      },
                      activeColor: Colors.white,
                    ),
                  ),
                ],
              ),
              RadioListTile<String>(
                title: Text(
                  'Ninguna',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                value: 'Ninguna',
                groupValue: _seleccionPecho,
                onChanged: (String? value) {
                  setState(() {
                    _seleccionPecho = value!;
                  });
                },
                activeColor: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: _validateNumber,
        style: GoogleFonts.quicksand(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.quicksand(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.8),
            size: 20,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String hintText,
    List<String> options,
    String selectedValue,
    Function(String?) onChanged,
  ) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: GoogleFonts.quicksand(fontSize: 14, color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.quicksand(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
        ),
        dropdownColor: const Color(0xFF667eea),
        iconEnabledColor: Colors.white.withValues(alpha: 0.8),
        style: GoogleFonts.quicksand(fontSize: 14, color: Colors.white),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _guardarDatos,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Registrar Lactancia',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Campo opcional
    }

    final intValue = int.tryParse(value);
    if (intValue == null || intValue < 0 || intValue > 1000) {
      return 'Número inválido (0-1000)';
    }

    return null;
  }

  int _parseNumber(String text) {
    if (text.isEmpty) return 0;
    final intValue = int.tryParse(text);
    return intValue ?? 0;
  }

  /// Obtiene el ID del documento del usuario en Firestore
  Future<String?> _getUserDocumentId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // Si el usuario tiene email, buscar por email primero
      if (user.email != null) {
        print(
          '🔍 LactationRecordDialog: Buscando usuario por email: ${user.email}',
        );

        // Buscar el documento del usuario por email
        final userQuery = await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          final userDocId = userQuery.docs.first.id;
          print(
            '🔍 LactationRecordDialog: Usuario encontrado con ID: $userDocId',
          );
          return userDocId;
        } else {
          print('❌ LactationRecordDialog: Usuario no encontrado por email');
        }
      }

      // Fallback: intentar con UID directamente
      print('🔍 LactationRecordDialog: Intentando con UID: ${user.uid}');
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        print(
          '🔍 LactationRecordDialog: Usuario encontrado con UID directo: ${user.uid}',
        );
        return user.uid;
      }

      print('❌ LactationRecordDialog: No se encontró usuario en Firestore');
      return null;
    } catch (e) {
      print('❌ Error obteniendo ID del usuario: $e');
      return null;
    }
  }

  Future<void> _guardarDatos() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        DialogExample.showErrorDialog(
          context,
          'Error de Autenticación',
          'No hay usuario autenticado. Por favor, inicia sesión nuevamente.',
        );
        return;
      }

      // Verificar si el usuario tiene situación Post-Parto
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) {
        DialogExample.showErrorDialog(
          context,
          'Error de Usuario',
          'No se pudo encontrar la información del usuario. Por favor, inicia sesión nuevamente.',
        );
        return;
      }

      final situacionDocRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userDocId)
          .collection('situacion')
          .doc('seleccion');

      final situacionSnapshot = await situacionDocRef.get();

      if (!situacionSnapshot.exists) {
        DialogExample.showInfoDialog(
          context,
          'Información Requerida',
          'Debes completar el proceso de onboarding y seleccionar la situación "Post-Parto" para poder registrar datos de lactancia.',
        );
        return;
      }

      // Verificar que el situationType sea 'postparto'
      final data = situacionSnapshot.data();
      final situationType = data?['situationType'] as String?;

      if (situationType != 'postparto') {
        DialogExample.showInfoDialog(
          context,
          'Información Requerida',
          'Debes completar el proceso de onboarding y seleccionar la situación "Post-Parto" para poder registrar datos de lactancia.',
        );
        return;
      }

      // Preparar datos de lactancia
      Map<String, dynamic> datosLactancia = {
        'volumen_extraccion': _parseNumber(_volumenExtraccionController.text),
        'unidad_volumen': _seleccionVolumenUnidad,
        'veces_biberon': _parseNumber(_vecesBiberonController.text),
        'veces_pecho': _parseNumber(_vecesPechoController.text),
        'pecho_dado': _seleccionPecho,
        'horas_sueno_bebe': _parseNumber(_horasSuenoController.text),
        'unidad_sueno': _seleccionSuenoUnidad,
        'timestamp': Timestamp.now(),
        'fecha_registro': DateTime.now().toIso8601String(),
      };

      // Guardar en la subcolección de lactancia
      await situacionDocRef.collection('lactancia').add(datosLactancia);

      // Mostrar mensaje de éxito y cerrar diálogo
      DialogExample.showSuccessDialog(
        context,
        'Registro Exitoso',
        'Los datos de lactancia han sido registrados correctamente.',
        () {
          Navigator.of(context).pop();
          // Opcional: refrescar la pantalla principal
        },
      );
    } catch (e) {
      DialogExample.showErrorDialog(
        context,
        'Error al Guardar',
        'No se pudieron guardar los datos. Por favor, inténtalo nuevamente.\n\nError: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
