import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:ledger_book_flutter/models/person.dart';
import 'package:ledger_book_flutter/models/transaction.dart';
import 'package:ledger_book_flutter/providers/ledger_provider.dart';
import 'package:ledger_book_flutter/screens/home_screen.dart';
import 'package:ledger_book_flutter/screens/onboarding/onboarding_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(PersonAdapter());

  await Hive.openBox<Person>('people');

  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  runApp(
    ChangeNotifierProvider(
      create: (_) => LedgerProvider(),
      child: MyApp(onboardingCompleted: onboardingCompleted),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.onboardingCompleted});

  final bool onboardingCompleted;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ledger Book',
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: onboardingCompleted ? const HomeScreen() : const OnboardingScreen(),
      routes: {'/dashboard': (context) => const HomeScreen()},
    );
  }
}
