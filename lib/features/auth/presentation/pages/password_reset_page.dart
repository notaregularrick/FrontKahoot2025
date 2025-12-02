import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';

class PasswordResetPage extends ConsumerStatefulWidget {
  const PasswordResetPage({super.key});

  @override
  ConsumerState<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends ConsumerState<PasswordResetPage> {
  final emailController = TextEditingController();
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Restablecer Contraseña")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Correo Electrónico'),
            ),
            const SizedBox(height: 16),
            if (errorMessage != null) ...[
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();

                try {
                  await ref.read(authRepositoryProvider).requestPasswordReset(email);
                  if (mounted) {
                    // Solo muestra el SnackBar si el widget aún está montado
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Correo enviado con éxito')),
                    );
                  }
                } catch (e) {
                  setState(() {
                    errorMessage = e.toString();
                  });
                }
              },
              child: const Text('Enviar correo de restablecimiento'),
            ),
          ],
        ),
      ),
    );
  }
}
