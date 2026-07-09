import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hapo_pay/features/auth/providers/auth_provider.dart';
import 'package:hapo_pay/shared/widgets/action_card.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider.select((s) => s.user));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hey, ${user?.fullName ?? 'Student'}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ready to make a payment?',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6200EE), Color(0xFFBB86FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text(
                    'Available Balance',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '\$120.50',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const _BalanceInfo(label: 'Today', value: '\$15.00'),
                      Container(width: 1, height: 40, color: Colors.white24),
                      const _BalanceInfo(label: 'Limit', value: '\$50.00'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ActionCard(
              title: 'Pay with QR',
              subtitle: 'Scan a merchant code',
              icon: Icons.qr_code_scanner,
              onTap: () {},
            ),
            const SizedBox(height: 16),
            ActionCard(
              title: 'My QR Code',
              subtitle: 'Show code to receive money',
              icon: Icons.qr_code,
              onTap: () {},
            ),
            const SizedBox(height: 16),
            ActionCard(
              title: 'Rewards',
              subtitle: 'View your saving achievements',
              icon: Icons.emoji_events_outlined,
              onTap: () {},
              color: Colors.amber,
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceInfo extends StatelessWidget {
  final String label;
  final String value;

  const _BalanceInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
