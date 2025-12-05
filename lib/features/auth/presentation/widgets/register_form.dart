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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: "Nombre"),
            enabled: !_isLoading, // Deshabilitar mientras carga
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(labelText: "Email"),
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Contraseña"),
            enabled: !_isLoading,
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit, // Desactiva el botón si carga
              child: _isLoading 
                ? const SizedBox(
                    height: 20, 
                    width: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  )
                : const Text("Crear Cuenta"),
            ),
          ),

          TextButton(
            onPressed: _isLoading ? null : () => context.go('/login'),
            child: const Text("Ya tengo cuenta"),
          )
        ],
      ),
    );
  }
}