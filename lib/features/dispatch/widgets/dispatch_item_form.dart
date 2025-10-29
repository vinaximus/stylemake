import 'package:flutter/material.dart';
import 'package:stylemake/core/constants/layout_constants.dart';
import 'package:stylemake/core/utils/validators.dart';
import 'package:stylemake/core/widgets/form/text_input_field.dart';
import 'package:stylemake/core/widgets/form/style_autocomplete_field.dart';
import 'package:stylemake/core/repositories/style_repository.dart';

/// Widget for adding/editing dispatch items
class DispatchItemForm extends StatefulWidget {
  const DispatchItemForm({
    super.key,
    this.initialData,
    this.onSave,
    this.onCancel,
  });

  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onCancel;

  @override
  State<DispatchItemForm> createState() => _DispatchItemFormState();
}

class _DispatchItemFormState extends State<DispatchItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _styleController = TextEditingController();
  final _styleRepository = StyleRepository();
  String? _selectedStyleId;
  String? _selectedStyleName;
  final _colorController = TextEditingController();
  final _sizeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _rateController = TextEditingController();
  final _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _selectedStyleId = widget.initialData!['style_id']?.toString();
      _selectedStyleName = widget.initialData!['style_name']?.toString();
      // Load style name for display if style_id exists but style_name doesn't
      if (_selectedStyleId != null && _selectedStyleName == null) {
        _loadStyleName(_selectedStyleId!);
      } else if (_selectedStyleName != null) {
        _styleController.text = _selectedStyleName!;
      }
      _colorController.text = widget.initialData!['color']?.toString() ?? '';
      _sizeController.text = widget.initialData!['size']?.toString() ?? '';
      _quantityController.text =
          widget.initialData!['quantity']?.toString() ?? '1';
      _rateController.text = widget.initialData!['rate']?.toString() ?? '';
      _remarksController.text =
          widget.initialData!['remarks']?.toString() ?? '';
    } else {
      _quantityController.text = '1';
    }
  }

  Future<void> _loadStyleName(String styleId) async {
    try {
      final style = await _styleRepository.getStyleById(styleId);
      if (style != null && mounted) {
        setState(() {
          _styleController.text = style.name;
          _selectedStyleName = style.name;
        });
      }
    } catch (e) {
      // If style loading fails, just leave it empty
    }
  }

  @override
  void dispose() {
    _styleController.dispose();
    _colorController.dispose();
    _sizeController.dispose();
    _quantityController.dispose();
    _rateController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedStyleId == null || _selectedStyleId!.isEmpty) {
      // Show error if style not selected
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a style')));
      return;
    }

    final itemData = {
      'style_id': _selectedStyleId,
      'style_name': _selectedStyleName ?? _styleController.text.trim(),
      'color': _colorController.text.trim().isEmpty
          ? null
          : _colorController.text.trim(),
      'size': _sizeController.text.trim().isEmpty
          ? null
          : _sizeController.text.trim(),
      'quantity': double.parse(_quantityController.text.trim()),
      'rate': _rateController.text.trim().isEmpty
          ? null
          : double.tryParse(_rateController.text.trim()),
      'remarks': _remarksController.text.trim().isEmpty
          ? null
          : _remarksController.text.trim(),
    };

    widget.onSave?.call(itemData);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.initialData == null ? 'Add Item' : 'Edit Item',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: LayoutConstants.spaceMedium),
              StyleAutocompleteField(
                controller: _styleController,
                label: 'Style',
                hint: 'Search and select style',
                validator: Validators.compose([
                  Validators.required('Style is required'),
                ]),
                onChanged: (styleId) async {
                  setState(() {
                    _selectedStyleId = styleId;
                  });
                  // Fetch and store style name
                  if (styleId != null) {
                    final style = await _styleRepository.getStyleById(styleId);
                    if (style != null && mounted) {
                      setState(() {
                        _selectedStyleName = style.name;
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: LayoutConstants.spaceMedium),
              Row(
                children: [
                  Expanded(
                    child: TextInputField(
                      controller: _colorController,
                      label: 'Color',
                      hint: 'e.g., Red, Blue',
                    ),
                  ),
                  const SizedBox(width: LayoutConstants.spaceMedium),
                  Expanded(
                    child: TextInputField(
                      controller: _sizeController,
                      label: 'Size',
                      hint: 'e.g., S, M, L',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: LayoutConstants.spaceMedium),
              Row(
                children: [
                  Expanded(
                    child: TextInputField(
                      controller: _quantityController,
                      label: 'Quantity',
                      hint: 'Enter quantity',
                      keyboardType: TextInputType.number,
                      validator: Validators.compose([
                        Validators.required('Quantity is required'),
                        Validators.positiveNumber(
                          'Quantity must be greater than 0',
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(width: LayoutConstants.spaceMedium),
                  Expanded(
                    child: TextInputField(
                      controller: _rateController,
                      label: 'Rate (Optional)',
                      hint: 'Enter rate',
                      keyboardType: TextInputType.number,
                      validator: Validators.compose([
                        Validators.decimal('Rate must be a valid number'),
                      ]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: LayoutConstants.spaceMedium),
              TextInputField(
                controller: _remarksController,
                label: 'Remarks (Optional)',
                hint: 'Additional notes',
                maxLines: 2,
              ),
              const SizedBox(height: LayoutConstants.spaceLarge),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: LayoutConstants.spaceMedium),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper function to show dispatch item form as a dialog
Future<Map<String, dynamic>?> showDispatchItemForm(
  BuildContext context, {
  Map<String, dynamic>? initialData,
}) async {
  Map<String, dynamic>? result;

  await showDialog(
    context: context,
    builder: (context) => DispatchItemForm(
      initialData: initialData,
      onSave: (data) {
        result = data;
        Navigator.pop(context);
      },
      onCancel: () => Navigator.pop(context),
    ),
  );

  return result;
}
