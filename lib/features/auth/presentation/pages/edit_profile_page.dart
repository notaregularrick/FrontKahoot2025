import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_providers.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
void initState() {
  super.initState();
  
  // Obtener el estado actual del perfil desde el ProfileNotifier
  final profileState = ref.read(profileNotifierProvider);

  // Verifica si el perfil ya está cargado, para evitar errores si aún no está disponible
  if (profileState.profile != null) {
    nameController.text = profileState.profile!.name; // Acceder a profile.name
    emailController.text = profileState.profile!.email; // Acceder a profile.email
    descriptionController.text = profileState.profile!.description; // Acceder a profile.description
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Perfil")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Descripción"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final notifier = ref.read(profileNotifierProvider.notifier);

                await notifier.updateProfile({
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'description': descriptionController.text.trim(),
                });

                // Si el perfil fue actualizado con éxito, navega de vuelta al perfil
                if (mounted) {
                  Navigator.pop(context);  // Regresar a la página del perfil
                }
              },
              child: const Text("Actualizar Perfil"),
            ),
          ],
        ),
      ),
    );
  }
}
