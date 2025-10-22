import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stylemake/core/constants/layout_constants.dart';
import 'package:stylemake/core/utils/snackbar_utils.dart';
import 'package:stylemake/core/utils/validators.dart';
import 'package:stylemake/core/widgets/form/date_picker_field.dart';
import 'package:stylemake/core/widgets/form/dropdown_field.dart';
import 'package:stylemake/core/widgets/form/text_input_field.dart';
import 'package:stylemake/core/widgets/responsive_center.dart';
import 'package:stylemake/features/production/providers/bill_providers.dart';
import 'package:stylemake/features/production/providers/po_providers.dart';

/// Bill form screen for Add/Edit
class BillFormScreen extends ConsumerStatefulWidget {
  const BillFormScreen({super.key, this.billId, this.poId});

  final String? billId;
  final String? poId; // Pre-fill PO from route

  @override
  ConsumerState<BillFormScreen> createState() => _BillFormScreenState();
}

class _BillFormScreenState extends ConsumerState<BillFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supplierInvoiceNoController = TextEditingController();
  final _invoiceDateController = TextEditingController();
  final _quantityController = TextEditingController();
  final _rateController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedPoId;

  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isEditMode => widget.billId != null;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isEditMode) {
      await _loadBill();
    } else {
      // Add mode
      // Pre-fill PO if provided
      if (widget.poId != null) {
        _selectedPoId = widget.poId;
      }
      // Set default invoice date to today
      _invoiceDateController.text = _dateFormat.format(DateTime.now());
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadBill() async {
    try {
      final bill = await ref.read(billByIdProvider(widget.billId!).future);
      if (bill != null) {
        _supplierInvoiceNoController.text = bill.supplierInvoiceNo;
        _invoiceDateController.text = _dateFormat.format(bill.invoiceDate);
        _selectedPoId = bill.poId;
        _quantityController.text = bill.quantity.toString();
        _rateController.text = bill.rate.toStringAsFixed(2);
        _notesController.text = bill.notes ?? '';
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Failed to load bill: ${e.toString()}',
        );
      }
    }
  }

  @override
  void dispose() {
    _supplierInvoiceNoController.dispose();
    _invoiceDateController.dispose();
    _quantityController.dispose();
    _rateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(billRepositoryProvider);

      final quantity = int.parse(_quantityController.text);
      final rate = double.parse(_rateController.text);
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();

      // Parse date from controller
      final invoiceDate = _dateFormat.parse(_invoiceDateController.text);

      if (_isEditMode) {
        await repository.updateBill(
          id: widget.billId!,
          supplierInvoiceNo: _supplierInvoiceNoController.text.trim(),
          invoiceDate: invoiceDate,
          poId: _selectedPoId!,
          quantity: quantity,
          rate: rate,
          notes: notes,
        );
      } else {
        await repository.createBill(
          supplierInvoiceNo: _supplierInvoiceNoController.text.trim(),
          invoiceDate: invoiceDate,
          poId: _selectedPoId!,
          quantity: quantity,
          rate: rate,
          notes: notes,
        );
      }

      // Refresh providers
      ref.invalidate(billsListProvider);
      if (_selectedPoId != null) {
        ref.invalidate(billsByPoProvider(_selectedPoId!));
      }

      if (mounted) {
        SnackbarUtils.showSuccess(
          context,
          _isEditMode
              ? 'Bill updated successfully'
              : 'Bill created successfully',
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Failed to save bill: ${e.toString()}',
        );
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
    final posAsync = ref.watch(posListProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(_isEditMode ? 'Edit Bill' : 'Add Bill')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Build PO dropdown items
    final poDropdownItems = posAsync.when(
      data: (pos) => pos
          .map(
            (po) => DropdownMenuItem(
              value: po.id,
              child: Text('${po.poNumber} - ${po.vendorName}'),
            ),
          )
          .toList(),
      loading: () => <DropdownMenuItem<String>>[],
      error: (_, __) => <DropdownMenuItem<String>>[],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Bill' : 'Add Bill'),
        actions: [
          IconButton(
            tooltip: 'Save bill',
            onPressed: _isSaving ? null : _saveBill,
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
                // Supplier Invoice No
                TextInputField(
                  controller: _supplierInvoiceNoController,
                  label: 'Supplier Invoice Number *',
                  prefixIcon: const Icon(Icons.receipt_outlined),
                  hint: 'Enter supplier invoice number',
                  validator: Validators.compose([
                    Validators.required('Supplier invoice number is required'),
                    Validators.maxLength(
                      100,
                      'Invoice number must be less than 100 characters',
                    ),
                  ]),
                ),
                const SizedBox(height: LayoutConstants.spaceMedium),

                // Invoice Date
                DatePickerField(
                  controller: _invoiceDateController,
                  label: 'Invoice Date *',
                  validator: Validators.required('Invoice date is required'),
                ),
                const SizedBox(height: LayoutConstants.spaceMedium),

                // Related PO
                DropdownField<String>(
                  label: 'Related Purchase Order *',
                  value: _selectedPoId,
                  items: poDropdownItems,
                  onChanged: (value) {
                    setState(() => _selectedPoId = value);
                  },
                  validator: Validators.required('Please select a PO'),
                ),
                const SizedBox(height: LayoutConstants.spaceMedium),

                // Quantity
                TextInputField(
                  controller: _quantityController,
                  label: 'Quantity *',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.inventory_2_outlined),
                  hint: 'Enter quantity',
                  validator: Validators.compose([
                    Validators.required('Quantity is required'),
                    Validators.positiveInteger(),
                  ]),
                  onChanged: (value) {
                    setState(() {}); // Recalculate total
                  },
                ),
                const SizedBox(height: LayoutConstants.spaceMedium),

                // Rate
                TextInputField(
                  controller: _rateController,
                  label: 'Rate *',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixIcon: const Icon(Icons.currency_rupee),
                  hint: 'Enter rate',
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
                    children: [
                      Text(
                        'Total Amount:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${_totalAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: LayoutConstants.spaceMedium),

                // Notes
                TextInputField(
                  controller: _notesController,
                  label: 'Notes (Optional)',
                  maxLines: 4,
                  prefixIcon: const Icon(Icons.notes),
                  validator: Validators.maxLength(
                    500,
                    'Notes must be less than 500 characters',
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
                        onPressed: _isSaving ? null : _saveBill,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Tooltip(message: 'Save bill', child: Text('Create Bill')),
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
