import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(labelText: "Email"),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: passCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Password"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final notifier = ref.read(authNotifierProvider.notifier);
              notifier.login(
                emailCtrl.text.trim(),
                passCtrl.text.trim(),
              );
            },
            child: const Text("Login"),
          ),
          TextButton(
            onPressed: () => context.push('/register'),
            child: const Text("Crear Cuenta"),
          ),
          TextButton(
            onPressed: () => context.push('/passreset'),
            child: const Text("Olvide mi Contraseña"),
          )

        ],
      ),
    );
  }
}
