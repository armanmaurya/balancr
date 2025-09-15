import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ledger_book_flutter/core/router/routes.dart';

class SplashPage extends StatefulWidget {
	const SplashPage({super.key});

	@override
	State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
	StreamSubscription<User?>? _sub;

	@override
	void initState() {
		super.initState();
		// Listen once to auth state and navigate.
		_sub = FirebaseAuth.instance.authStateChanges().listen((user) {
			final router = GoRouter.of(context);
			if (!mounted) return;
			if (user != null) {
				router.go(AppRoutes.contacts);
			} else {
				router.go(AppRoutes.login);

			}
		});
	}

	@override
	void dispose() {
		_sub?.cancel();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final scheme = Theme.of(context).colorScheme;
		return Scaffold(
			body: Center(
				child: LoadingAnimationWidget.staggeredDotsWave(
					color: scheme.primary,
					size: 56,
				),
			),
		);
	}
}
