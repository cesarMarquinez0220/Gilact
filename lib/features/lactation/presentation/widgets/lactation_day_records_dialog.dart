import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../domain/entities/lactation_record.dart';
import '../../data/services/lactation_service.dart';
import 'lactation_record_form_dialog.dart';
import '../../../../alerta_dialoge.dart';

class LactationDayRecordsDialog extends StatefulWidget {
  final DateTime date;
  final List<LactationRecord> records;
  final VoidCallback onRecordAdded;
  final VoidCallback onRecordEdited;
  final VoidCallback onRecordDeleted;

  const LactationDayRecordsDialog({
    super.key,
    required this.date,
    required this.records,
    required this.onRecordAdded,
    required this.onRecordEdited,
    required this.onRecordDeleted,
  });

  @override
  State<LactationDayRecordsDialog> createState() =>
      _LactationDayRecordsDialogState();
}

class _LactationDayRecordsDialogState extends State<LactationDayRecordsDialog> {
  late LactationService _lactationService;

  @override
  void initState() {
    super.initState();
    _lactationService = LactationService(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Expanded(
                  child: widget.records.isEmpty
                      ? _buildEmptyState()
                      : _buildRecordsList(),
                ),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, d MMMM yyyy', 'es').format(widget.date),
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${widget.records.length} registro${widget.records.length != 1 ? 's' : ''}',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay registros para este día',
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega el primer registro de lactancia',
            style: GoogleFonts.quicksand(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    // Ordenar registros por hora
    final sortedRecords = List<LactationRecord>.from(widget.records)
      ..sort((a, b) => a.fechaRegistro.compareTo(b.fechaRegistro));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedRecords.length,
      itemBuilder: (context, index) {
        final record = sortedRecords[index];
        return _buildRecordCard(record);
      },
    );
  }

  Widget _buildRecordCard(LactationRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getTypeColor(record.tipo).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  _getTypeIcon(record.tipo),
                  color: _getTypeColor(record.tipo),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTypeName(record.tipo),
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(record.fechaRegistro),
                      style: GoogleFonts.quicksand(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (record.duracion.inMinutes > 0)
                      Text(
                        'Duración: ${record.duracion.inMinutes} min',
                        style: GoogleFonts.quicksand(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditRecordDialog(record);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(record);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (record.notas != null && record.notas!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                record.notas!,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
          if (_hasAdditionalData(record)) ...[
            const SizedBox(height: 12),
            _buildAdditionalData(record),
          ],
        ],
      ),
    );
  }

  Widget _buildAdditionalData(LactationRecord record) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles Adicionales',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (record.volumenExtraccion > 0)
                _buildDataChip(
                  'Volumen: ${record.volumenExtraccion} ${record.unidadVolumen}',
                  Icons.water_drop,
                ),
              if (record.vecesPecho > 0)
                _buildDataChip(
                  'Pecho: ${record.vecesPecho}x',
                  Icons.child_care,
                ),
              if (record.vecesBiberon > 0)
                _buildDataChip(
                  'Biberón: ${record.vecesBiberon}x',
                  Icons.local_drink,
                ),
              if (record.horasSuenoBebe > 0)
                _buildDataChip(
                  'Sueño: ${record.horasSuenoBebe} ${record.unidadSueno}',
                  Icons.bedtime,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF667eea).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF667eea).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF667eea)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              color: const Color(0xFF667eea),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Cerrar',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _showAddRecordDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Agregar',
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRecordDialog() {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => LactationRecordFormDialog(
        selectedDate: widget.date,
        onRecordSaved: widget.onRecordAdded,
      ),
    );
  }

  void _showEditRecordDialog(LactationRecord record) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => LactationRecordFormDialog(
        selectedDate: record.fechaRegistro,
        existingRecord: record,
        onRecordSaved: widget.onRecordEdited,
      ),
    );
  }

  void _showDeleteConfirmation(LactationRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Eliminar Registro',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar este registro de lactancia?',
          style: GoogleFonts.quicksand(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.tr(), style: GoogleFonts.quicksand()),
          ),
          ElevatedButton(
            onPressed: () async {
              final dialogContext = context;
              Navigator.of(dialogContext).pop();
              try {
                await _lactationService.deleteRecord(record.id);
                if (!mounted || !dialogContext.mounted) return;

                widget.onRecordDeleted();
                DialogExample.showSuccessDialog(
                  dialogContext,
                  'Registro Eliminado',
                  'El registro de lactancia ha sido eliminado correctamente.',
                  () {},
                );
              } catch (e) {
                if (!mounted || !dialogContext.mounted) return;

                DialogExample.showErrorDialog(
                  dialogContext,
                  'Error al Eliminar',
                  'No se pudo eliminar el registro. Por favor, inténtalo nuevamente.',
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Eliminar',
              style: GoogleFonts.quicksand(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasAdditionalData(LactationRecord record) {
    return record.volumenExtraccion > 0 ||
        record.vecesPecho > 0 ||
        record.vecesBiberon > 0 ||
        record.horasSuenoBebe > 0;
  }

  Color _getTypeColor(LactationType type) {
    switch (type) {
      case LactationType.breastfeeding:
        return const Color(0xFF4CAF50);
      case LactationType.pumping:
        return const Color(0xFF2196F3);
      case LactationType.bottle:
        return const Color(0xFFFF9800);
    }
  }

  IconData _getTypeIcon(LactationType type) {
    switch (type) {
      case LactationType.breastfeeding:
        return Icons.child_care;
      case LactationType.pumping:
        return Icons.water_drop;
      case LactationType.bottle:
        return Icons.local_drink;
    }
  }

  String _getTypeName(LactationType type) {
    switch (type) {
      case LactationType.breastfeeding:
        return 'Lactancia Directa';
      case LactationType.pumping:
        return 'Extracción';
      case LactationType.bottle:
        return 'Biberón';
    }
  }
}
