import 'package:flutter/material.dart';
import 'package:ledger_book_flutter/widgets/modal_bottom_sheets/confirmation_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:ledger_book_flutter/providers/ledger_provider.dart';

Future<T?> displayDeletePersonBottomSheet<T>(BuildContext context, String personId) {
  return showConfirmationBottomSheet<T>(
    context: context,
    title: 'Delete Person',
    message: 'Are you sure you want to delete this person?',
    icon: Icons.warning_amber_rounded,
    iconColor: Colors.red.shade400,
    onConfirm: () {
      Provider.of<LedgerProvider>(
        context,
        listen: false,
      ).deletePerson(personId);
    },
  );
}