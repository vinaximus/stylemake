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
import 'package:stylemake/features/production/providers/issue_providers.dart';
import 'package:stylemake/features/production/providers/po_providers.dart';

/// Item Issue form screen for Add/Edit
class IssueFormScreen extends ConsumerStatefulWidget {
  const IssueFormScreen({super.key, this.issueId, this.poId});

  final String? issueId;
  final String? poId; // Pre-fill PO from route

  @override
  ConsumerState<IssueFormScreen> createState() => _IssueFormScreenState();
}

class _IssueFormScreenState extends ConsumerState<IssueFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issueDateController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _rateController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedPoId;

  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isEditMode => widget.issueId != null;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isEditMode) {
      await _loadIssue();
    } else {
      // Add mode
      // Pre-fill PO if provided
      if (widget.poId != null) {
        _selectedPoId = widget.poId;
      }
      // Set default issue date to today
      _issueDateController.text = _dateFormat.format(DateTime.now());
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadIssue() async {
    try {
      final issue = await ref.read(issueByIdProvider(widget.issueId!).future);
      if (issue != null) {
        _issueDateController.text = _dateFormat.format(issue.issueDate);
        _selectedPoId = issue.poId;
        _itemDescriptionController.text = issue.itemDescription;
        _quantityController.text = issue.quantity.toString();
        _rateController.text = issue.rate.toStringAsFixed(2);
        _notesController.text = issue.notes ?? '';
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Failed to load issue: ${e.toString()}',
        );
      }
    }
  }

  @override
  void dispose() {
    _issueDateController.dispose();
    _itemDescriptionController.dispose();
    _quantityController.dispose();
    _rateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveIssue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(issueRepositoryProvider);

      final quantity = int.parse(_quantityController.text);
      final rate = double.parse(_rateController.text);
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();

      // Parse date from controller
      final issueDate = _dateFormat.parse(_issueDateController.text);

      if (_isEditMode) {
        await repository.updateIssue(
          id: widget.issueId!,
          issueDate: issueDate,
          poId: _selectedPoId!,
          itemDescription: _itemDescriptionController.text.trim(),
          quantity: quantity,
          rate: rate,
          notes: notes,
        );
      } else {
        await repository.createIssue(
          issueDate: issueDate,
          poId: _selectedPoId!,
          itemDescription: _itemDescriptionController.text.trim(),
          quantity: quantity,
          rate: rate,
          notes: notes,
        );
      }

      // Refresh providers
      ref.invalidate(issuesListProvider);
      if (_selectedPoId != null) {
        ref.invalidate(issuesByPoProvider(_selectedPoId!));
      }

      if (mounted) {
        SnackbarUtils.showSuccess(
          context,
          _isEditMode
              ? 'Issue updated successfully'
              : 'Issue created successfully',
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Failed to save issue: ${e.toString()}',
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
        appBar: AppBar(title: Text(_isEditMode ? 'Edit Issue' : 'Add Issue')),
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
        title: Text(_isEditMode ? 'Edit Item Issue' : 'Add Item Issue'),
        actions: [
          IconButton(
            tooltip: 'Save issue',
            onPressed: _isSaving ? null : _saveIssue,
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
                // Issue Date
                DatePickerField(
                  controller: _issueDateController,
                  label: 'Issue Date *',
                  validator: Validators.required('Issue date is required'),
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

                // Item Description
                TextInputField(
                  controller: _itemDescriptionController,
                  label: 'Item Description *',
                  prefixIcon: const Icon(Icons.description_outlined),
                  hint: 'Enter item description',
                  maxLines: 2,
                  validator: Validators.compose([
                    Validators.required('Item description is required'),
                    Validators.maxLength(
                      200,
                      'Description must be less than 200 characters',
                    ),
                  ]),
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
                    Validators.nonNegativeDecimal(),
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
                        onPressed: _isSaving ? null : _saveIssue,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Tooltip(message: 'Save issue', child: Text('Create Issue')),
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
