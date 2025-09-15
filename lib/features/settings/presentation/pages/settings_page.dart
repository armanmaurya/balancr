import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ledger_book_flutter/providers/theme_provider.dart';
import 'package:ledger_book_flutter/providers/language_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:ledger_book_flutter/core/router/routes.dart';
import 'package:ledger_book_flutter/l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    // Show confirmation dialog before signing out
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        // Navigate to login after signing out
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final languageProvider = context.watch<LanguageProvider>();
  final user = FirebaseAuth.instance.currentUser;

    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          _Section(
            title: t.profileTitle,
            children: [
              ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Center(
                    child: Text(
                      (user?.displayName?.isNotEmpty ?? false)
                          ? user!.displayName![0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  user?.displayName ?? 'User',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(user?.email ?? t.signedIn),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.outline,
                ),
                onTap: () {
                  // Navigate to profile edit page
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Preferences Section
          _Section(
            title: t.preferencesTitle,
            children: [
              SwitchListTile(
                value: themeProvider.isDark,
                onChanged: (val) => themeProvider.setDark(val),
                secondary: Icon(
                  themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(t.darkMode),
                subtitle: Text(themeProvider.isDark ? t.enabled : t.disabled),
              ),
              ListTile(
                leading: Icon(
                  Icons.language,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(t.language),
                subtitle: Text(languageProvider.labelFor(languageProvider.locale)),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.outline,
                ),
                onTap: () async {
                  context.push(AppRoutes.language);
                },
              ),
              // Currency selection could come later
            ],
          ),
          
          const SizedBox(height: 24),
          
          // About Section
          _Section(
            title: t.aboutTitle,
            children: [
              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(t.version),
                subtitle: const Text('1.0.1+2'),
              ),
              ListTile(
                leading: Icon(
                  Icons.description,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(t.termsOfService),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.outline,
                ),
                onTap: () {
                  // Navigate to terms of service
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.security,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(t.privacyPolicy),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.outline,
                ),
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Sign Out Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout),
              label: Text(t.signOut),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // App Info Footer
          Center(
            child: Text(
              'Balancr © 2023',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Material(
          color: Theme.of(context).colorScheme.surfaceContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: children.map((child) {
              final index = children.indexOf(child);
              return Column(
                children: [
                  child,
                  if (index < children.length - 1)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// language selection moved to a dedicated page