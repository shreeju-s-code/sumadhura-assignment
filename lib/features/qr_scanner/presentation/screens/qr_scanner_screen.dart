import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../visitor/data/models/visitor_model.dart';
import '../../../visitor/presentation/controllers/visitor_providers.dart';
import '../../../visitor/presentation/screens/visitor_details_screen.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  late final MobileScannerController _scannerController;
  bool _isProcessingScan = false;
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
    if (_isProcessingScan) return; // Prevent duplicate rapid scans

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue?.trim();
    if (rawValue == null || rawValue.isEmpty) return;

    _handleScannedId(rawValue);
  }

  Future<void> _handleScannedId(String visitorId) async {
    setState(() => _isProcessingScan = true);
    HapticFeedback.mediumImpact();

    // Show processing indicator
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
      final repo = ref.read(visitorRepositoryProvider);
      final visitor = await repo.getVisitorById(visitorId);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _showVisitorActionSheet(visitor);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _showScanErrorDialog(visitorId, e.toString());
      }
    }
  }

  void _showVisitorActionSheet(Visitor visitor) {
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

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header with name and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              visitor.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Pass ID: #${visitor.id} • ${visitor.project.label}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(status: visitor.status),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 12),

                  // Purpose
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.assignment_outlined, size: 16, color: AppColors.tealAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          visitor.purpose,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Dynamic Action Button depending on Status Rule
                  if (visitor.canCheckIn)
                    AppButton(
                      label: 'Confirm Check In',
                      icon: Icons.login_rounded,
                      variant: ButtonVariant.teal,
                      isLoading: isActionRunning,
                      width: double.infinity,
                      onPressed: () async {
                        setSheetState(() => isActionRunning = true);
                        try {
                          await ref.read(visitorListNotifierProvider.notifier).checkIn(visitor);
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                            _showSuccessFeedback('${visitor.name} successfully checked in.');
                          }
                        } catch (e) {
                          setSheetState(() => isActionRunning = false);
                          if (context.mounted) {
                            AppSnackBar.showError(context, e.toString());
                          }
                        }
                      },
                    )
                  else if (visitor.canCheckOut)
                    AppButton(
                      label: 'Confirm Check Out',
                      icon: Icons.logout_rounded,
                      variant: ButtonVariant.primary,
                      isLoading: isActionRunning,
                      width: double.infinity,
                      onPressed: () async {
                        setSheetState(() => isActionRunning = true);
                        try {
                          await ref.read(visitorListNotifierProvider.notifier).checkOut(visitor);
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                            _showSuccessFeedback('${visitor.name} successfully checked out.');
                          }
                        } catch (e) {
                          setSheetState(() => isActionRunning = false);
                          if (context.mounted) {
                            AppSnackBar.showError(context, e.toString());
                          }
                        }
                      },
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Completed visit. This pass has already been checked out.',
                        style: TextStyle(
                          color: AppColors.statusCheckedOut,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 10),

                  // View full details link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VisitorDetailsScreen(visitorId: visitor.id),
                          ),
                        );
                      },
                      child: const Text(
                        'View Full Visitor Profile & Pass',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
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
      // Resume scanning capability when bottom sheet closes
      if (mounted) setState(() => _isProcessingScan = false);
    });
  }

  void _showScanErrorDialog(String scannedId, String errorMessage) {
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
              setState(() => _isProcessingScan = false);
            },
            child: const Text('Scan Again'),
          ),
        ],
      ),
    );
  }

  void _showSuccessFeedback(String message) {
    AppSnackBar.showSuccess(context, message);
  }

  void _showManualIdDialog() {
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
                _handleScannedId(id);
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Gate QR Scanner', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded, color: Colors.white),
            tooltip: 'Toggle Flashlight',
            onPressed: () {
              _scannerController.toggleTorch();
              setState(() => _isTorchOn = !_isTorchOn);
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white),
            tooltip: 'Flip Camera',
            onPressed: () => _scannerController.switchCamera(),
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
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.tealAccent, width: 2.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Top-left corner
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
                  // Top-right corner
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
                  // Bottom-left corner
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
                  // Bottom-right corner
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Align the visitor\'s QR pass within the frame',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
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
              onPressed: _showManualIdDialog,
              icon: const Icon(Icons.keyboard_outlined, size: 18),
              label: const Text('Enter Pass ID Manually'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
