import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hapopay/core/constants/constants.dart';
import 'package:intl/intl.dart';
import '../../student/providers/student_account_provider.dart';

class FamilyLedgerScreen extends ConsumerWidget {
  const FamilyLedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(studentAccountProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(studentAccountProvider.notifier).refresh(),
          ),
        ],
      ),
      body: accountAsync.when(
        loading: () => Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary)),
        error: (err, _) => Center(
          child: Text('Error loading transactions: $err',
              style: TextStyle(color: theme.colorScheme.error)),
        ),
        data: (account) {
          final txs = account.transactions;

          if (txs.isEmpty) {
            return Center(
              child: Text(
                'No transactions recorded yet.',
                style:
                    TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24.0),
            itemCount: txs.length,
            separatorBuilder: (context, index) => verticalSpaceSmall,
            itemBuilder: (context, index) {
              final tx = txs[index];
              final isDebit = tx.type == 'debit';
              final formattedTime =
                  DateFormat('MMM d, h:mm a').format(tx.timestamp.toLocal());

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.surface),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDebit
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDebit ? Icons.arrow_outward : Icons.call_received,
                        color: isDebit
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.description,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedTime,
                            style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withAlpha(Colors.white54 as int),
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${isDebit ? '-' : '+'}\$${tx.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDebit
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
