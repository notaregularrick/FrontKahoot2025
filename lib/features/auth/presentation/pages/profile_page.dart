import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_providers.dart'; // Verifica que esta ruta sea correcta

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Escuchamos cambios en el estado
    final state = ref.watch(profileNotifierProvider);

    // 2. LÓGICA AUTOMÁTICA DE CARGA (El "Trigger")
    // Si no hay perfil, no está cargando y no hay error, forzamos la petición de datos.
    if (state.profile == null && !state.isLoading && state.errorMessage == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Usamos read porque estamos dentro de un callback, no queremos re-renderizar aquí
        ref.read(profileNotifierProvider.notifier).getUserProfile();
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      // 3. Renderizado condicional directo (sin Builder extra)
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(child: Text('Error: ${state.errorMessage}'))
              : state.profile == null
                  ? const Center(child: Text('Cargando datos del perfil...'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(), // Permite scroll suave
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- AVATAR ---
                            Center(
                              child: CircleAvatar(
                                radius: 50,
                                // Validación segura de la URL
                                backgroundImage: (state.profile!.avatarUrl.isNotEmpty)
                                    ? NetworkImage(state.profile!.avatarUrl)
                                    : null,
                                child: (state.profile!.avatarUrl.isEmpty)
                                    ? const Icon(Icons.person, size: 50)
                                    : null,
                              ),
                            ),
                            
                            const SizedBox(height: 20),

                            // --- ITEMS DE INFORMACIÓN ---
                            // Usamos state.profile! con seguridad porque ya validamos que no es null arriba
                            _InfoItem(label: 'Nombre', value: state.profile!.name),
                            _InfoItem(label: 'Email', value: state.profile!.email),
                            _InfoItem(label: 'Descripción', value: state.profile!.description),
                            _InfoItem(label: 'Tipo de Usuario', value: state.profile!.userType),
                            _InfoItem(label: 'Racha', value: state.profile!.gameStreak.toString()),

                            const SizedBox(height: 30),

                            // --- BOTÓN EDITAR ---
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Usamos push para apilar la vista y poder regresar
                                  context.push('/edit-profile');
                                },
                                child: const Text('Editar Perfil'),
                              ),
                            ),
                            
                            const SizedBox(height: 10),

                            // --- BOTÓN CAMBIAR CONTRASEÑA ---
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade100,
                                  foregroundColor: Colors.red.shade900,
                                ),
                                onPressed: () {
                                  context.push('/passchange');
                                },
                                child: const Text('Cambiar Contraseña'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}

// Widget auxiliar para estilos (se queda igual)
class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label, 
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 16, 
              color: Colors.grey
            )
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? "No especificado" : value, 
            style: const TextStyle(fontSize: 18)
          ),
          const Divider(),
        ],
      ),
    );
  }
}