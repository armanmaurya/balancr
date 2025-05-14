import 'package:flutter/material.dart';
import 'package:ledger_book_flutter/widgets/cards/person_card.dart';
import 'package:provider/provider.dart';
import '../providers/ledger_provider.dart';
import 'transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddPersonDialog(BuildContext context) {
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Person',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Enter name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.trim().isNotEmpty) {
                        Provider.of<LedgerProvider>(
                          context,
                          listen: false,
                        ).addPerson(nameController.text.trim());
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Person',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  void _showEditPersonDialog(BuildContext context, int personIndex) {
    final ledger = Provider.of<LedgerProvider>(context, listen: false);
    final person = ledger.people[personIndex];
    final nameController = TextEditingController(text: person.name);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Person',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Enter name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.trim().isNotEmpty) {
                        ledger.updatePerson(
                          personIndex,
                          nameController.text.trim(),
                        );
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  void _showDeletePersonDialog(BuildContext context, int personIndex) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Person'),
            content: const Text('Are you sure you want to delete this person?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<LedgerProvider>(
                    context,
                    listen: false,
                  ).deletePerson(personIndex);
                  Navigator.of(ctx).pop();
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  // Reusable balance indicator widget
  Widget _buildBalanceIndicator(
    BuildContext context, {
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color.withOpacity(0.9)),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ledger = Provider.of<LedgerProvider>(context);

    // Calculate totals
    double totalGive = 0;
    double totalTake = 0;
    for (final person in ledger.people) {
      final balance = person.transactions.fold(
        0.0,
        (sum, tx) => tx.isGiven ? sum - tx.amount : sum + tx.amount,
      );
      if (balance > 0) {
        totalGive += balance.abs();
      } else if (balance < 0) {
        totalTake += balance.abs();
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Ledger Book'),
            centerTitle: true,
            floating: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                // vertical: 8,
              ),
              child: Column(
                children: [
                  if (ledger.people.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 16, bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade800, width: 0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBalanceIndicator(
                            context,
                            label: 'To Give',
                            amount: totalGive,
                            icon: Icons.arrow_upward,
                            color: Colors.red.shade400,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.shade700,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          _buildBalanceIndicator(
                            context,
                            label: 'To Take',
                            amount: totalTake,
                            icon: Icons.arrow_downward,
                            color: Colors.green.shade400,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (ledger.people.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 100,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Persons Added Yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Add a person to get started!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final person = ledger.people[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: PersonCard(
                      person: person,
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                              milliseconds: 300,
                            ),
                            reverseTransitionDuration: const Duration(
                              milliseconds: 300,
                            ),
                            pageBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                            ) {
                              return TransactionScreen(index: i);
                            },
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              final slideIn = Tween<Offset>(
                                begin: const Offset(
                                  1.0,
                                  0.0,
                                ), // From right
                                end: Offset.zero,
                              ).chain(CurveTween(curve: Curves.ease));
        
                              final slideOut = Tween<Offset>(
                                begin: Offset.zero,
                                end: const Offset(-1.0, 0.0), // To left
                              ).chain(CurveTween(curve: Curves.ease));
        
                              return SlideTransition(
                                position: animation.drive(slideIn),
                                child: SlideTransition(
                                  position: secondaryAnimation.drive(
                                    slideOut,
                                  ),
                                  child: child,
                                ),
                              );
                            },
                          ),
                        );
                      },
                      onEdit: () => _showEditPersonDialog(context, i),
                      onDelete: () => _showDeletePersonDialog(context, i),
                    ),
                  );
                },
                childCount: ledger.people.length,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPersonDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
