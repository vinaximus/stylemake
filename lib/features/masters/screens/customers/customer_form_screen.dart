import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylemake/core/constants/layout_constants.dart';
import 'package:stylemake/core/widgets/responsive_center.dart';
import 'package:stylemake/features/masters/providers/customer_providers.dart';

/// Screen for adding or editing a customer
class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({super.key, this.customerId});

  final String? customerId;

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstNoController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.customerId != null) {
      _loadCustomer();
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _gstNoController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomer() async {
    setState(() => _isLoading = true);

    try {
      final customerAsync = await ref.read(
        customerProvider(widget.customerId!).future,
      );

      if (customerAsync != null && mounted) {
        _customerNameController.text = customerAsync.customerName;
        _contactPersonController.text = customerAsync.contactPerson ?? '';
        _phoneController.text = customerAsync.phone ?? '';
        _addressController.text = customerAsync.address ?? '';
        _gstNoController.text = customerAsync.gstNo ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load customer: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.customerId == null ? 'Add Customer' : 'Edit Customer',
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.customerId == null ? 'Add Customer' : 'Edit Customer',
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveCustomer,
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
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
            children: [
              _buildCustomerNameField(),
              const SizedBox(height: LayoutConstants.spaceMedium),
              _buildContactPersonField(),
              const SizedBox(height: LayoutConstants.spaceMedium),
              _buildPhoneField(),
              const SizedBox(height: LayoutConstants.spaceMedium),
              _buildAddressField(),
              const SizedBox(height: LayoutConstants.spaceMedium),
              _buildGstNoField(),
              const SizedBox(height: LayoutConstants.spaceXLarge),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerNameField() {
    return TextFormField(
      controller: _customerNameController,
      decoration: const InputDecoration(
        labelText: 'Customer Name *',
        hintText: 'Enter customer name',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Customer name is required';
        }
        if (value.trim().length < 2) {
          return 'Customer name must be at least 2 characters';
        }
        if (value.trim().length > 100) {
          return 'Customer name must be less than 100 characters';
        }
        return null;
      },
    );
  }

  Widget _buildContactPersonField() {
    return TextFormField(
      controller: _contactPersonController,
      decoration: const InputDecoration(
        labelText: 'Contact Person',
        hintText: 'Enter contact person name',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value != null && value.trim().length > 100) {
          return 'Contact person name must be less than 100 characters';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: 'Phone',
        hintText: 'Enter phone number',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value != null && value.trim().isNotEmpty) {
          // Basic phone validation - at least 10 digits
          final phoneRegex = RegExp(r'^[\d\s\-\+\(\)]{10,}$');
          if (!phoneRegex.hasMatch(value.trim())) {
            return 'Please enter a valid phone number';
          }
        }
        return null;
      },
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Address',
        hintText: 'Enter address',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value != null && value.trim().length > 500) {
          return 'Address must be less than 500 characters';
        }
        return null;
      },
    );
  }

  Widget _buildGstNoField() {
    return TextFormField(
      controller: _gstNoController,
      decoration: const InputDecoration(
        labelText: 'GST Number',
        hintText: 'Enter GST number',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value != null && value.trim().isNotEmpty) {
          // Basic GST validation - 15 characters, alphanumeric
          final gstRegex = RegExp(
            r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
          );
          if (!gstRegex.hasMatch(value.trim().toUpperCase())) {
            return 'Please enter a valid GST number';
          }
        }
        return null;
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: LayoutConstants.spaceMedium),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveCustomer,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    widget.customerId == null
                        ? 'Add Customer'
                        : 'Update Customer',
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(customerRepositoryProvider);

      final customerData = {
        'customer_name': _customerNameController.text.trim(),
        'contact_person': _contactPersonController.text.trim().isEmpty
            ? null
            : _contactPersonController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'address': _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        'gst_no': _gstNoController.text.trim().isEmpty
            ? null
            : _gstNoController.text.trim().toUpperCase(),
      };

      if (widget.customerId == null) {
        await repository.createCustomer(customerData);
        // Invalidate providers to refresh the list
        ref.invalidate(customersListProvider);
        ref.invalidate(filteredCustomersProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Customer added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await repository.updateCustomer(widget.customerId!, customerData);
        // Invalidate providers to refresh the list
        ref.invalidate(customersListProvider);
        ref.invalidate(filteredCustomersProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Customer updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save customer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
