import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import 'package:go_router/go_router.dart';

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final nameCtrl = TextEditingController();
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
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: "Nombre"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(labelText: "Email"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Contraseña"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final notifier = ref.read(authNotifierProvider.notifier);

              await notifier.register(
                name: nameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                password: passCtrl.text.trim(),
              );

              // si todo salió bien => user no es null
              if (mounted) {
                // si todo salió bien => user no es null
                final user = ref.read(authNotifierProvider).user;
                if (user != null) {
                  // ignore: use_build_context_synchronously
                  context.go('/home');
                }
              }
            },
            child: const Text("Crear Cuenta"),
          ),

          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text("Ya tengo cuenta"),
          )
        ],
      ),
    );
  }
}
