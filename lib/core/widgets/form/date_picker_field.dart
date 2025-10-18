import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Reusable date picker field with Material 3 design
class DatePickerField extends StatefulWidget {
  const DatePickerField({
    required this.controller,
    required this.label,
    super.key,
    this.hint,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  DateTime? _selectedDate;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isNotEmpty) {
      try {
        _selectedDate = _dateFormat.parse(widget.controller.text);
      } catch (e) {
        // Invalid date format, ignore
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!widget.enabled) return;

    final DateTime initialDate = _selectedDate ?? DateTime.now();
    final DateTime firstDate = widget.firstDate ?? DateTime(1900);
    final DateTime lastDate = widget.lastDate ?? DateTime(2100);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        widget.controller.text = _dateFormat.format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint ?? 'DD/MM/YYYY',
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: widget.enabled ? () => _selectDate(context) : null,
        ),
      ),
      validator: widget.validator,
      enabled: widget.enabled,
      readOnly: true,
      onTap: () => _selectDate(context),
    );
  }
}
