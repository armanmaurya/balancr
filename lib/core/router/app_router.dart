import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:ledger_book_flutter/features/user/presentation/pages/login_page.dart';
import 'package:ledger_book_flutter/features/splash/presentation/pages/splash_page.dart';
import 'package:ledger_book_flutter/features/settings/presentation/pages/settings_page.dart';
import 'package:ledger_book_flutter/features/settings/presentation/pages/language_page.dart';
import 'package:ledger_book_flutter/features/transaction/presentation/pages/transaction_form_page.dart';
import 'package:ledger_book_flutter/screens/search_person.dart';
import '../../features/contacts/presentation/pages/contact_form_page.dart';
import '../../features/contacts/presentation/pages/contacts_page.dart';
import '../../features/transaction/domain/entities/transaction_entity.dart';
import '../../features/transaction/presentation/pages/transaction_screen.dart';
import 'routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder:
            (context, state) =>
                CupertinoPage(key: state.pageKey, child: const SplashPage()),
      ),
      GoRoute(
        path: AppRoutes.contacts,
        pageBuilder:
            (context, state) =>
                CupertinoPage(key: state.pageKey, child: const ContactsPage()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder:
            (context, state) =>
                CupertinoPage(key: state.pageKey, child: const LoginPage()),
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) {
          return CupertinoPage(key: state.pageKey, child: const SettingsPage());
        },
      ),
      GoRoute(
        path: AppRoutes.language,
        pageBuilder:
            (context, state) =>
                CupertinoPage(key: state.pageKey, child: const LanguagePage()),
      ),
      GoRoute(
        path: AppRoutes.addContact,
        pageBuilder: (context, state) {
          return CupertinoPage(
            key: state.pageKey,
            child: AddContactPage.addContactPage(
              initialName: state.uri.queryParameters['name'],
              phone: state.uri.queryParameters['phone'],
              email: state.uri.queryParameters['email'],
              id: state.uri.queryParameters['id'],
            ),
          );
        },
      ),

      // Transaction routes can be added here similarly
      GoRoute(
        path: "${AppRoutes.transaction}/:personId",
        pageBuilder: (context, state) {
          final personId = state.pathParameters['personId'];
          return CupertinoPage(
            key: state.pageKey,
            child: TransactionScreen(contactId: personId!),
          );
        },
      ),
      GoRoute(
        path: "${AppRoutes.transactionForm}/:contactId",
        pageBuilder: (context, state) {
          final contactId = state.pathParameters['contactId'];
          final transaction = state.extra as TransactionEntity?;
          return CupertinoPage(
            key: state.pageKey,
            child: TransactionFormPage(
              contactId: contactId!,
              transaction: transaction,
            ),
          );
        },
      ),

      // Search Local Contacts
      GoRoute(
        path: AppRoutes.searchLocalContact,
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          child: const SearchPersonPage(),
        ),
      )
    ],
  );
}
