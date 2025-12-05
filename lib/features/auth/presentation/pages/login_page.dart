import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import '../widgets/login_form.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }

      if (next.user != null) {
        // Login OK → navega
        //Navigator.pushReplacementNamed(context, '/home');
        context.go('/home');
      }
    });

    

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: authState.isLoading
            ? const CircularProgressIndicator()
            : const LoginForm(),
      ),
    );
  }

  
}
