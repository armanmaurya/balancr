import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ledger_book_flutter/features/user/presentation/providers/auth_provider.dart';

class FinancialOverviewSlivers extends ConsumerWidget {
  const FinancialOverviewSlivers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financialData = ref.watch(userFinancialDataProvider);
    
    return financialData.when(
      data: (userEntity) {
        if (userEntity == null) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Card(
              // elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Overview',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Net Balance (Most Important)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getNetBalanceColor(userEntity.netBalance, context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getNetBalanceColor(userEntity.netBalance, context).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                userEntity.netBalance >= 0 
                                    ? Icons.trending_up 
                                    : userEntity.netBalance < 0 
                                        ? Icons.trending_down 
                                        : Icons.trending_flat,
                                color: _getNetBalanceColor(userEntity.netBalance, context),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Net Balance',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${userEntity.netBalance.abs().toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: _getNetBalanceColor(userEntity.netBalance, context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getNetBalanceColor(userEntity.netBalance, context).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              userEntity.netBalance > 0 
                                  ? 'You have given money' 
                                  : userEntity.netBalance < 0
                                      ? 'You have received money'
                                      : 'All settled up',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getNetBalanceColor(userEntity.netBalance, context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Given and Taken Summary
                    Row(
                      children: [
                        // Total Given
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  color: Colors.green[600],
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Given',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹${userEntity.totalGiven.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.green[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Total Taken
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  color: Colors.orange[600],
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Taken',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹${userEntity.totalTaken.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.orange[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverToBoxAdapter(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.withOpacity(0.1),
                    Colors.grey.withOpacity(0.05),
                  ],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ),
      ),
      error: (error, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }

  Color _getNetBalanceColor(double netBalance, BuildContext context) {
    if (netBalance > 0) {
      return Colors.green[600]!; // User is owed money (positive)
    } else if (netBalance < 0) {
      return Colors.red[600]!; // User owes money (negative)
    } else {
      return Colors.grey[600]!; // Balanced
    }
  }
}