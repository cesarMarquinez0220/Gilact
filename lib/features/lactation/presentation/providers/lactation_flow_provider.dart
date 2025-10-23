import 'package:flutter/material.dart';
import '../../domain/services/lactation_decision_tree.dart';
import '../../data/services/lactation_flow_service.dart';
import '../../domain/entities/lactation_record.dart';

/// Provider para manejar el estado del flujo de lactancia
class LactationFlowProvider extends ChangeNotifier {
  final LactationFlowService _flowService;

  LactationFlowProvider(this._flowService);

  // Estado del flujo
  LactationFlowContext _context = LactationFlowContext(
    data: {},
    currentStep: LactationStep.initial,
    history: [],
  );

  // Estado de carga
  bool _isLoading = false;
  String? _errorMessage;

  // Estadísticas del usuario
  Map<String, dynamic> _userStatistics = {};

  // Getters
  LactationFlowContext get context => _context;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get userStatistics => _userStatistics;

  /// Inicializa el provider con un registro existente
  Future<void> initializeWithRecord(LactationRecord? record) async {
    if (record != null) {
      _context = _flowService.recordToFlowContext(record);
      notifyListeners();
    }

    // Cargar estadísticas del usuario
    await _loadUserStatistics();
  }

  /// Selecciona una opción y avanza al siguiente paso
  Future<void> selectOption(LactationOption option) async {
    try {
      _setLoading(true);
      _clearError();

      // Agregar respuesta al contexto
      _context = _context.addResponse(_context.currentStep.name, option.id);

      // Determinar el siguiente paso
      final nextStep = LactationDecisionTree.getNextStep(
        currentStep: _context.currentStep,
        userResponse: option.id,
        context: _context.data,
      );

      // Actualizar contexto
      _context = _context.copyWith(currentStep: nextStep);

      notifyListeners();
    } catch (e) {
      _setError('Error al procesar selección: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Retrocede al paso anterior
  void goToPreviousStep() {
    if (_context.history.length > 1) {
      // Implementar lógica para volver al paso anterior
      // Por simplicidad, reiniciamos el flujo
      _context = LactationFlowContext(
        data: {},
        currentStep: LactationStep.initial,
        history: [],
      );
      notifyListeners();
    }
  }

  /// Guarda el registro de lactancia
  Future<bool> saveRecord({
    DateTime? selectedDate,
    String? existingRecordId,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _flowService.saveLactationRecord(
        context: _context,
        selectedDate: selectedDate,
        existingRecordId: existingRecordId,
      );

      // Marcar como completado
      _context = _context.copyWith(currentStep: LactationStep.completed);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al guardar registro: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Elimina un registro
  Future<bool> deleteRecord(String recordId) async {
    try {
      _setLoading(true);
      _clearError();

      await _flowService.deleteLactationRecord(recordId);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al eliminar registro: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Obtiene sugerencias inteligentes para el paso actual
  Future<List<String>> getIntelligentSuggestions() async {
    try {
      return await _flowService.getIntelligentSuggestions(
        currentStep: _context.currentStep,
        userStats: _userStatistics,
      );
    } catch (e) {
      return [];
    }
  }

  /// Verifica si el usuario puede registrar lactancia
  Future<bool> canUserRegisterLactation() async {
    try {
      return await _flowService.canUserRegisterLactation();
    } catch (e) {
      return false;
    }
  }

  /// Reinicia el flujo
  void resetFlow() {
    _context = LactationFlowContext(
      data: {},
      currentStep: LactationStep.initial,
      history: [],
    );
    _clearError();
    notifyListeners();
  }

  /// Carga las estadísticas del usuario
  Future<void> _loadUserStatistics() async {
    try {
      _userStatistics = await _flowService.getUserStatistics();
      notifyListeners();
    } catch (e) {
      // Las estadísticas no son críticas, continuar sin ellas
    }
  }

  /// Establece el estado de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Establece un mensaje de error
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Limpia el mensaje de error
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Obtiene el progreso del flujo
  double getProgress() {
    final currentStepNumber = _getCurrentStepNumber();
    final totalSteps = _getTotalSteps();
    return currentStepNumber / totalSteps;
  }

  /// Obtiene el número del paso actual
  int _getCurrentStepNumber() {
    switch (_context.currentStep) {
      case LactationStep.initial:
        return 1;
      case LactationStep.breastOrBottle:
        return 2;
      case LactationStep.breastSide:
        return 3;
      case LactationStep.breastDuration:
        return 4;
      case LactationStep.bottleVolume:
        return 4;
      case LactationStep.sleepTime:
        return 5;
      case LactationStep.extractionVolume:
        return 6;
      case LactationStep.confirmation:
        return 7;
      case LactationStep.completed:
        return 8;
    }
  }

  /// Obtiene el total de pasos
  int _getTotalSteps() {
    return 8;
  }

  /// Obtiene el mensaje del paso actual
  String getCurrentStepMessage() {
    return LactationDecisionTree.getMessageForStep(_context.currentStep);
  }

  /// Obtiene las opciones del paso actual
  List<LactationOption> getCurrentStepOptions() {
    return LactationDecisionTree.getOptionsForStep(_context.currentStep);
  }

  /// Verifica si el flujo está completado
  bool get isCompleted => _context.currentStep == LactationStep.completed;

  /// Verifica si hay datos para mostrar en el resumen
  bool get hasSummaryData {
    return _context.data.isNotEmpty;
  }

  /// Obtiene un resumen de los datos ingresados
  Map<String, String> getSummaryData() {
    final summary = <String, String>{};

    if (_context.hasBreastfeeding) {
      final lado = _context.data['breastSide'] ?? 'No especificado';
      final duracion = _context.data['breastDuration'] ?? '0';
      summary['Lactancia Materna'] = '$lado - $duracion min';
    }

    final bottleVolume = _context.data['bottleVolume'];
    if (bottleVolume != null && bottleVolume != '0') {
      summary['Biberón'] = '$bottleVolume ml';
    }

    final sleepTime = _context.data['sleepTime'];
    if (sleepTime != null && sleepTime != '0') {
      summary['Sueño'] = '$sleepTime min';
    }

    final extractionVolume = _context.data['extractionVolume'];
    if (extractionVolume != null && extractionVolume != '0') {
      summary['Extracción'] = '$extractionVolume ml';
    }

    return summary;
  }
}
