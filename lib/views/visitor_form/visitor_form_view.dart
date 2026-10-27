import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/haptic_helper.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/validators.dart';
import '../../features/visitor/data/models/visitor_model.dart';
import '../../shared/widgets/custom_button.dart';
import '../../viewmodels/visitor_form_viewmodel.dart';
import '../visitor_details/visitor_details_view.dart';

/// Opens a smooth, slow-transferring centered modal pop-up dialog for visitor registration.
Future<T?> openRegisterVisitorModal<T>(BuildContext context, {Visitor? existingVisitor}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Register Visitor',
    barrierColor: Colors.black.withValues(alpha: 0.65),
    transitionDuration: const Duration(milliseconds: 750),
    pageBuilder: (dialogContext, anim1, anim2) {
      final screenWidth = MediaQuery.sizeOf(dialogContext).width;
      final screenHeight = MediaQuery.sizeOf(dialogContext).height;

      // Pop-up dimensions: centered with clear margins on all four sides
      final dialogWidth = (screenWidth * 0.92).clamp(320.0, 520.0);
      final dialogHeight = (screenHeight * 0.82).clamp(460.0, 700.0);

      return MediaQuery.removePadding(
        context: dialogContext,
        removeTop: true,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: dialogWidth,
              height: dialogHeight,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 28,
                    spreadRadius: 3,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: VisitorFormView(existingVisitor: existingVisitor, isPopup: true),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      );
      return ScaleTransition(
        scale: Tween<double>(begin: 0.72, end: 1.0).animate(curved),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
          ),
          child: child,
        ),
      );
    },
  );
}

class VisitorFormView extends ConsumerStatefulWidget {
  final Visitor? existingVisitor;
  final bool isPopup;

  const VisitorFormView({super.key, this.existingVisitor, this.isPopup = false});

  bool get isEditing => existingVisitor != null;

  @override
  ConsumerState<VisitorFormView> createState() => _VisitorFormViewState();
}

