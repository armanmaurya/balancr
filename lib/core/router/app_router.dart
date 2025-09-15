import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:ledger_book_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:ledger_book_flutter/features/splash/presentation/pages/splash_page.dart';
import 'package:ledger_book_flutter/features/settings/presentation/pages/settings_page.dart';
import 'package:ledger_book_flutter/features/settings/presentation/pages/language_page.dart';
import '../../features/contacts/presentation/pages/contact_form_page.dart';
import '../../features/contacts/presentation/pages/contacts_page.dart';
import 'routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.contacts,
        builder: (context, state) => const ContactsPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
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
    ],
  );
}
