import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ledger_book_flutter/providers/language_provider.dart';
import 'package:ledger_book_flutter/l10n/app_localizations.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
  final languageProvider = context.watch<LanguageProvider>();
  final current = languageProvider.locale;
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.language),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: t.chooseLanguage,
            children: [
              RadioListTile<Locale?>(
                value: null,
                groupValue: current,
                onChanged: (val) => languageProvider.setLocale(val),
                title: Text(t.system),
              ),
              ...LanguageProvider.supportedLocales.map(
                (loc) => RadioListTile<Locale?>(
                  value: loc,
                  groupValue: current,
                  onChanged: (val) => languageProvider.setLocale(val),
                  title: Text(languageProvider.labelFor(loc)),
                ),
              ),
            ],
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
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        Material(
          color: scheme.surfaceContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
