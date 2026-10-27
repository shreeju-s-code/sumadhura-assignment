import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/haptic_helper.dart';
import '../../core/utils/responsive.dart';
import '../../features/visitor/data/models/visitor_model.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/status_chip.dart';
import '../../viewmodels/qr_scanner_viewmodel.dart';
import '../visitor_details/visitor_details_view.dart';

class QrScannerView extends ConsumerStatefulWidget {
  const QrScannerView({super.key});

  @override
  ConsumerState<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends ConsumerState<QrScannerView> {
  late final MobileScannerController _scannerController;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final viewModel = ref.read(qrScannerViewModelProvider.notifier);
    final state = ref.read(qrScannerViewModelProvider);

    if (state.isProcessing) return; // Prevent duplicate rapid scans

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue?.trim();
    if (rawValue == null || rawValue.isEmpty) return;

    _handleScannedId(rawValue, viewModel);
  }

  Future<void> _handleScannedId(String visitorId, QrScannerViewModel viewModel) async {
    // 3. Heavy vibrate when QR code is detected and read
    await HapticHelper.heavyVibrate();

    if (!mounted) return;

    // Show lookup loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.tealAccent),
                ),
                SizedBox(width: 18),
                Text(
                  'Looking up visitor pass...',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final visitor = await viewModel.processScannedId(visitorId);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        if (visitor != null) {
          _showVisitorActionSheet(visitor, viewModel);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _showScanErrorDialog(visitorId, e.toString(), viewModel);
      }
    }
  }

  void _showVisitorActionSheet(Visitor visitor, QrScannerViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            bool isActionRunning = false;
            final bottomInset = Responsive.bottomInset(context);

            return Padding(
              // 4. PADDING with MediaQuery
              padding: Responsive.paddingLTRB(context, 20, 16, 20, 28 + bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: Responsive.w(context, 40),
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // 2. SIZEDBOX with MediaQuery
                  Responsive.vSpace(context, 16),

                  // Header with name and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. TEXTSIZE with MediaQuery
                            Text(
                              visitor.name,
                              style: TextStyle(
                                fontSize: Responsive.sp(context, 18),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Pass ID: #${visitor.id} • ${visitor.project.label}',
                              style: TextStyle(
                                fontSize: Responsive.sp(context, 13),
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusChip(status: visitor.status),
                    ],
                  ),

                  Responsive.vSpace(context, 14),
                  const Divider(color: AppColors.border),
                  Responsive.vSpace(context, 12),

                  // Purpose
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.assignment_outlined, size: Responsive.sp(context, 16), color: AppColors.tealAccent),
                      Responsive.hSpace(context, 8),
                      Expanded(
                        child: Text(
                          visitor.purpose,
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 13.5),
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Responsive.vSpace(context, 20),

                  // Dynamic Action Button based on visitor status
                  if (visitor.canCheckIn)
                    CustomButton(
                      label: 'Confirm Check In',
                      icon: Icons.login_rounded,
                      variant: CustomButtonVariant.teal,
                      isLoading: isActionRunning,
                      width: double.infinity,
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        setSheetState(() => isActionRunning = true);
                        try {
                          await viewModel.checkInScannedVisitor();
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                            _showSuccessFeedback('${visitor.name} successfully checked in.');
                          }
                        } catch (e) {
                          setSheetState(() => isActionRunning = false);
                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.statusDestructive,
                              content: Text(e.toString()),
                            ),
                          );
                        }
                      },
                    )
                  else if (visitor.canCheckOut)
                    CustomButton(
                      label: 'Confirm Check Out',
                      icon: Icons.logout_rounded,
                      variant: CustomButtonVariant.primary,
                      isLoading: isActionRunning,
                      width: double.infinity,
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        setSheetState(() => isActionRunning = true);
                        try {
                          await viewModel.checkOutScannedVisitor();
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                            _showSuccessFeedback('${visitor.name} successfully checked out.');
                          }
                        } catch (e) {
                          setSheetState(() => isActionRunning = false);
                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.statusDestructive,
                              content: Text(e.toString()),
                            ),
                          );
                        }
                      },
                    )
                  else
                    // 3. CONTAINER with Responsive padding
                    Container(
                      width: double.infinity,
                      padding: Responsive.paddingAll(context, 12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Completed visit. This pass has already been checked out.',
                        style: TextStyle(
                          color: AppColors.statusCheckedOut,
                          fontSize: Responsive.sp(context, 13),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  Responsive.vSpace(context, 10),

                  // View full details link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VisitorDetailsView(visitorId: visitor.id),
                          ),
                        );
                      },
                      child: Text(
                        'View Full Visitor Profile & Pass',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: Responsive.sp(context, 13.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      viewModel.reset();
    });
  }

  void _showScanErrorDialog(String scannedId, String errorMessage, QrScannerViewModel viewModel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.statusDestructive),
            SizedBox(width: 8),
            Text('Pass Not Found'),
          ],
        ),
        content: Text(
          'Scanned ID: "$scannedId"\n\n$errorMessage',
          style: const TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              viewModel.reset();
            },
            child: const Text('Scan Again'),
          ),
        ],
      ),
    );
  }

  void _showSuccessFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.statusCheckedIn,
        content: Text(message),
      ),
    );
  }

  void _showManualIdDialog(QrScannerViewModel viewModel) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Visitor Pass ID', style: TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. 101',
            prefixIcon: Icon(Icons.pin_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              final id = textController.text.trim();
              if (id.isNotEmpty) {
                Navigator.pop(ctx);
                _handleScannedId(id, viewModel);
              }
            },
            child: const Text('Look Up'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(qrScannerViewModelProvider.notifier);
    // 3. CONTAINER size derived via MediaQuery
    final scannerBoxSize = Responsive.scannerBoxSize(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Gate QR Scanner'),
        actions: [
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded),
            tooltip: 'Toggle Flashlight',
            onPressed: () {
              _scannerController.toggleTorch();
              setState(() => _isTorchOn = !_isTorchOn);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Preview
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // Custom Scanner Overlay with Teal Target Reticle
          Center(
            child: Container(
              width: scannerBoxSize,
              height: scannerBoxSize,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.tealAccent, width: 2.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.tealAccent,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(14)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.tealAccent,
                        borderRadius: BorderRadius.only(topRight: Radius.circular(14)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.tealAccent,
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(14)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.tealAccent,
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Guidance instructions banner
          Positioned(
            top: 30,
            left: 20,
            right: 20,
            child: Container(
              // 4. PADDING with MediaQuery
              padding: Responsive.paddingSymmetric(context, horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Align the visitor\'s QR pass within the frame',
                // 1. TEXTSIZE with MediaQuery
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.sp(context, 13),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Manual fallback button at bottom
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: ElevatedButton.icon(
              onPressed: () => _showManualIdDialog(viewModel),
              icon: Icon(Icons.keyboard_outlined, size: Responsive.sp(context, 18)),
              label: Text(
                'Enter Pass ID Manually',
                style: TextStyle(fontSize: Responsive.sp(context, 14)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: Responsive.paddingSymmetric(context, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
