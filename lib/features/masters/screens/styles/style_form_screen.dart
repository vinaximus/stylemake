import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stylemake/core/constants/layout_constants.dart';
import 'package:stylemake/core/utils/snackbar_utils.dart';
import 'package:stylemake/core/utils/validators.dart';
import 'package:stylemake/core/widgets/form/text_input_field.dart';
import 'package:stylemake/core/widgets/responsive_center.dart';
import 'package:stylemake/features/masters/providers/style_providers.dart';

/// Style form screen for Add/Edit
class StyleFormScreen extends ConsumerStatefulWidget {
  const StyleFormScreen({super.key, this.styleId});

  final String? styleId;

  @override
  ConsumerState<StyleFormScreen> createState() => _StyleFormScreenState();
}

class _StyleFormScreenState extends ConsumerState<StyleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _designerController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isEditMode => widget.styleId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadStyle();
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designerController.dispose();
    super.dispose();
  }

  Future<void> _loadStyle() async {
    try {
      final repository = ref.read(styleRepositoryProvider);
      final style = await repository.getStyleById(widget.styleId!);

      if (style != null && mounted) {
        setState(() {
          _nameController.text = style.name;
          _designerController.text = style.designer ?? '';
          _isLoading = false;
        });
      } else {
        if (mounted) {
          SnackbarUtils.showError(context, 'Style not found');
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarUtils.showError(context, 'Failed to load style: $e');
      }
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(styleRepositoryProvider);
      final name = _nameController.text.trim();
      final designer = _designerController.text.trim().isEmpty
          ? null
          : _designerController.text.trim();

      if (_isEditMode) {
        await repository.updateStyle(
          id: widget.styleId!,
          name: name,
          designer: designer,
        );
      } else {
        await repository.createStyle(name: name, designer: designer);
      }

      if (mounted) {
        // Invalidate providers to refresh the list
        ref.invalidate(stylesListProvider);
        ref.invalidate(filteredStylesProvider);
        SnackbarUtils.showSuccess(
          context,
          _isEditMode
              ? 'Style updated successfully'
              : 'Style created successfully',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        SnackbarUtils.showError(
          context,
          'Failed to save style: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Style' : 'Add Style')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: ResponsiveFormContainer(
                child: Padding(
                  padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextInputField(
                          controller: _nameController,
                          label: 'Style Name',
                          hint: 'e.g., T-Shirt Basic, Polo Shirt',
                          validator: Validators.compose([
                            Validators.required('Style name is required'),
                            Validators.minLength(
                              3,
                              'Minimum 3 characters required',
                            ),
                            Validators.maxLength(
                              100,
                              'Maximum 100 characters allowed',
                            ),
                          ]),
                          enabled: !_isSaving,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: LayoutConstants.spaceMedium),
                        TextInputField(
                          controller: _designerController,
                          label: 'Designer (Optional)',
                          hint: 'e.g., John Smith, Fashion House',
                          validator: Validators.compose([
                            Validators.maxLength(
                              100,
                              'Maximum 100 characters allowed',
                            ),
                          ]),
                          enabled: !_isSaving,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: LayoutConstants.spaceXLarge),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSaving
                                    ? null
                                    : () => context.pop(),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: LayoutConstants.spaceMedium),
                            Expanded(
                              child: FilledButton(
                                onPressed: _isSaving ? null : _saveForm,
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(_isEditMode ? 'Update' : 'Save'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
