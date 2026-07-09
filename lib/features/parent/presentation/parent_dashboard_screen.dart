import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hapo_pay/features/auth/providers/auth_provider.dart';
import 'package:hapo_pay/shared/widgets/action_card.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider.select((s) => s.user));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
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
              'Hello, ${user?.fullName ?? 'Parent'}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your family accounts',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 32),
            ActionCard(
              title: 'Family Ledger',
              subtitle: 'View all student transactions',
              icon: Icons.history,
              onTap: () {},
            ),
            const SizedBox(height: 16),
            ActionCard(
              title: 'Spending Limits',
              subtitle: 'Set daily and weekly caps',
              icon: Icons.speed,
              onTap: () {},
            ),
            const SizedBox(height: 16),
            ActionCard(
              title: 'Card Lock',
              subtitle: 'Suspend payment capabilities',
              icon: Icons.lock_outline,
              onTap: () {},
              color: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }
}
