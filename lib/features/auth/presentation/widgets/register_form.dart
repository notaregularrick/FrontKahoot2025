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
  
  // 1. Variable para controlar el estado de carga
  bool _isLoading = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validar campos vacíos rápidamente
    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(authNotifierProvider.notifier);

      // 2. Intentamos registrar
      await notifier.register(
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      // Verificamos si hubo un error guardado en el estado (depende de cómo esté hecho tu notifier)
      // Pero si tu notifier lanza excepción en caso de error, el catch lo agarrará.
      
      if (mounted) {
        // Verificar el estado después de la operación
        final authState = ref.read(authNotifierProvider);

        if (authState.errorMessage != null) {
           throw authState.errorMessage!; // Forzamos ir al catch
        }

        // 3. SI LLEGAMOS AQUÍ, TODO SALIÓ BIEN -> NAVEGAR
        // Usamos go para ir a profile y borrar el historial de registro si lo deseas
        // O push si quieres permitir volver atrás.
        context.go('/inicio'); 
      }

    } catch (e) {
      // 4. Manejo de errores visual
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // 5. Apagar carga siempre
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shadow = BoxShadow(
      color: Colors.black.withOpacity(0.05),
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
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              labelText: 'Nombre',
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