class _VisitorFormViewState extends ConsumerState<VisitorFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _purposeController;

  late VisitorType _selectedType;
  late ProjectName _selectedProject;

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

    // 3. Heavy vibration when user hits generate QR / register pass
    await HapticHelper.heavyVibrate();

    final viewModel = ref.read(visitorFormViewModelProvider.notifier);

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

        final result = await viewModel.updateVisitor(updated);

        if (mounted && result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.statusCheckedIn,
              content: Text('Visitor details updated successfully.'),
            ),
          );
          Navigator.pop(context, result);
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

        final created = await viewModel.registerVisitor(newVisitor);

        if (mounted && created != null) {
          // Reinforced heavy vibration when QR pass is successfully generated
          await HapticHelper.heavyVibrate();

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.statusCheckedIn,
              content: Text('Visitor "${created.name}" registered with Pass ID #${created.id}!'),
            ),
          );

          // Replace form or close popup with Visitor Details showing QR Code pass
          if (widget.isPopup) {
            Navigator.pop(context, created);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VisitorDetailsView(visitorId: created.id),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => VisitorDetailsView(visitorId: created.id),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusDestructive,
            content: Text('Failed to save visitor: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(visitorFormViewModelProvider);
    final bottomInset = Responsive.bottomInset(context);
    final isSmallScreen = Responsive.screenWidth(context) < 360;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        primary: !widget.isPopup,
        toolbarHeight: widget.isPopup ? Responsive.h(context, 48) : null,
        title: Text(widget.isEditing ? 'Edit Visitor' : 'Register Visitor'),
        automaticallyImplyLeading: !widget.isPopup,
        actions: [
          if (widget.isPopup)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Close',
              onPressed: () => Navigator.pop(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        // 4. PADDING with MediaQuery
        padding: Responsive.paddingLTRB(
          context,
          isSmallScreen ? 14.0 : 18.0,
          18.0,
          isSmallScreen ? 14.0 : 18.0,
          18.0 + (bottomInset > 0 ? bottomInset * 0.1 : 0),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3. CONTAINER with MediaQuery margin & padding
              Container(
                padding: Responsive.paddingAll(context, 14),
                margin: EdgeInsets.only(bottom: Responsive.h(context, 18)),
                decoration: BoxDecoration(
                  color: AppColors.tealLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.tealAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.tealAccent,
                      size: Responsive.sp(context, 22),
                    ),
                    Responsive.hSpace(context, 10),
                    Expanded(
                      child: Text(
                        widget.isEditing
                            ? 'Update visitor profile information and project assignment.'
                            : 'All registered visitors start with Registered status. A QR pass will be generated after registration.',
                        // 1. TEXTSIZE with MediaQuery
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: Responsive.sp(context, 12.5),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Full Name (Required)
              _buildSectionTitle('Full Name *'),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                validator: Validators.validateName,
                style: TextStyle(fontSize: Responsive.sp(context, 14)),
                decoration: InputDecoration(
                  hintText: 'e.g. Rahul Sharma',
                  hintStyle: TextStyle(fontSize: Responsive.sp(context, 13.5)),
                  prefixIcon: Icon(Icons.person_outline_rounded, size: Responsive.sp(context, 18)),
                  contentPadding: Responsive.paddingSymmetric(context, horizontal: 16, vertical: 14),
                ),
              ),
              // 2. SIZEDBOX with MediaQuery
              Responsive.vSpace(context, 16),

              // Mobile Number (Required, exactly 10 digits)
              _buildSectionTitle('Mobile Number (10 Digits) *'),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                validator: Validators.validateMobile,
                style: TextStyle(fontSize: Responsive.sp(context, 14)),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  hintText: 'e.g. 9876543210',
                  hintStyle: TextStyle(fontSize: Responsive.sp(context, 13.5)),
                  prefixIcon: Icon(Icons.phone_outlined, size: Responsive.sp(context, 18)),
                  contentPadding: Responsive.paddingSymmetric(context, horizontal: 16, vertical: 14),
                ),
              ),
              Responsive.vSpace(context, 16),

              // Email Address (Optional; validate when entered)
              _buildSectionTitle('Email Address (Optional)'),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                style: TextStyle(fontSize: Responsive.sp(context, 14)),
                decoration: InputDecoration(
                  hintText: 'e.g. rahul@example.com',
                  hintStyle: TextStyle(fontSize: Responsive.sp(context, 13.5)),
                  prefixIcon: Icon(Icons.email_outlined, size: Responsive.sp(context, 18)),
                  contentPadding: Responsive.paddingSymmetric(context, horizontal: 16, vertical: 14),
                ),
              ),
              Responsive.vSpace(context, 16),

              // Dropdowns Row: Visitor Type & Project
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
                          decoration: InputDecoration(
                            contentPadding: Responsive.paddingSymmetric(context, horizontal: 12, vertical: 12),
                          ),
                          items: VisitorType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(
                                type.label,
                                style: TextStyle(fontSize: Responsive.sp(context, 13.5)),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedType = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  Responsive.hSpace(context, 14),

                  // Project
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Project Location *'),
                        DropdownButtonFormField<ProjectName>(
                          initialValue: _selectedProject,
                          decoration: InputDecoration(
                            contentPadding: Responsive.paddingSymmetric(context, horizontal: 12, vertical: 12),
                          ),
                          items: ProjectName.values.map((proj) {
                            return DropdownMenuItem(
                              value: proj,
                              child: Text(
                                proj.label,
                                style: TextStyle(fontSize: Responsive.sp(context, 13.5)),
                              ),
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
              Responsive.vSpace(context, 16),

              // Purpose of Visit (Required)
              _buildSectionTitle('Purpose of Visit *'),
              TextFormField(
                controller: _purposeController,
                maxLines: 3,
                validator: Validators.validatePurpose,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(fontSize: Responsive.sp(context, 14)),
                decoration: InputDecoration(
                  hintText: 'e.g. Flat site visit & documentation handover',
                  hintStyle: TextStyle(fontSize: Responsive.sp(context, 13.5)),
                  contentPadding: Responsive.paddingSymmetric(context, horizontal: 16, vertical: 14),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.description_outlined, size: Responsive.sp(context, 18)),
                  ),
                ),
              ),
              Responsive.vSpace(context, 28),

              // Action Buttons: Save & Cancel
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Cancel',
                      variant: CustomButtonVariant.secondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Responsive.hSpace(context, 12),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      label: widget.isEditing ? 'Save Changes' : 'Register & Generate Pass',
                      icon: widget.isEditing
                          ? Icons.check_circle_outline_rounded
                          : Icons.qr_code_2_rounded,
                      isLoading: formState.isSubmitting,
                      variant: CustomButtonVariant.primary,
                      onPressed: _submitForm,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: Responsive.sp(context, 13),
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
