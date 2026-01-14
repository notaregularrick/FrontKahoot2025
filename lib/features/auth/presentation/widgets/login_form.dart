import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../providers/auth_providers.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final usernameCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    usernameCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (usernameCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa usuario y contraseña')),
      );
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      await ref.read(authNotifierProvider.notifier).login(
        usernameCtrl.text.trim(),
        passCtrl.text.trim(),
      );
      

    } catch (e) {
      if (mounted) {
        // setState(() => _isLoading = false);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.errorMessage != null && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!.replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final shadow = BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 16,
      offset: const Offset(0, 10),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [shadow],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Accede a tu cuenta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          
          // --- CAMPO USUARIO ---
          TextField(
            controller: usernameCtrl,
            decoration: InputDecoration(
              labelText: 'Usuario',
              prefixIcon: const Icon(Icons.person_outline),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
            enabled: !_isLoading,
          ),
          const SizedBox(height: 14),
          
          // --- CAMPO CONTRASEÑA ---
          TextField(
            controller: passCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            enabled: !_isLoading,
          ),
          const SizedBox(height: 18),
          
          // --- BOTÓN INGRESAR ---
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _submit,
            icon: _isLoading 
                ? const SizedBox(
                    height: 18, width: 18, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                  ) 
                : const Icon(Icons.login, color: Colors.white),
            label: Text(
              _isLoading ? 'Ingresando...' : 'Ingresar',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6A5F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // BOTÓN CREAR CUENTA
          OutlinedButton.icon(
            onPressed: _isLoading ? null : () => context.push('/register'),
            icon: const Icon(Icons.person_add_alt),
            label: const Text('Crear cuenta'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFFFF6A5F)),
              foregroundColor: const Color(0xFFFF6A5F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          // BOTÓN CAMBIAR BACKEND
          TextButton.icon(
            onPressed: _isLoading ? null : () => context.push('/back-settings'),
            icon: const Icon(Icons.cloud_sync),
            label: const Text('Cambiar backend'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.brown.shade700,
            ),
          ),
        ],
      ),
    );
  }
}