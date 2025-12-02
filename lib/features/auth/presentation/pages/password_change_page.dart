import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/profile_providers.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final currentPasswordCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cambiar Contraseña")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: currentPasswordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña Actual'),
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
                final currentPassword = currentPasswordCtrl.text.trim();
                final newPassword = newPasswordCtrl.text.trim();

                try {
                  // Llamamos al notifier para cambiar la contraseña
                  await ref.read(profileNotifierProvider.notifier)
                      .changePassword(currentPassword, newPassword);

                  // Si todo fue bien, mostramos un mensaje de éxito
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contraseña actualizada con éxito')),
                  );
                  context.go('/profile'); // Redirige a la página de perfil
                } catch (e) {
                  setState(() {
                    errorMessage = e.toString();
                  });
                }
              },
              child: const Text('Cambiar Contraseña'),
            ),
          ],
        ),
      ),
    );
  }
}
