import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ledger_book_flutter/core/router/routes.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:ledger_book_flutter/l10n/app_localizations.dart';
import 'package:ledger_book_flutter/services/firestore_user_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Reuse a single instance
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _loading = false;
  String? _error;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Always show the account chooser by clearing any cached account
      // (prevents auto-selecting the previously used account)
      await _googleSignIn.signOut();
      // Optionally revoke to ensure re-consent on some devices (ignore errors)
      try { await _googleSignIn.disconnect(); } catch (_) {}

      // Trigger the authentication flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // user aborted
        if (mounted) {
          setState(() {
            _error = 'Sign-in cancelled';
          });
        }
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      // Upsert user document in Firestore
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirestoreUserService().upsertUser(user);
        }
      } catch (e, st) {
        // ignore: avoid_print
        print('Failed to upsert Firestore user: $e\n$st');
      }
      if (!mounted) return;
      context.go(AppRoutes.contacts);
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = e.message ?? e.code);
      // ignore: avoid_print
      print('FirebaseAuthException: code=${e.code}, message=${e.message}, email=${e.email}, credential=${e.credential}');
    } on PlatformException catch (e, st) {
      // Common cause on Android: ApiException 10 (DEVELOPER_ERROR)
      final isDevError = e.code == 'sign_in_failed' && (e.message?.contains('ApiException: 10') ?? false);
      if (mounted) {
        setState(() => _error = isDevError
            ? 'Google Sign-In configuration error (code 10). Please add your debug SHA-1/SHA-256 to Firebase and replace google-services.json.'
            : 'Google Sign-In failed: ${e.message ?? e.code}');
      }
      // ignore: avoid_print
      print('PlatformException during Google sign-in: code=${e.code}, message=${e.message}, details=${e.details}\n$st');
    } on Exception catch (e, st) {
      // PlatformException or others
      if (mounted) setState(() => _error = e.toString());
      // ignore: avoid_print
      print('Sign-in error: $e\n$st');
    } catch (e) {
      if (mounted) setState(() => _error = 'Sign-in failed. Please try again.');
      // ignore: avoid_print
      print('Unknown sign-in error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.surface.withOpacity(0.8),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade50,
                      Colors.white,
                    ],
                  ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App Logo/Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 3,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Welcome Text
                    Text(
                      t.loginWelcome,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Subtitle
                    Text(
                      t.loginSubtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    
                    // Error Message
                    if (_error != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.onErrorContainer,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_error != null) const SizedBox(height: 20),
                                        
                    // Google Sign In Button
                    _GoogleButton(
                      onPressed: _loading ? null : _signInWithGoogle,
                      loading: _loading,
                    ),
                    const SizedBox(height: 40),
                    
                    // Terms and Privacy
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          children: [
                            TextSpan(text: t.termsPrefix),
                            TextSpan(
                              text: t.termsOfService,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: t.and),
                            TextSpan(
                              text: t.privacyPolicy,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: t.termsSuffixPeriod),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed, required this.loading});

  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 1,
          shadowColor: Colors.black12,
          side: BorderSide(color: theme.colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : SvgPicture.asset(
                    'assets/icons/google.svg',
                    width: 24,
                    height: 24,
                  ),
            const SizedBox(width: 12),
            Text(
              loading ? t.signingIn : t.continueWithGoogle,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}