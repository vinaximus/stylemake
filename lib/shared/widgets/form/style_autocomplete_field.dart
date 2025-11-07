import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylemake/features/masters/data/models/style.dart';
import 'package:stylemake/features/masters/data/repositories/style_repository.dart';

/// Autocomplete field for style selection
class StyleAutocompleteField extends ConsumerStatefulWidget {
  const StyleAutocompleteField({
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
  ConsumerState<StyleAutocompleteField> createState() => _StyleAutocompleteFieldState();
}

class _StyleAutocompleteFieldState extends ConsumerState<StyleAutocompleteField> {
  final StyleRepository _styleRepository = StyleRepository();
  List<Style> _styles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStyles();
  }

  Future<void> _loadStyles() async {
    setState(() => _isLoading = true);
    try {
      final styles = await _styleRepository.getAllStyles();
      if (mounted) {
        setState(() {
          _styles = styles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Style> _filterStyles(String query) {
    if (query.isEmpty) return _styles;
    
    final lowercaseQuery = query.toLowerCase();
    return _styles.where((style) {
      return style.name.toLowerCase().contains(lowercaseQuery) ||
             (style.designer?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Style>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Style>.empty();
        }
        return _filterStyles(textEditingValue.text);
      },
      displayStringForOption: (Style style) => style.name,
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
            hintText: widget.hint ?? 'Search styles...',
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
            widget.onChanged?.call(value);
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
                  final style = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(
                      style.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    subtitle: style.designer != null
                        ? Text(
                            'Designer: ${style.designer}',
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : null,
                    onTap: () {
                      onSelected(style);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
      onSelected: (Style style) {
        widget.controller.text = style.name;
        widget.onChanged?.call(style.id);
      },
    );
  }
}
