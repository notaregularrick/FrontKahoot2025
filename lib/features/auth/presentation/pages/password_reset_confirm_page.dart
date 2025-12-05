import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';

class PasswordResetConfirmPage extends ConsumerStatefulWidget {
  const PasswordResetConfirmPage({super.key});

  @override
  ConsumerState<PasswordResetConfirmPage> createState() => _PasswordResetConfirmPageState();
}

class _PasswordResetConfirmPageState extends ConsumerState<PasswordResetConfirmPage> {
  final resetTokenCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Establecer Nueva Contraseña")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: resetTokenCtrl,
              decoration: const InputDecoration(labelText: 'Token de Restablecimiento'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nueva Contraseña'),
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
                final resetToken = resetTokenCtrl.text.trim();
                final newPassword = newPasswordCtrl.text.trim();

                try {
                  if (newPassword.length < 8) {
                    setState(() {
                      errorMessage = 'La contraseña debe tener al menos 8 caracteres.';
                    });
                    return;
                  }// Llamamos al repositorio para confirmar el restablecimiento de contraseña
                  await ref.read(authRepositoryProvider).confirmPasswordReset(resetToken, newPassword);

                  // Si todo salió bien, mostramos un mensaje de éxito
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contraseña actualizada con éxito')),
                  );

                  // Redirigimos a login o donde necesites
                  context.go('/login');
                } catch (e) {
                  setState(() {
                    errorMessage = e.toString();
                  });
                }
              },
              child: const Text('Confirmar Nueva Contraseña'),
            ),
          ],
        ),
      ),
    );
  }
}
