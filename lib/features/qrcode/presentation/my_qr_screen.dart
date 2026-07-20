import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hapopay/core/constants/constants.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../auth/providers/auth_provider.dart';

class MyQrScreen extends ConsumerStatefulWidget {
  const MyQrScreen({super.key});

  @override
  ConsumerState<MyQrScreen> createState() => _MyQrScreenState();
}

class _MyQrScreenState extends ConsumerState<MyQrScreen> {
  final _amountController = TextEditingController(text: '10.00');
  final _descController = TextEditingController(text: 'Pocket Money Request');

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _generateQrPayload(String studentId, String studentName) {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final payload = {
      'student_id': studentId,
      'student_name': studentName,
      'amount': amount,
      'description': _descController.text,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    return jsonEncode(payload);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).user;
    final studentId = user?.id ?? 'student_123';
    final studentName = user?.fullName ?? 'Demo Student';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My QR Code'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Receive Payments & Allowances',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            verticalSpaceSmall,
            Text(
              'Show this QR code to a parent or merchant to request money.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
            ),
            verticalSpaceSmall,

            // Dynamic QR Code Container with nice aesthetic styling
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme
                    .onSurface, // QR code needs a white background for scanners to detect it easily
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: _generateQrPayload(studentId, studentName),
                    version: QrVersions.auto,
                    size: 200.0,
                    gapless: false,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: theme.colorScheme.onSurface,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    studentName,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  verticalSpaceTiny,
                  Text(
                    'Scan to pay HapoPay user',
                    style: TextStyle(
                      color: theme.colorScheme.onError,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            verticalSpaceXXLarge,

            // Form Fields to dynamically update QR details
            Card(
              color: theme.colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount (\$)',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        //TODO: Change the state manager to riverpod
                        setState(() {});
                      },
                    ),
                    verticalSpaceMedium,
                    TextField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description_outlined),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
