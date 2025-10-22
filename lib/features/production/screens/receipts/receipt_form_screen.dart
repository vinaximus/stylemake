import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stylemake/core/constants/layout_constants.dart';
import 'package:stylemake/core/providers/receipt_providers.dart';
import 'package:stylemake/core/utils/snackbar_utils.dart';
import 'package:stylemake/core/utils/validators.dart';
import 'package:stylemake/core/widgets/form/date_picker_field.dart';
import 'package:stylemake/core/widgets/form/dropdown_field.dart';
import 'package:stylemake/core/widgets/form/text_input_field.dart';
import 'package:stylemake/core/widgets/responsive_center.dart';
import 'package:stylemake/features/masters/providers/style_providers.dart';
import 'package:stylemake/features/production/providers/cutting_providers.dart';

class ReceiptFormScreen extends ConsumerStatefulWidget {
  const ReceiptFormScreen({super.key, this.receiptId, this.prefillCuttingId});

  final String? receiptId;
  final String? prefillCuttingId;

  @override
  ConsumerState<ReceiptFormScreen> createState() => _ReceiptFormScreenState();
}

class _ReceiptFormScreenState extends ConsumerState<ReceiptFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _qtyController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCuttingId;
  String? _selectedStyleId;

  bool _isLoading = true;
  bool _isSaving = false;
  bool get _isEditMode => widget.receiptId != null;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isEditMode) {
      await _loadReceipt();
    } else {
      _selectedCuttingId = widget.prefillCuttingId;
      _dateController.text = _dateFormat.format(DateTime.now());
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadReceipt() async {
    try {
      final receipt = await ref.read(receiptByIdProvider(widget.receiptId!).future);
      if (receipt != null) {
        _selectedCuttingId = receipt.cuttingId;
        _selectedStyleId = receipt.styleId;
        _qtyController.text = receipt.quantityReceived.toString();
        _dateController.text = _dateFormat.format(receipt.dateOfReceipt);
        _notesController.text = receipt.notes ?? '';
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to load receipt: $e');
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _qtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(receiptRepositoryProvider);
      final date = _dateFormat.parse(_dateController.text);
      final qty = int.parse(_qtyController.text);
      final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

      if (_isEditMode) {
        await repo.updateReceipt(
          id: widget.receiptId!,
          cuttingId: _selectedCuttingId!,
          styleId: _selectedStyleId!,
          quantityReceived: qty,
          dateOfReceipt: date,
          notes: notes,
        );
      } else {
        await repo.createReceipt(
          cuttingId: _selectedCuttingId!,
          styleId: _selectedStyleId!,
          quantityReceived: qty,
          dateOfReceipt: date,
          notes: notes,
        );
      }

      // refresh lists
      ref.invalidate(receiptsListProvider);
      if (_selectedCuttingId != null) {
        ref.invalidate(receiptsByCuttingProvider(_selectedCuttingId!));
      }

      if (mounted) {
        SnackbarUtils.showSuccess(
          context,
          _isEditMode ? 'Receipt updated successfully' : 'Receipt created successfully',
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to save receipt: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cuttingsAsync = ref.watch(cuttingsListProvider);
    final stylesAsync = ref.watch(stylesListProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(_isEditMode ? 'Edit Receipt' : 'Add Receipt')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final cuttingItems = cuttingsAsync.when(
      data: (list) => list
          .map((c) => DropdownMenuItem(
                value: c.id,
                child: Text('${c.cuttingRef} - ${c.styleName}'),
              ))
          .toList(),
      loading: () => <DropdownMenuItem<String>>[],
      error: (_, __) => <DropdownMenuItem<String>>[],
    );

    final styleItems = stylesAsync.when(
      data: (list) => list
          .map((s) => DropdownMenuItem(
                value: s.id,
                child: Text(s.name),
              ))
          .toList(),
      loading: () => <DropdownMenuItem<String>>[],
      error: (_, __) => <DropdownMenuItem<String>>[],
    );

    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Receipt' : 'Add Receipt'), actions: [
        IconButton(
          tooltip: 'Save receipt',
          onPressed: _isSaving ? null : _save,
          icon: const Icon(Icons.check),
        ),
      ]),
      body: ResponsiveCenter(
        maxWidth: LayoutConstants.maxFormWidth,
        padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cutting
                DropdownField<String>(
                  label: 'Cutting *',
                  value: _selectedCuttingId,
                  items: cuttingItems,
                  onChanged: (v) => setState(() => _selectedCuttingId = v),
                  validator: Validators.required('Please select a cutting'),
                ),
                const SizedBox(height: LayoutConstants.spaceMedium),

                // Style
                DropdownField<String>(
                  label: 'Style *',
                  value: _selectedStyleId,
                  items: styleItems,
                  onChanged: (v) => setState(() => _selectedStyleId = v),
                  validator: Validators.required('Please select a style'),
                ),
                const SizedBox(height: LayoutConstants.spaceMedium),

                // Quantity
                TextInputField(
                  controller: _qtyController,
                  label: 'Quantity Received *',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.inventory_2_outlined),
                  validator: Validators.compose([
                    Validators.required('Quantity is required'),
                    Validators.positiveInteger(),
                  ]),
                ),
                const SizedBox(height: LayoutConstants.spaceMedium),

                // Date of receipt
                DatePickerField(
                  controller: _dateController,
                  label: 'Date of Receipt *',
                  validator: Validators.required('Date is required'),
                ),
                const SizedBox(height: LayoutConstants.spaceMedium),

                // Notes
                TextInputField(
                  controller: _notesController,
                  label: 'Notes (Optional)',
                  maxLines: 4,
                  prefixIcon: const Icon(Icons.notes),
                  validator: Validators.maxLength(500, 'Notes must be < 500 chars'),
                ),
                const SizedBox(height: LayoutConstants.spaceLarge),

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
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Tooltip(message: 'Save receipt', child: Text('Create Receipt')),
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


