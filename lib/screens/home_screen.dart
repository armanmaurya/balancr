import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ledger_book_flutter/screens/search_person.dart';
import 'package:ledger_book_flutter/widgets/cards/balance_summary_card.dart';
import 'package:ledger_book_flutter/widgets/cards/person_card.dart';
import 'package:ledger_book_flutter/widgets/modal_bottom_sheets/delete_person_bottom_sheet.dart';
import 'package:ledger_book_flutter/widgets/modal_bottom_sheets/edit_person_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../providers/ledger_provider.dart';
import 'transaction_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _requestContactPermission(BuildContext context) async {
    final status = await Permission.contacts.status;
    if (!status.isGranted) {
      final result = await Permission.contacts.request();
      if (!result.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact permission is required to access contacts.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestContactPermission(context);
    });

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
                    BalanceSummaryCard(
                      totalGive: totalGive,
                      totalTake: totalTake,
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
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((ctx, i) {
                final person = ledger.people[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PersonCard(
                    person: person,
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => TransactionScreen(personId: person.id),
                        ),
                      );
                    },
                    onMenu: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        enableDrag: true,
                        builder: (ctx) => SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                              left: 16,
                              right: 16,
                              top: 24,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.edit),
                                  title: const Text('Edit'),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    displayEditPersonBottomSheet(
                                      context,
                                      person.id,
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete),
                                  title: const Text('Delete'),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    displayDeletePersonBottomSheet(
                                      context,
                                      person.id,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }, childCount: ledger.people.length),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            CupertinoPageRoute(builder: (context) => const SearchPersonPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
