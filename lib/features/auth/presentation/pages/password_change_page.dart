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
  final confirmPasswordCtrl = TextEditingController();
  
  bool isLoading = false;

  @override
  void dispose() {
    currentPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (currentPasswordCtrl.text.isEmpty || 
        newPasswordCtrl.text.isEmpty || 
        confirmPasswordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    if (newPasswordCtrl.text != confirmPasswordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas nuevas no coinciden')),
      );
      return;
    }

    setState(() => isLoading = true);
    FocusScope.of(context).unfocus();

    final currentPassword = currentPasswordCtrl.text.trim();
    final newPassword = newPasswordCtrl.text.trim();

    try {
      await ref.read(profileNotifierProvider.notifier)
          .changePassword(currentPassword, newPassword);

      if (mounted) {
        final profileState = ref.read(profileNotifierProvider);
        if (profileState.errorMessage != null) {
           throw profileState.errorMessage!;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña actualizada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFF6A5F);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. FONDO CON GRADIENTE
          Container(
            height: 300,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFF6A5F),
                  Color(0xFFFF9472),
                  Colors.white,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 2. CABECERA CON BOTÓN ATRÁS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const Text(
                        'Seguridad',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. TARJETA FLOTANTE CON FORMULARIO
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Cambiar Contraseña',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Asegúrate de usar una contraseña fuerte y segura.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // --- CAMPO ACTUAL ---
                          TextField(
                            controller: currentPasswordCtrl,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Contraseña Actual',
                              prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryColor, width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- CAMPO NUEVA ---
                          TextField(
                            controller: newPasswordCtrl,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Nueva Contraseña',
                              prefixIcon: Icon(Icons.key_rounded, color: primaryColor),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryColor, width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- CAMPO CONFIRMAR NUEVA ---
                          TextField(
                            controller: confirmPasswordCtrl,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Confirmar Nueva Contraseña',
                              prefixIcon: Icon(Icons.check_circle_outline, color: primaryColor),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryColor, width: 1.5),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),

                          // --- BOTÓN CAMBIAR ---
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isLoading ? null : _handleChangePassword,
                              icon: isLoading 
                                  ? const SizedBox(
                                      height: 20, 
                                      width: 20, 
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                                    )
                                  : const Icon(Icons.security, color: Colors.white),
                              label: Text(
                                isLoading ? 'Actualizando...' : 'Actualizar Contraseña',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}