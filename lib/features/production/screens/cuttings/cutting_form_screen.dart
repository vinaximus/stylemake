import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stylemake/core/constants/layout_constants.dart';
import 'package:stylemake/core/providers/dropdown_providers.dart';
import 'package:stylemake/core/utils/snackbar_utils.dart';
import 'package:stylemake/core/utils/validators.dart';
import 'package:stylemake/core/widgets/form/date_picker_field.dart';
import 'package:stylemake/core/widgets/form/dropdown_field.dart';
import 'package:stylemake/core/widgets/form/text_input_field.dart';
import 'package:stylemake/core/widgets/responsive_center.dart';
import 'package:stylemake/features/production/providers/cutting_providers.dart';

/// Cutting form screen for Add/Edit
class CuttingFormScreen extends ConsumerStatefulWidget {
  const CuttingFormScreen({super.key, this.cuttingId});

  final String? cuttingId;

  @override
  ConsumerState<CuttingFormScreen> createState() => _CuttingFormScreenState();
}

class _CuttingFormScreenState extends ConsumerState<CuttingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cuttingRefController = TextEditingController();
  final _cuttingDateController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedStyleId;
  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isEditMode => widget.cuttingId != null;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadCutting();
    } else {
      _isLoading = false;
      // Set default date to today
      _cuttingDateController.text = _dateFormat.format(DateTime.now());
    }
  }

  @override
  void dispose() {
    _cuttingRefController.dispose();
    _cuttingDateController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCutting() async {
    try {
      final repository = ref.read(cuttingRepositoryProvider);
      final cutting = await repository.getCuttingById(widget.cuttingId!);

      if (cutting != null && mounted) {
        setState(() {
          _cuttingRefController.text = cutting.cuttingRef;
          _cuttingDateController.text = _dateFormat.format(cutting.cuttingDate);
          _quantityController.text = cutting.quantityCut.toString();
          _selectedStyleId = cutting.styleId;
          _notesController.text = cutting.notes ?? '';
          _isLoading = false;
        });
      } else {
        if (mounted) {
          SnackbarUtils.showError(context, 'Cutting not found');
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarUtils.showError(context, 'Failed to load cutting: $e');
      }
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStyleId == null) {
      SnackbarUtils.showError(context, 'Please select a style');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(cuttingRepositoryProvider);
      final cuttingRef = _cuttingRefController.text.trim().toUpperCase();
      final cuttingDate = _dateFormat.parse(_cuttingDateController.text);
      final quantityCut = int.parse(_quantityController.text.trim());
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();

      if (_isEditMode) {
        await repository.updateCutting(
          id: widget.cuttingId!,
          cuttingRef: cuttingRef,
          cuttingDate: cuttingDate,
          quantityCut: quantityCut,
          styleId: _selectedStyleId!,
          notes: notes,
        );
      } else {
        await repository.createCutting(
          cuttingRef: cuttingRef,
          cuttingDate: cuttingDate,
          quantityCut: quantityCut,
          styleId: _selectedStyleId!,
          notes: notes,
        );
      }

      if (mounted) {
        ref.invalidate(cuttingsListProvider);
        SnackbarUtils.showSuccess(
          context,
          _isEditMode
              ? 'Cutting updated successfully'
              : 'Cutting created successfully',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        SnackbarUtils.showError(
          context,
          'Failed to save cutting: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stylesDropdown = ref.watch(stylesDropdownProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Cutting' : 'Add Cutting')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: ResponsiveFormContainer(
                child: Padding(
                  padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextInputField(
                          controller: _cuttingRefController,
                          label: 'Cutting Reference',
                          hint: 'e.g., CUT-2025-001',
                          validator: Validators.compose([
                            Validators.required(
                              'Cutting reference is required',
                            ),
                            Validators.minLength(
                              3,
                              'Minimum 3 characters required',
                            ),
                            Validators.maxLength(
                              50,
                              'Maximum 50 characters allowed',
                            ),
                            Validators.cuttingRefFormat(),
                          ]),
                          enabled: !_isSaving,
                          textCapitalization: TextCapitalization.characters,
                        ),
                        const SizedBox(height: LayoutConstants.spaceMedium),
                        DatePickerField(
                          controller: _cuttingDateController,
                          label: 'Cutting Date',
                          validator: Validators.required(
                            'Cutting date is required',
                          ),
                          enabled: !_isSaving,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        ),
                        const SizedBox(height: LayoutConstants.spaceMedium),
                        TextInputField(
                          controller: _quantityController,
                          label: 'Quantity Cut',
                          hint: 'Number of pieces',
                          validator: Validators.compose([
                            Validators.required('Quantity is required'),
                            Validators.positiveInteger(
                              'Please enter a positive integer',
                            ),
                          ]),
                          enabled: !_isSaving,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: LayoutConstants.spaceMedium),
                        DropdownField<String>(
                          label: 'Style',
                          hint: 'Select a style',
                          items: stylesDropdown,
                          value: _selectedStyleId,
                          onChanged: (value) {
                            setState(() {
                              _selectedStyleId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a style';
                            }
                            return null;
                          },
                          enabled: !_isSaving,
                        ),
                        const SizedBox(height: LayoutConstants.spaceMedium),
                        TextInputField(
                          controller: _notesController,
                          label: 'Notes',
                          hint: 'Optional notes',
                          validator: Validators.maxLength(
                            500,
                            'Maximum 500 characters allowed',
                          ),
                          enabled: !_isSaving,
                          maxLines: 3,
                        ),
                        const SizedBox(height: LayoutConstants.spaceXLarge),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSaving
                                    ? null
                                    : () => context.pop(),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: LayoutConstants.spaceMedium),
                            Expanded(
                              child: FilledButton(
                                onPressed: _isSaving ? null : _saveForm,
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(_isEditMode ? 'Update' : 'Save'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

