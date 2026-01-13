import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final usernameCtrl = TextEditingController(); // NUEVO: Controlador para username
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    usernameCtrl.dispose(); // No olvides limpiarlo
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validamos que todos los campos estén llenos
    if (nameCtrl.text.isEmpty || 
        usernameCtrl.text.isEmpty || 
        emailCtrl.text.isEmpty || 
        passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(authNotifierProvider.notifier);

      // Enviamos todos los datos al backend
      await notifier.register(
        name: nameCtrl.text.trim(),
        username: usernameCtrl.text.trim(), // NUEVO
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );
      
      if (mounted) {
        // Verificamos si hubo error en el estado
        final authState = ref.read(authNotifierProvider);
        if (authState.errorMessage != null) {
           throw authState.errorMessage!;
        }

        // ÉXITO: Como este endpoint no devuelve token, redirigimos al Login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta creada con éxito. Por favor inicia sesión.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/login'); 
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shadow = BoxShadow(
      // Corrección de deprecación: withValues en lugar de withOpacity
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
            'Crea tu cuenta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          
          // --- CAMPO NOMBRE ---
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              labelText: 'Nombre Completo',
              prefixIcon: const Icon(Icons.person_outline),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            enabled: !_isLoading,
          ),
          const SizedBox(height: 12),

          TextField(
            controller: usernameCtrl,
            decoration: InputDecoration(
              labelText: 'Usuario (sin espacios)', // Aclara al usuario
              prefixIcon: const Icon(Icons.alternate_email),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            // ESTO EVITA ESPACIOS Y CARACTERES RAROS:
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')), 
            ],
            enabled: !_isLoading,
          ),
          const SizedBox(height: 12),

          // --- CAMPO EMAIL ---
          TextField(
            controller: emailCtrl,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.mail_outline),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 12),

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

          // --- BOTÓN DE REGISTRO ---
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _submit,
            icon: _isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check_circle_outline, color: Colors.white),
            label: Text(
              _isLoading ? 'Creando...' : 'Crear Cuenta',
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

          // --- IR A LOGIN ---
          TextButton.icon(
            onPressed: _isLoading ? null : () => context.go('/login'),
            icon: const Icon(Icons.login),
            label: const Text('Ya tengo cuenta'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.brown.shade700,
            ),
          ),
        ],
      ),
    );
  }
}