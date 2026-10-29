import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/models/visitor_model.dart';
import '../controllers/visitor_providers.dart';
import 'visitor_details_screen.dart';

class VisitorFormScreen extends ConsumerStatefulWidget {
  final Visitor? existingVisitor;

  const VisitorFormScreen({super.key, this.existingVisitor});

  bool get isEditing => existingVisitor != null;

  @override
  ConsumerState<VisitorFormScreen> createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends ConsumerState<VisitorFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _purposeController;

  late VisitorType _selectedType;
  late ProjectName _selectedProject;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final visitor = widget.existingVisitor;
    _nameController = TextEditingController(text: visitor?.name ?? '');
    _mobileController = TextEditingController(text: visitor?.mobile ?? '');
    _emailController = TextEditingController(text: visitor?.email ?? '');
    _purposeController = TextEditingController(text: visitor?.purpose ?? '');

    _selectedType = visitor?.visitorType ?? VisitorType.customer;
    _selectedProject = visitor?.project ?? ProjectName.projectA;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.isEditing) {
        final updated = widget.existingVisitor!.copyWith(
          name: _nameController.text.trim(),
          mobile: _mobileController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          visitorType: _selectedType,
          project: _selectedProject,
          purpose: _purposeController.text.trim(),
        );

        await ref.read(visitorListNotifierProvider.notifier).updateVisitor(updated);

        if (mounted) {
          AppSnackBar.showSuccess(context, 'Visitor details updated successfully.');
          Navigator.pop(context, updated);
        }
      } else {
        final newVisitor = Visitor(
          id: '', // Will be assigned by API/server
          name: _nameController.text.trim(),
          mobile: _mobileController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          visitorType: _selectedType,
          project: _selectedProject,
          purpose: _purposeController.text.trim(),
          status: VisitorStatus.registered,
          createdAt: DateFormatter.nowIso(),
        );

        final created = await ref.read(visitorListNotifierProvider.notifier).registerVisitor(newVisitor);

        if (mounted) {
          AppSnackBar.showSuccess(
            context,
            'Visitor "${created.name}" registered with Pass ID #${created.id}!',
          );

          // Replace form with Visitor Details showing QR Code pass
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => VisitorDetailsScreen(visitorId: created.id),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Failed to save visitor: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Visitor' : 'Register Visitor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header description
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.tealLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.tealAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.tealAccent, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.isEditing
                            ? 'Update visitor profile information and project assignment.'
                            : 'All registered visitors start with Registered status. A QR pass will be generated after registration.',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Full Name
              _buildSectionTitle('Full Name *'),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                validator: Validators.validateName,
                decoration: const InputDecoration(
                  hintText: 'e.g. John Doe',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 16),

              // Mobile Number (Exactly 10 digits)
              _buildSectionTitle('Mobile Number (10 Digits) *'),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                validator: Validators.validateMobile,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: const InputDecoration(
                  hintText: 'e.g. 9876543210',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Email Address (Optional)
              _buildSectionTitle('Email Address (Optional)'),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                decoration: const InputDecoration(
                  hintText: 'e.g. visitor@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Visitor Type & Project row
              Row(
                children: [
                  // Visitor Type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Visitor Type *'),
                        DropdownButtonFormField<VisitorType>(
                          initialValue: _selectedType,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: VisitorType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.label, style: const TextStyle(fontSize: 13.5)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedType = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Project
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Project Location *'),
                        DropdownButtonFormField<ProjectName>(
                          initialValue: _selectedProject,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: ProjectName.values.map((proj) {
                            return DropdownMenuItem(
                              value: proj,
                              child: Text(proj.label, style: const TextStyle(fontSize: 13.5)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedProject = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Purpose of Visit
              _buildSectionTitle('Purpose of Visit *'),
              TextFormField(
                controller: _purposeController,
                maxLines: 3,
                validator: Validators.validatePurpose,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'e.g. Flat handover discussion / vendor supplies delivery',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.description_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              AppButton(
                label: widget.isEditing ? 'Save Changes' : 'Register & Generate Pass',
                icon: widget.isEditing ? Icons.check_circle_outline_rounded : Icons.qr_code_2_rounded,
                isLoading: _isLoading,
                onPressed: _submitForm,
                width: double.infinity,
                variant: ButtonVariant.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
