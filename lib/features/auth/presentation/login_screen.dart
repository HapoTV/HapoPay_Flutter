import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hapopay/core/constants/constants.dart';

import '../providers/auth_provider.dart'; // re-exports authProvider, AppUser, UserRole

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    await ref
        .read(authProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);

    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      // The router's redirect will navigate automatically; no manual push
      // needed. Explicit navigation is kept as a fast-path fallback.
      context.go(authState.user?.isParent == true ? '/parent' : '/student');
    } else if (authState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authState.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              verticalSpaceXXLarge,
              const Text(
                'Welcome to HapoPay',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              verticalSpaceXIVLLarge,
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: theme.colorScheme.onSurface)),
                keyboardType: TextInputType.emailAddress,
              ),
              verticalSpaceMedium,
              TextField(
                controller: _passwordController,
                decoration:  InputDecoration(labelText: 'Password', labelStyle: TextStyle(color: theme.colorScheme.onSurface)),
                obscureText: true,
              ),
              verticalSpaceXXLarge,
              ElevatedButton(
                onPressed: isLoading ? null : _onLogin,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
