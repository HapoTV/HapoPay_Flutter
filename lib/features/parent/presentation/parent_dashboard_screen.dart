import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hapopay/core/constants/constants.dart';
import '../../../shared/widgets/action_card.dart';
import '../../auth/providers/auth_provider.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final theme = Theme.of(context);

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
            verticalSpaceSmall,
            Text(
              'Manage your family accounts',
              style: TextStyle(
                  color: theme.colorScheme.onSurface
                      .withAlpha(Colors.white54 as int)),
            ),
            verticalSpaceXXLarge,
            ActionCard(
              title: 'Family Ledger',
              subtitle: 'View all student transactions',
              icon: Icons.history,
              onTap: () => context.push('/parent/ledger'),
            ),
            verticalSpaceMedium,
            ActionCard(
              title: 'Spending Limits',
              subtitle: 'Set daily and weekly caps',
              icon: Icons.speed,
              onTap: () => context.push('/parent/limits'),
            ),
            verticalSpaceMedium,
            ActionCard(
              title: 'Card Lock',
              subtitle: 'Suspend payment capabilities',
              icon: Icons.lock_outline,
              onTap: () => context.push('/parent/limits'),
              color: theme.colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}
