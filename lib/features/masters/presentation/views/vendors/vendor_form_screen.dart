import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stylemake/shared/constants/layout_constants.dart';
import 'package:stylemake/shared/utils/snackbar_utils.dart';
import 'package:stylemake/shared/utils/validators.dart';
import 'package:stylemake/shared/widgets/form/text_input_field.dart';
import 'package:stylemake/shared/widgets/responsive_center.dart';
import 'package:stylemake/features/masters/presentation/viewmodels/vendor_view_model.dart';

/// Vendor form screen for Add/Edit
class VendorFormScreen extends ConsumerStatefulWidget {
  const VendorFormScreen({super.key, this.vendorId});

  final String? vendorId;

  @override
  ConsumerState<VendorFormScreen> createState() => _VendorFormScreenState();
}

class _VendorFormScreenState extends ConsumerState<VendorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _gstController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pinCodeController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isEditMode => widget.vendorId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadVendor();
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gstController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadVendor() async {
    try {
      final repository = ref.read(vendorRepositoryProvider);
      final vendor = await repository.getVendorById(widget.vendorId!);

      if (vendor != null && mounted) {
        setState(() {
          _nameController.text = vendor.name;
          _gstController.text = vendor.gst ?? '';
          _addressController.text = vendor.address ?? '';
          _cityController.text = vendor.city ?? '';
          _pinCodeController.text = vendor.pinCode ?? '';
          _isLoading = false;
        });
      } else {
        if (mounted) {
          SnackbarUtils.showError(context, 'Vendor not found');
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarUtils.showError(context, 'Failed to load vendor: $e');
      }
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(vendorRepositoryProvider);
      final name = _nameController.text.trim();
      final gst = _gstController.text.trim().isEmpty
          ? null
          : _gstController.text.trim();
      final address = _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim();
      final city = _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim();
      final pinCode = _pinCodeController.text.trim().isEmpty
          ? null
          : _pinCodeController.text.trim();

      if (_isEditMode) {
        await repository.updateVendor(
          id: widget.vendorId!,
          name: name,
          gst: gst,
          address: address,
          city: city,
          pinCode: pinCode,
        );
      } else {
        await repository.createVendor(
          name: name,
          gst: gst,
          address: address,
          city: city,
          pinCode: pinCode,
        );
      }

      if (mounted) {
        ref.invalidate(vendorsListProvider);
        ref.invalidate(vendorCitiesProvider);
        SnackbarUtils.showSuccess(
          context,
          _isEditMode
              ? 'Vendor updated successfully'
              : 'Vendor created successfully',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        SnackbarUtils.showError(
          context,
          'Failed to save vendor: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Vendor' : 'Add Vendor')),
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
                          label: 'Vendor Name',
                          hint: 'e.g., Embroidery Works Ltd',
                          validator: Validators.compose([
                            Validators.required('Vendor name is required'),
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
                          controller: _gstController,
                          label: 'GST Number',
                          hint: '15-character GST (optional)',
                          validator: Validators.gstNumber(
                            'Invalid GST format (e.g., 27AABCU9603R1ZX)',
                          ),
                          enabled: !_isSaving,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 15,
                        ),
                        const SizedBox(height: LayoutConstants.spaceMedium),
                        TextInputField(
                          controller: _addressController,
                          label: 'Address',
                          hint: 'Optional',
                          validator: Validators.maxLength(
                            200,
                            'Maximum 200 characters allowed',
                          ),
                          enabled: !_isSaving,
                          maxLines: 2,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: LayoutConstants.spaceMedium),
                        TextInputField(
                          controller: _cityController,
                          label: 'City',
                          hint: 'Optional',
                          validator: Validators.maxLength(
                            50,
                            'Maximum 50 characters allowed',
                          ),
                          enabled: !_isSaving,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: LayoutConstants.spaceMedium),
                        TextInputField(
                          controller: _pinCodeController,
                          label: 'PIN Code',
                          hint: '6-digit PIN (optional)',
                          validator: Validators.pinCode(
                            'Invalid PIN code (6 digits)',
                          ),
                          enabled: !_isSaving,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
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
