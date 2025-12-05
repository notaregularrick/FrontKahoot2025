import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Importante para context.pop()
import '../providers/profile_providers.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  // Inicializamos los controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController descriptionController;
  
  bool isLoading = false; // Para evitar doble tap y mostrar carga

  @override
  void initState() {
    super.initState();
    
    // Leemos el estado INICIAL
    final profileState = ref.read(profileNotifierProvider);
    final user = profileState.profile;

    // Inicializamos los controladores con los datos actuales O cadenas vacías si es null
    nameController = TextEditingController(text: user?.name ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
    descriptionController = TextEditingController(text: user?.description ?? '');
  }

  @override
  void dispose() {
    // IMPORTANTE: Siempre limpiar los controladores
    nameController.dispose();
    emailController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    // 1. Evitar que el usuario presione el botón varias veces
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final notifier = ref.read(profileNotifierProvider.notifier);

      // 2. Preparamos los datos.
      // Si el backend no acepta campos vacíos, deberías validar aquí antes de enviar.
      // Al usar .trim(), quitamos espacios accidentales.
      final Map<String, dynamic> dataToSend = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'description': descriptionController.text.trim(),
      };

      // 3. Llamada asíncrona dentro de TRY-CATCH
      await notifier.updateProfile(dataToSend);

      // 4. Verificamos si el widget sigue montado antes de usar el contexto
      if (mounted) {
        // Usamos GoRouter para volver atrás
        context.pop(); 
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
      }
    } catch (e) {
      // 5. MANEJO DE ERRORES: Si falla, mostramos por qué y quitamos la carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // 6. Siempre quitamos el estado de carga al final
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Perfil")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Evita error de pixel overflow si sale teclado
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress, // Teclado de email
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Descripción"),
                maxLines: 3, // Permite escribir más en la descripción
              ),
              const SizedBox(height: 20),
              
              // Botón con indicador de carga
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleUpdate,
                  child: isLoading 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2)
                        )
                      : const Text("Actualizar Perfil"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}