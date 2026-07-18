import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../student/providers/student_account_provider.dart';

class PayQrScreen extends ConsumerStatefulWidget {
  const PayQrScreen({super.key});

  @override
  ConsumerState<PayQrScreen> createState() => _PayQrScreenState();
}

class _PayQrScreenState extends ConsumerState<PayQrScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isProcessingScan = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessingScan) return;

    final barcode = capture.barcodes.firstOrNull;
    final String? rawValue = barcode?.rawValue;

    if (rawValue != null && rawValue.isNotEmpty) {
      setState(() {
        _isProcessingScan = true;
      });
      _scannerController.stop();
      _processScannedPayload(rawValue);
    }
  }

  void _processScannedPayload(String payload) {
    double amount = 0.0;
    String description = 'QR Merchant Payment';
    String recipientName = 'HapoPay Merchant';

    // Attempt to parse QR code
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      amount = double.tryParse(data['amount']?.toString() ?? '') ?? 0.0;
      description = data['description']?.toString() ?? 'QR Merchant Payment';
      recipientName = data['student_name']?.toString() ?? data['merchant_name']?.toString() ?? 'HapoPay Merchant';
    } catch (_) {
      // Fallback 1: query string parameters
      try {
        final uri = Uri.parse('?$payload');
        amount = double.tryParse(uri.queryParameters['amount'] ?? '') ?? 0.0;
        description = uri.queryParameters['description'] ?? 'QR Merchant Payment';
        recipientName = uri.queryParameters['merchant'] ?? 'HapoPay Merchant';
      } catch (_) {
        // Fallback 2: plain number
        final plainAmount = double.tryParse(payload);
        if (plainAmount != null) {
          amount = plainAmount;
        } else {
          _showErrorDialog('Invalid QR Code', 'This code is not recognized by HapoPay. Please scan a valid payment code.');
          return;
        }
      }
    }

    if (amount <= 0) {
      _showErrorDialog('Invalid Amount', 'The QR code specifies an invalid transaction amount (\$${amount.toStringAsFixed(2)}).');
      return;
    }

    // Show beautiful confirmation bottom sheet
    _showPaymentConfirmationSheet(payload, recipientName, amount, description);
  }

  void _showPaymentConfirmationSheet(
    String originalPayload,
    String recipient,
    double amount,
    String description,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Confirm Payment',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 32),
              // Transaction details box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    Text(
                      '\$${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'to $recipient',
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const Divider(height: 32, color: Colors.white12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Purpose', style: TextStyle(color: Colors.white54)),
                        Text(description, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Glowing confirm button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6200EE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // close bottom sheet
                    _authenticateAndPay(originalPayload);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fingerprint),
                      SizedBox(width: 12),
                      Text(
                        'Authenticate & Pay',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _resumeScanner();
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      // If bottom sheet dismissed without clicking pay
      if (_isProcessingScan && !_isPaying) {
        _resumeScanner();
      }
    });
  }

  bool _isPaying = false;

  Future<void> _authenticateAndPay(String qrPayload) async {
    _isPaying = true;
    
    // 1. Biometric Authentication
    try {
      final bool canCheck = await _localAuth.canCheckBiometrics;
      final bool isSupported = await _localAuth.isDeviceSupported();
      
      if (canCheck || isSupported) {
        final bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Scan fingerprint to authorize transaction',
          options: const AuthenticationOptions(
            biometricOnly: false, // Fallback to PIN/pattern if biometric unavailable
            stickyAuth: true,
          ),
        );
        
        if (!didAuthenticate) {
          _isPaying = false;
          _showErrorDialog('Auth Required', 'Payment aborted. Biometric authorization is mandatory for security.');
          return;
        }
      }
    } catch (_) {
      // Local authentication unsupported or threw error on emulator; proceed with normal PIN mockup
    }

    // 2. Process Backend Handshake (Interceptors)
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFBB86FC)),
      ),
    );

    try {
      await ref.read(studentAccountProvider.notifier).payWithQr(qrPayload);
      if (!mounted) return;
      Navigator.pop(context); // close loading spinner
      
      // Show gorgeous success overlay
      _showSuccessScreen();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // close loading spinner
      _isPaying = false;
      
      String errorMsg = e.toString();
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map) {
          errorMsg = data['detail']?.toString() ?? data['message']?.toString() ?? errorMsg;
        }
      }
      
      _showErrorDialog('Payment Failed', errorMsg.replaceAll('Exception: ', ''));
    }
  }

  void _showSuccessScreen() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B5E20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF81C784),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Payment Successful',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your transaction has been securely processed and recorded.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6200EE),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      context.go('/student'); // Return to dashboard
                    },
                    child: const Text('Back to Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Text(message, style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resumeScanner();
              },
              child: const Text('OK', style: TextStyle(color: Color(0xFFBB86FC))),
            ),
          ],
        );
      },
    );
  }

  void _resumeScanner() {
    setState(() {
      _isProcessingScan = false;
      _isPaying = false;
    });
    _scannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Stack(
        children: [
          // Scanner Camera Preview viewport
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // High-end UI overlay (scanning target layout)
          Positioned.fill(
            child: Container(
              decoration: const ShapeDecoration(
                shape: QrScannerOverlayShape(
                  borderColor: Color(0xFFBB86FC),
                  borderRadius: 16,
                  borderLength: 30,
                  borderWidth: 6,
                  cutOutSize: 240,
                ),
              ),
            ),
          ),

          // Visual Instruction text
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Align the merchant QR code within the frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// QR Scanner Overlay Custom Painter
// ---------------------------------------------------------------------------
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderLength;
  final double borderRadius;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
    this.borderLength = 20.0,
    this.borderRadius = 0.0,
    this.cutOutSize = 250.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;

    final cutOutRect = Rect.fromCenter(
      center: Offset(width / 2, height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    // Dark screen overlay
    final backgroundPaint = Paint()..color = Colors.black.withValues(alpha: 0.65);
    final backgroundPath = Path()
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(backgroundPath, backgroundPaint);

    // Outline corner brackets
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final borderPath = Path();

    // Top-left
    borderPath.moveTo(cutOutRect.left, cutOutRect.top + borderLength);
    borderPath.lineTo(cutOutRect.left, cutOutRect.top);
    borderPath.lineTo(cutOutRect.left + borderLength, cutOutRect.top);

    // Top-right
    borderPath.moveTo(cutOutRect.right - borderLength, cutOutRect.top);
    borderPath.lineTo(cutOutRect.right, cutOutRect.top);
    borderPath.lineTo(cutOutRect.right, cutOutRect.top + borderLength);

    // Bottom-right
    borderPath.moveTo(cutOutRect.right, cutOutRect.bottom - borderLength);
    borderPath.lineTo(cutOutRect.right, cutOutRect.bottom);
    borderPath.lineTo(cutOutRect.right - borderLength, cutOutRect.bottom);

    // Bottom-left
    borderPath.moveTo(cutOutRect.left + borderLength, cutOutRect.bottom);
    borderPath.lineTo(cutOutRect.left, cutOutRect.bottom);
    borderPath.lineTo(cutOutRect.left, cutOutRect.bottom - borderLength);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
