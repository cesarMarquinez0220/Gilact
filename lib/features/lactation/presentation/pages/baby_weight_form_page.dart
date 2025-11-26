import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/datasources/baby_weight_offline_local_data_source.dart';
import '../../domain/entities/baby_weight_record.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/sync_queue_service.dart';
import 'dart:ui';
import '../../../../alerta_dialoge.dart';
import '../../../../main.dart';

/// Página de registro de peso del bebé
class BabyWeightFormPage extends StatefulWidget {
  const BabyWeightFormPage({super.key});

  @override
  State<BabyWeightFormPage> createState() => _BabyWeightFormPageState();
}

class _BabyWeightFormPageState extends State<BabyWeightFormPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  final FocusNode _weightFocusNode = FocusNode();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  double _weight = 3.5; // Valor inicial del peso en kg
  bool _isEditingWeight = false; // Modo edición manual del número

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _weightController.text = '3.5'; // Valor inicial
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Iniciar animaciones con delays escalonados
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveWeightRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await _getUserDocumentId();
      if (userId == null) {
        throw Exception('No se pudo obtener el ID del usuario');
      }

      // Fecha de hoy para el registro
      final today = DateTime.now();
      final fechaRegistro =
          '${today.year}-${_pad(today.month)}-${_pad(today.day)}';

      // Estructura de datos para Firestore
      final weightData = {
        'peso': _weight,
        'unidad': 'kg', // Unidad de peso
        'fecha_registro': fechaRegistro,
        'fecha_peso': fechaRegistro,
        'creado_en': DateTime.now().toIso8601String(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        if (_notesController.text.trim().isNotEmpty)
          'notas': _notesController.text.trim(),
      };

      // OFFLINE-FIRST: Guardar localmente primero
      final weightOfflineDataSource = BabyWeightOfflineLocalDataSource();
      final weightRecordId = 'weight_${DateTime.now().millisecondsSinceEpoch}';

      // Crear BabyWeightRecord para guardar localmente
      final weightRecord = BabyWeightRecord(
        id: weightRecordId,
        userId: userId,
        weight: _weight,
        recordedAt: today,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Guardar localmente
      await weightOfflineDataSource.saveRecord(weightRecord);

      // Si hay conexión, guardar también en Firestore
      final connectivityService = ConnectivityService();
      final isConnected = await connectivityService.isConnected();

      if (isConnected) {
        try {
          final weightCollection = FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .collection('situacion')
              .doc('seleccion')
              .collection('peso');

          final docRef = await weightCollection.add(weightData);

          // Marcar como sincronizado
          await weightOfflineDataSource.markAsSynced(weightRecordId, docRef.id);
        } catch (e) {
          // Si falla Firestore, agregar a cola de sincronización
          final syncQueueService = SyncQueueService();
          final operation = SyncOperation(
            id: '${weightRecordId}_${DateTime.now().millisecondsSinceEpoch}',
            operationType: SyncOperationType.create,
            collectionPath: 'peso',
            localId: weightRecordId,
            data: weightData,
            createdAt: DateTime.now(),
          );
          await syncQueueService.addOperation(operation);
        }
      } else {
        // Sin conexión: agregar a cola de sincronización
        final syncQueueService = SyncQueueService();
        final operation = SyncOperation(
          id: '${weightRecordId}_${DateTime.now().millisecondsSinceEpoch}',
          operationType: SyncOperationType.create,
          collectionPath: 'peso',
          localId: weightRecordId,
          data: weightData,
          createdAt: DateTime.now(),
        );
        await syncQueueService.addOperation(operation);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Mostrar mensaje de éxito
        void showSuccessSnack() {
          final homeCtx = navigatorKey.currentContext;
          if (homeCtx != null) {
            ScaffoldMessenger.of(homeCtx).showSnackBar(
              SnackBar(
                content: Text('forms.babyWeight.saved'.tr()),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }

        // Volver atrás
        final canPop = Navigator.of(context).canPop();
        if (canPop) {
          Navigator.of(context).pop(true);
          await Future.delayed(const Duration(milliseconds: 200));
          showSuccessSnack();
        } else {
          // Fallback: navegar a home solo si no se puede volver atrás
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (route) => false);
          await Future.delayed(const Duration(milliseconds: 200));
          showSuccessSnack();
        }
      }
    } catch (e) {
      if (mounted) {
        DialogExample.showErrorDialog(
          context,
          'forms.babyWeight.error'.tr(),
          'No se pudieron guardar los datos.\n\nError: ${e.toString()}',
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _pad(int number) => number.toString().padLeft(2, '0');

  double _snapToTenth(double value) {
    // Ajustar al múltiplo más cercano de 0.1 dentro del rango 0.5..10
    final snapped = (value * 10).round() / 10.0;
    if (snapped < 0.5) return 0.5;
    if (snapped > 10) return 10;
    return snapped;
  }

  Future<String?> _getUserDocumentId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      if (user.email != null) {
        final userQuery = await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();
        if (userQuery.docs.isNotEmpty) {
          return userQuery.docs.first.id;
        }
      }

      final docSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      if (docSnapshot.exists) {
        return user.uid;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Si está en modo edición manual, cerrar edición en lugar de navegar atrás
        if (_isEditingWeight) {
          setState(() {
            // Normalizar valor escrito si quedó algo en el controlador
            final parsed = double.tryParse(
              _weightController.text.replaceAll(',', '.'),
            );
            if (parsed != null) {
              _weight = _snapToTenth(parsed);
            }
            _weightController.text = _weight.toStringAsFixed(1);
            _isEditingWeight = false;
          });
          FocusScope.of(context).unfocus();
          return false; // No salir de la página
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2C5F5D), // Azul teal oscuro (secundario)
                Color(0xFF1A365D), // Azul marino oscuro (primario)
                Color(0xFF4FD1C7), // Verde azulado medio vibrante (primario)
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              SafeArea(
                child: ScrollConfiguration(
                  // <-- 1. Envuelve con esto
                  behavior: ScrollConfiguration.of(context).copyWith(
                    overscroll: false, // <-- 2. Desactiva el "glow"
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _slideController,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              24.0,
                              0,
                              24.0,
                              24.0,
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                _buildHeader(),
                                const SizedBox(height: 30),
                                // Campo de peso
                                _buildWeightInput(),
                                const SizedBox(height: 24),
                                // Campo de notas opcional
                                _buildNotesSection(),
                                const SizedBox(height: 40),
                                // Botones
                                _buildActionButtons(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.monitor_weight,
            color: Colors.white,
            size: 50,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'forms.babyWeight.title'.tr(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'forms.babyWeight.question'.tr(),
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWeightInput() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Número editable
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isEditingWeight = true;
                              _weightController.text = _weight.toStringAsFixed(
                                1,
                              );
                            });
                          },
                          child: _isEditingWeight
                              ? SizedBox(
                                  width: 110,
                                  child: TextField(
                                    controller: _weightController,
                                    focusNode: _weightFocusNode,
                                    autofocus: true,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.quicksand(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onTapOutside: (_) {
                                      _weightFocusNode.requestFocus();
                                    },
                                    onSubmitted: (val) {
                                      final parsed = double.tryParse(
                                        val.replaceAll(',', '.'),
                                      );
                                      setState(() {
                                        if (parsed != null) {
                                          _weight = _snapToTenth(parsed);
                                          if (_weight > 10) _weight = 10;
                                          if (_weight < 0.5) _weight = 0.5;
                                        }
                                        _weightController.text = _weight
                                            .toStringAsFixed(1);
                                        _isEditingWeight = false;
                                      });
                                    },
                                  ),
                                )
                              : RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.quicksand(
                                      color: Colors.white,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: _weight.toStringAsFixed(1),
                                        style: GoogleFonts.quicksand(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' kg',
                                        style: GoogleFonts.quicksand(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Columna de botones + y -
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _WeightAdjustButton(
                        icon: Icons.add,
                        onPressed: () {
                          setState(() {
                            _weight = _snapToTenth(_weight + 0.1);
                            _weightController.text = _weight.toStringAsFixed(1);
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      _WeightAdjustButton(
                        icon: Icons.remove,
                        onPressed: () {
                          setState(() {
                            _weight = _snapToTenth(_weight - 0.1);
                            _weightController.text = _weight.toStringAsFixed(1);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Slider(
                value: _weight,
                min: 0.5,
                max: 10,
                divisions: 95, // 0.1 kg por división
                label: '${_weight.toStringAsFixed(1)} kg',
                activeColor: Colors.white,
                inactiveColor: Colors.white.withValues(alpha: 0.3),
                onChanged: (value) {
                  setState(() {
                    _weight = _snapToTenth(value);
                    _weightController.text = _weight.toStringAsFixed(1);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            style: GoogleFonts.quicksand(fontSize: 16, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'forms.babyWeight.notesPlaceholder'.tr(),
              hintStyle: GoogleFonts.quicksand(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botón Guardar con gradiente y sombras
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1A365D), // Azul marino oscuro
                Color(0xFF4FD1C7), // Verde azulado medio
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4FD1C7).withValues(alpha:0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha:0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveWeightRecord,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'forms.babyWeight.save'.tr(),
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// Botón para ajustar el peso
class _WeightAdjustButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _WeightAdjustButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
