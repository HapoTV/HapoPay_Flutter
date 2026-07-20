import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hapopay/core/constants/constants.dart';
import '../../student/providers/student_account_provider.dart';

class SpendingLimitsScreen extends ConsumerStatefulWidget {
  const SpendingLimitsScreen({super.key});

  @override
  ConsumerState<SpendingLimitsScreen> createState() =>
      _SpendingLimitsScreenState();
}

class _SpendingLimitsScreenState extends ConsumerState<SpendingLimitsScreen> {
  double _currentSliderValue = 50.0;
  bool _isCardLocked = false;
  bool _initialized = false;
  bool _isSaving = false;

  void _initializeState(double currentLimit) {
    if (_initialized) return;
    _currentSliderValue = currentLimit;
    _isCardLocked = currentLimit == 0.0;
    _initialized = true;
  }

  Future<void> _saveLimit() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final targetLimit = _isCardLocked ? 0.0 : _currentSliderValue;
      await ref.read(studentAccountProvider.notifier).updateLimit(targetLimit);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Spending limits updated successfully.'),
            backgroundColor: Color(0xFF1B5E20),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update limits: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountAsync = ref.watch(studentAccountProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Controls'),
      ),
      body: accountAsync.when(
        loading: () => Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary)),
        error: (err, _) => Center(
          child: Text('Error loading limits: $err',
              style: TextStyle(color: theme.colorScheme.error)),
        ),
        data: (account) {
          _initializeState(account.dailyLimit);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage Student Card Controls',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                verticalSpaceSmall,
                const Text(
                  'Instantly adjust spending limits or freeze the debit card to prevent unauthorized purchases.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                verticalSpaceXXLarge,

                // Card Freeze Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _isCardLocked
                        ? theme.colorScheme.error
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isCardLocked
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _isCardLocked
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isCardLocked ? Icons.lock : Icons.lock_open,
                          color: _isCardLocked
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface
                                  .withAlpha(Colors.white54 as int),
                        ),
                      ),
                      horizontalSpaceMedium,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Card Lock',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            horizontalSpaceTiny,
                            Text(
                              'Suspend all payments immediately',
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withAlpha(Colors.white54 as int),
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        activeThumbColor: theme.colorScheme.error,
                        value: _isCardLocked,
                        onChanged: (val) {
                          setState(() {
                            _isCardLocked = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                verticalSpaceXLarge,

                // Limit Settings Container (Disabled when locked)
                Opacity(
                  opacity: _isCardLocked ? 0.4 : 1.0,
                  child: IgnorePointer(
                    ignoring: _isCardLocked,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.onSurface),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Daily spending cap',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Icon(Icons.speed,
                                  color: theme.colorScheme.onSurface),
                            ],
                          ),
                          Divider(
                              height: 24, color: theme.colorScheme.onSurface),
                          verticalSpaceSmall,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Limit Value',
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurface)),
                              Text(
                                '\$${_currentSliderValue.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          verticalSpaceMedium,
                          Slider(
                            value: _currentSliderValue,
                            min: 5.0,
                            max: 200.0,
                            divisions: 39,
                            activeColor: theme.colorScheme.primary,
                            inactiveColor: theme.colorScheme.onSurface,
                            label: '\$${_currentSliderValue.round()}',
                            onChanged: (double value) {
                              setState(() {
                                //TODO: Change the statehandling to riverpod
                                _currentSliderValue = value;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('\$5.00',
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 12)),
                              Text('\$200.00',
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                verticalSpaceXVILarge,

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    onPressed: _isSaving ? null : _saveLimit,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save Spending Controls',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
