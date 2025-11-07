import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stylemake/shared/constants/layout_constants.dart';
import 'package:stylemake/app/router/app_router.dart';
import 'package:stylemake/shared/utils/snackbar_utils.dart';
import 'package:stylemake/shared/utils/validators.dart';
import 'package:stylemake/shared/widgets/responsive_center.dart';
import 'package:stylemake/shared/widgets/form/text_input_field.dart';
import 'package:stylemake/shared/widgets/form/customer_autocomplete_field.dart';
import 'package:stylemake/features/dispatch/presentation/viewmodels/dispatch_view_model.dart';
import 'package:stylemake/features/dispatch/presentation/widgets/dispatch_item_form.dart';

/// Dispatch form screen for adding/editing dispatches
class DispatchFormScreen extends ConsumerStatefulWidget {
  const DispatchFormScreen({super.key, this.dispatchId});

  final String? dispatchId;

  @override
  ConsumerState<DispatchFormScreen> createState() => _DispatchFormScreenState();
}

class _DispatchFormScreenState extends ConsumerState<DispatchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dispatchNoController = TextEditingController();
  final _customerController = TextEditingController();
  String? _selectedCustomerId;
  final _transportNameController = TextEditingController();
  final _vehicleNoController = TextEditingController();
  final _lrNoController = TextEditingController();
  final _remarksController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.dispatchId != null) {
      _loadDispatch();
    } else {
      _generateDispatchNo();
    }
  }

  @override
  void dispose() {
    _dispatchNoController.dispose();
    _customerController.dispose();
    _transportNameController.dispose();
    _vehicleNoController.dispose();
    _lrNoController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _loadDispatch() async {
    setState(() => _isLoading = true);
    try {
      final repository = ref.read(dispatchRepositoryProvider);
      final dispatch = await repository.getDispatchById(widget.dispatchId!);

      if (dispatch != null && mounted) {
        _selectedCustomerId = dispatch.customerId;
        // Load customer name for display
        final customerRepository = ref.read(customerRepositoryProvider);
        final customer = await customerRepository.getCustomerById(
          dispatch.customerId,
        );

        if (mounted) {
          setState(() {
            _dispatchNoController.text = dispatch.dispatchNo;
            _selectedDate = dispatch.dispatchDate;
            if (customer != null) {
              _customerController.text = customer.customerName;
            }
            _transportNameController.text = dispatch.transportName ?? '';
            _vehicleNoController.text = dispatch.vehicleNo ?? '';
            _lrNoController.text = dispatch.lrNo ?? '';
            _remarksController.text = dispatch.remarks ?? '';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to load dispatch: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _generateDispatchNo() async {
    try {
      final repository = ref.read(dispatchRepositoryProvider);
      final dispatchNo = await repository.generateDispatchNo();
      if (mounted) {
        _dispatchNoController.text = dispatchNo;
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Failed to generate dispatch number: $e',
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveDispatch() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCustomerId == null || _selectedCustomerId!.isEmpty) {
      SnackbarUtils.showError(context, 'Please select a customer');
      return;
    }

    final items = ref.read(dispatchFormItemsProvider);
    if (items.isEmpty) {
      SnackbarUtils.showError(context, 'At least one item is required');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(dispatchRepositoryProvider);

      final masterData = {
        'dispatch_no': _dispatchNoController.text.trim(),
        'dispatch_date': _selectedDate.toIso8601String().split('T')[0],
        'customer_id': _selectedCustomerId ?? '',
        'transport_name': _transportNameController.text.trim().isEmpty
            ? null
            : _transportNameController.text.trim(),
        'vehicle_no': _vehicleNoController.text.trim().isEmpty
            ? null
            : _vehicleNoController.text.trim(),
        'lr_no': _lrNoController.text.trim().isEmpty
            ? null
            : _lrNoController.text.trim(),
        'remarks': _remarksController.text.trim().isEmpty
            ? null
            : _remarksController.text.trim(),
      };

      final itemsData = ref.read(dispatchFormItemsProvider);

      if (widget.dispatchId == null) {
        // Create new dispatch
        await repository.createDispatch(masterData, itemsData);
        if (mounted) {
          SnackbarUtils.showSuccess(context, 'Dispatch created successfully');
        }
      } else {
        // Update existing dispatch
        await repository.updateDispatch(
          widget.dispatchId!,
          masterData,
          itemsData,
        );
        if (mounted) {
          SnackbarUtils.showSuccess(context, 'Dispatch updated successfully');
        }
      }

      // Invalidate providers to refresh the list
      ref.invalidate(dispatchesListProvider);
      ref.invalidate(filteredDispatchesProvider);

      if (mounted) {
        context.go(AppRouter.dispatchesList);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to save dispatch: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.dispatchId == null ? 'Add Dispatch' : 'Edit Dispatch',
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveDispatch,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: ResponsiveFormContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMasterSection(),
                const SizedBox(height: LayoutConstants.spaceLarge),
                _buildItemsSection(),
                const SizedBox(height: LayoutConstants.spaceLarge),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMasterSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dispatch Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: LayoutConstants.spaceMedium),
            Row(
              children: [
                Expanded(
                  child: TextInputField(
                    controller: _dispatchNoController,
                    label: 'Dispatch No',
                    hint: 'e.g., DCH-0001',
                    validator: Validators.compose([
                      Validators.required('Dispatch number is required'),
                    ]),
                    enabled: !_isSaving,
                  ),
                ),
                const SizedBox(width: LayoutConstants.spaceMedium),
                Expanded(
                  child: InkWell(
                    onTap: _isSaving ? null : _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Dispatch Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        DateFormat('MMM dd, yyyy').format(_selectedDate),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: LayoutConstants.spaceMedium),
            CustomerAutocompleteField(
              controller: _customerController,
              label: 'Customer',
              hint: 'Search and select customer',
              validator: Validators.compose([
                Validators.required('Customer is required'),
              ]),
              enabled: !_isSaving,
              onChanged: (customerId) {
                setState(() {
                  _selectedCustomerId = customerId;
                });
              },
            ),
            const SizedBox(height: LayoutConstants.spaceMedium),
            Row(
              children: [
                Expanded(
                  child: TextInputField(
                    controller: _transportNameController,
                    label: 'Transport Name',
                    hint: 'e.g., ABC Transport',
                    enabled: !_isSaving,
                  ),
                ),
                const SizedBox(width: LayoutConstants.spaceMedium),
                Expanded(
                  child: TextInputField(
                    controller: _vehicleNoController,
                    label: 'Vehicle No',
                    hint: 'e.g., KA-01-AB-1234',
                    enabled: !_isSaving,
                  ),
                ),
              ],
            ),
            const SizedBox(height: LayoutConstants.spaceMedium),
            TextInputField(
              controller: _lrNoController,
              label: 'LR No',
              hint: 'Lorry receipt number',
              enabled: !_isSaving,
            ),
            const SizedBox(height: LayoutConstants.spaceMedium),
            TextInputField(
              controller: _remarksController,
              label: 'Remarks',
              hint: 'Additional notes',
              maxLines: 3,
              enabled: !_isSaving,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    final items = ref.watch(dispatchFormItemsProvider);
    final totalQuantity = ref.watch(dispatchTotalQuantityProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dispatch Items',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: LayoutConstants.spaceMedium),
            if (items.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(LayoutConstants.paddingLarge),
                  child: Text(
                    'No items added yet. Click "Add Item" to get started.',
                  ),
                ),
              )
            else
              Column(
                children: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildItemCard(index, item);
                }).toList(),
              ),
            if (items.isNotEmpty) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: LayoutConstants.spaceSmall,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Quantity:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      totalQuantity.toInt().toString(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(int index, Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: LayoutConstants.spaceSmall),
      child: Padding(
        padding: const EdgeInsets.all(LayoutConstants.paddingSmall),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Item ${index + 1}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _isSaving ? null : () => _editItem(index),
                  tooltip: 'Edit Item',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _isSaving ? null : () => _removeItem(index),
                  tooltip: 'Remove Item',
                ),
              ],
            ),
            const SizedBox(height: LayoutConstants.spaceSmall),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Style: ${item['style_name'] ?? item['style_id'] ?? 'Not selected'}',
                  ),
                ),
                Expanded(child: Text('Qty: ${item['quantity'] ?? 0}')),
              ],
            ),
            if (item['color'] != null && item['color'].toString().isNotEmpty)
              Text('Color: ${item['color']}'),
            if (item['size'] != null && item['size'].toString().isNotEmpty)
              Text('Size: ${item['size']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSaving
                ? null
                : () => context.go(AppRouter.dispatchesList),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: LayoutConstants.spaceMedium),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveDispatch,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Dispatch'),
          ),
        ),
      ],
    );
  }

  void _addItem() async {
    final result = await showDispatchItemForm(context);
    if (result != null) {
      final items = List<Map<String, dynamic>>.from(
        ref.read(dispatchFormItemsProvider),
      );
      items.add(result);
      ref.read(dispatchFormItemsProvider.notifier).state = items;
    }
  }

  void _editItem(int index) async {
    final items = ref.read(dispatchFormItemsProvider);
    final item = items[index];

    final result = await showDispatchItemForm(context, initialData: item);
    if (result != null) {
      final updatedItems = List<Map<String, dynamic>>.from(items);
      updatedItems[index] = result;
      ref.read(dispatchFormItemsProvider.notifier).state = updatedItems;
    }
  }

  void _removeItem(int index) {
    final items = List<Map<String, dynamic>>.from(
      ref.read(dispatchFormItemsProvider),
    );
    items.removeAt(index);
    ref.read(dispatchFormItemsProvider.notifier).state = items;
  }
}
