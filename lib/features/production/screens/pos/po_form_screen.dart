import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stylemake/core/constants/layout_constants.dart';
import 'package:stylemake/core/models/fabrication_po.dart';
import 'package:stylemake/core/providers/dropdown_providers.dart';
import 'package:stylemake/core/utils/snackbar_utils.dart';
import 'package:stylemake/core/utils/validators.dart';
import 'package:stylemake/core/widgets/form/date_picker_field.dart';
import 'package:stylemake/core/widgets/form/dropdown_field.dart';
import 'package:stylemake/core/widgets/form/text_input_field.dart';
import 'package:stylemake/core/widgets/responsive_center.dart';
import 'package:stylemake/features/production/providers/po_providers.dart';

/// Purchase Order form screen for Add/Edit
class PoFormScreen extends ConsumerStatefulWidget {
  const PoFormScreen({super.key, this.poId, this.cuttingId});

  final String? poId;
  final String? cuttingId; // Pre-fill cutting from route

  @override
  ConsumerState<PoFormScreen> createState() => _PoFormScreenState();
}

class _PoFormScreenState extends ConsumerState<PoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _poNumberController = TextEditingController();
  final _jobOrderNoController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _completionDateController = TextEditingController();
  final _quantityController = TextEditingController();
  final _rateController = TextEditingController();
  final _instructionsController = TextEditingController();

  String? _selectedCuttingId;
  String? _selectedVendorId;
  String? _selectedFabricationType;

  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isEditMode => widget.poId != null;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isEditMode) {
      await _loadPo();
    } else {
      // Add mode
      await _generatePoNumber();
      // Pre-fill cutting if provided
      if (widget.cuttingId != null) {
        _selectedCuttingId = widget.cuttingId;
      }
      // Set default issue date to today
      _issueDateController.text = _dateFormat.format(DateTime.now());
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generatePoNumber() async {
    try {
      final repository = ref.read(poRepositoryProvider);
      final poNumber = await repository.generatePoNumber();
      _poNumberController.text = poNumber;
    } catch (e) {
      _poNumberController.text = 'PO-0001';
    }
  }

  Future<void> _loadPo() async {
    try {
      final po = await ref.read(poByIdProvider(widget.poId!).future);
      if (po != null) {
        _poNumberController.text = po.poNumber;
        _selectedCuttingId = po.cuttingId;
        _jobOrderNoController.text = po.jobOrderNo;
        _selectedVendorId = po.vendorId;
        _selectedFabricationType = po.fabricationType;

        _issueDateController.text = _dateFormat.format(po.dateOfIssue);

        if (po.completionDate != null) {
          _completionDateController.text = _dateFormat.format(
            po.completionDate!,
          );
        }

        _quantityController.text = po.quantityIssued.toString();
        _rateController.text = po.ratePerUnit.toStringAsFixed(2);
        _instructionsController.text = po.instructions ?? '';
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to load PO: ${e.toString()}');
      }
    }
  }

  @override
  void dispose() {
    _poNumberController.dispose();
    _jobOrderNoController.dispose();
    _issueDateController.dispose();
    _completionDateController.dispose();
    _quantityController.dispose();
    _rateController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _savePo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(poRepositoryProvider);

      final quantity = int.parse(_quantityController.text);
      final rate = double.parse(_rateController.text);
      final instructions = _instructionsController.text.trim().isEmpty
          ? null
          : _instructionsController.text.trim();

      // Parse dates from controllers
      final issueDate = _dateFormat.parse(_issueDateController.text);
      final completionDate = _completionDateController.text.isNotEmpty
          ? _dateFormat.parse(_completionDateController.text)
          : null;

      if (_isEditMode) {
        await repository.updatePo(
          id: widget.poId!,
          cuttingId: _selectedCuttingId!,
          jobOrderNo: _jobOrderNoController.text.trim(),
          vendorId: _selectedVendorId!,
          fabricationType: _selectedFabricationType!,
          dateOfIssue: issueDate,
          completionDate: completionDate,
          quantityIssued: quantity,
          ratePerUnit: rate,
          instructions: instructions,
        );
      } else {
        await repository.createPo(
          poNumber: _poNumberController.text.trim(),
          cuttingId: _selectedCuttingId!,
          jobOrderNo: _jobOrderNoController.text.trim(),
          vendorId: _selectedVendorId!,
          fabricationType: _selectedFabricationType!,
          dateOfIssue: issueDate,
          completionDate: completionDate,
          quantityIssued: quantity,
          ratePerUnit: rate,
          instructions: instructions,
        );
      }

      // Refresh providers
      ref.invalidate(posListProvider);
      if (_selectedCuttingId != null) {
        ref.invalidate(posByCuttingProvider(_selectedCuttingId!));
      }

      if (mounted) {
        SnackbarUtils.showSuccess(
          context,
          _isEditMode ? 'PO updated successfully' : 'PO created successfully',
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to save PO: ${e.toString()}');
      }
    }
  }

  double get _totalAmount {
    final qty = int.tryParse(_quantityController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0.0;
    return qty * rate;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cuttingsDropdown = ref.watch(cuttingsDropdownProvider);
    final vendorsDropdown = ref.watch(vendorsDropdownProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(_isEditMode ? 'Edit PO' : 'Add PO')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Purchase Order' : 'Create Purchase Order'),
        actions: [
          IconButton(
            tooltip: 'Save purchase order',
            onPressed: _isSaving ? null : _savePo,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: ResponsiveCenter(
        maxWidth: LayoutConstants.maxFormWidth,
        padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PO Number (Read-only)
                TextInputField(
                  controller: _poNumberController,
                  label: 'PO Number',
                  enabled: false,
                  prefixIcon: const Icon(Icons.numbers),
                ),
                const SizedBox(height: LayoutConstants.spaceMedium),

                // Cutting Reference
                DropdownField<String>(
                  label: 'Cutting Reference *',
                  value: _selectedCuttingId,
                  items: cuttingsDropdown,
                  onChanged: (value) {
                    setState(() => _selectedCuttingId = value);
                  },
                  validator: Validators.required('Please select a cutting'),
                ),
                const SizedBox(height: LayoutConstants.spaceMedium),

                // Job Order No
                TextInputField(
                  controller: _jobOrderNoController,
                  label: 'Job Order Number *',
                  prefixIcon: const Icon(Icons.work_outline),
                  validator: Validators.compose([
                    Validators.required('Job Order No is required'),
                    Validators.jobOrderNo(),
                  ]),
                ),
                const SizedBox(height: LayoutConstants.spaceMedium),

                // Vendor
                DropdownField<String>(
                  label: 'Vendor *',
                  value: _selectedVendorId,
                  items: vendorsDropdown,
                  onChanged: (value) {
                    setState(() => _selectedVendorId = value);
                  },
                  validator: Validators.required('Please select a vendor'),
                ),
                const SizedBox(height: LayoutConstants.spaceMedium),

                // Fabrication Type
                DropdownField<String>(
                  label: 'Fabrication Type *',
                  value: _selectedFabricationType,
                  items: FabricationType.all
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedFabricationType = value);
                  },
                  validator: Validators.required(
                    'Please select fabrication type',
                  ),
                ),
                const SizedBox(height: LayoutConstants.spaceMedium),

                // Issue Date
                DatePickerField(
                  controller: _issueDateController,
                  label: 'Issue Date *',
                  validator: Validators.required('Issue date is required'),
                ),
                const SizedBox(height: LayoutConstants.spaceMedium),

                // Completion Date
                DatePickerField(
                  controller: _completionDateController,
                  label: 'Completion Date (Optional)',
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    if (_issueDateController.text.isEmpty) return null;
                    try {
                      final issueDate = _dateFormat.parse(
                        _issueDateController.text,
                      );
                      final compDate = _dateFormat.parse(value);
                      if (compDate.isBefore(issueDate)) {
                        return 'Must be on or after Issue Date';
                      }
                    } catch (e) {
                      return 'Invalid date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: LayoutConstants.spaceMedium),

                // Quantity Issued
                TextInputField(
                  controller: _quantityController,
                  label: 'Quantity Issued *',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.inventory_2_outlined),
                  hint: 'Enter quantity in pieces',
                  validator: Validators.compose([
                    Validators.required('Quantity is required'),
                    Validators.positiveInteger(),
                  ]),
                  onChanged: (value) {
                    setState(() {}); // Recalculate total
                  },
                ),
                const SizedBox(height: LayoutConstants.spaceMedium),

                // Rate per Unit
                TextInputField(
                  controller: _rateController,
                  label: 'Rate per Unit *',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixIcon: const Icon(Icons.currency_rupee),
                  hint: 'Enter rate in rupees',
                  validator: Validators.compose([
                    Validators.required('Rate is required'),
                    Validators.positiveDecimal(),
                  ]),
                  onChanged: (value) {
                    setState(() {}); // Recalculate total
                  },
                ),
                const SizedBox(height: LayoutConstants.spaceSmall),

                // Total Amount Display
                Container(
                  padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          'Total Amount:',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '₹${_totalAmount.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: LayoutConstants.spaceMedium),

                // Instructions
                TextInputField(
                  controller: _instructionsController,
                  label: 'Instructions (Optional)',
                  maxLines: 4,
                  prefixIcon: const Icon(Icons.notes),
                  validator: Validators.maxLength(
                    500,
                    'Instructions must be less than 500 characters',
                  ),
                ),
                const SizedBox(height: LayoutConstants.spaceLarge),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: LayoutConstants.spaceMedium),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _savePo,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_isEditMode ? 'Update PO' : 'Create PO'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
