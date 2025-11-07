import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylemake/features/masters/data/models/customer.dart';
import 'package:stylemake/features/masters/data/repositories/customer_repository.dart';

/// Autocomplete field for customer selection
class CustomerAutocompleteField extends ConsumerStatefulWidget {
  const CustomerAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final bool enabled;
  final void Function(String?)? onChanged;

  @override
  ConsumerState<CustomerAutocompleteField> createState() => _CustomerAutocompleteFieldState();
}

class _CustomerAutocompleteFieldState extends ConsumerState<CustomerAutocompleteField> {
  final CustomerRepository _customerRepository = CustomerRepository();
  List<Customer> _customers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      final customers = await _customerRepository.getAllCustomers();
      if (mounted) {
        setState(() {
          _customers = customers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Customer> _filterCustomers(String query) {
    if (query.isEmpty) return _customers;
    
    final lowercaseQuery = query.toLowerCase();
    return _customers.where((customer) {
      return customer.customerName.toLowerCase().contains(lowercaseQuery) ||
             (customer.contactPerson?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             (customer.phone?.contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Customer>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Customer>.empty();
        }
        return _filterCustomers(textEditingValue.text);
      },
      displayStringForOption: (Customer customer) => customer.customerName,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        // Sync the external controller with the internal one
        if (controller.text != widget.controller.text) {
          controller.text = widget.controller.text;
        }
        
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint ?? 'Search customers...',
            suffixIcon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.search),
            border: const OutlineInputBorder(),
          ),
          validator: widget.validator,
          enabled: widget.enabled,
          onChanged: (value) {
            widget.controller.text = value;
            // Don't call onChanged here - only when a customer is actually selected
            // If user types manually without selecting, we clear the selection
            if (value.isEmpty) {
              widget.onChanged?.call(null);
            }
          },
          onFieldSubmitted: (value) {
            onFieldSubmitted();
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final customer = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(
                      customer.customerName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    subtitle: customer.contactPerson != null
                        ? Text(
                            customer.contactPerson!,
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : null,
                    onTap: () {
                      onSelected(customer);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
      onSelected: (Customer customer) {
        widget.controller.text = customer.customerName;
        widget.onChanged?.call(customer.id);
      },
    );
  }
}
