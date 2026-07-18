import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/constants.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../providers/auth_provider.dart';
// import '../models/user_model.dart';

// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _onLogin() async {
//     await ref
//         .read(authProvider.notifier)
//         .login(_emailController.text, _passwordController.text);

//     final authState = ref.read(authProvider);
//     if (!mounted) return;
//     if (authState.user != null) {
//       if (authState.user!.role == UserRole.parent) {
//         context.go('/parent');
//       } else {
//         context.go('/student');
//       }
//     } else if (authState.error != null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(authState.error!)));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isLoading = ref.watch(authProvider.select((s) => s.isLoading));

//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const Icon(Icons.account_balance_wallet,
//                   size: 80, color: Color(0xFFBB86FC)),
//               const SizedBox(height: 32),
//               const Text(
//                 'Welcome to HapoPay',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 40),
//               TextField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(labelText: 'Email'),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(labelText: 'Password'),
//                 obscureText: true,
//               ),
//               const SizedBox(height: 32),
//               ElevatedButton(
//                 onPressed: isLoading ? null : _onLogin,
//                 child: isLoading
//                     ? const CircularProgressIndicator(color: Colors.black)
//                     : const Text('Login'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "HapoPay",
          style: theme.textTheme.headlineLarge!.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [
          verticalSpaceLarge,
          Text("Welcome Back", style: theme.textTheme.displayMedium),
          verticalSpaceSmall,
          Text(
            "Secure access to your family's wealth",
            style: theme.textTheme.bodyLarge!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          verticalSpaceLarge,
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text("Email", style: theme.textTheme.bodyLarge),
                  verticalSpaceTiny,
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      hintText: "hello@hapopay.com",
                      hintStyle: TextStyle(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  verticalSpaceSmall,
                  Text("Password", style: theme.textTheme.bodyLarge),
                  verticalSpaceTiny,
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  verticalSpaceSmall,
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed:
                          null, // Implement forgot password functionality
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                  verticalSpaceMedium,
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      onPressed: null, // Implement login functionality
                      child: Row(
                        mainAxisSize: .min,
                        children: [
                          Text(
                            "Sign In",
                            style: theme.textTheme.labelLarge!.copyWith(
                              color: theme.colorScheme.inverseSurface,
                            ),
                          ),
                          horizontalSpaceTiny,
                          const Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          verticalSpaceMedium,
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Don't have an account? ",
                  style: theme.textTheme.bodyMedium,
                ),
                TextSpan(
                  text: "Create Account",
                  style: theme.textTheme.labelLarge!.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Implement navigation to the registration screen
                      context.push("/signUp");
                    },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
