import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

//import '../../domain/entities/profile_entity.dart';
import '../../infraestructure/models/profile_model.dart';
import '../providers/auth_providers.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late Future<ProfileModel> userProfile;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    userProfile = ref.read(authRepositoryProvider).getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      body: FutureBuilder<ProfileModel>(
        future: userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No se encontraron datos del perfil.'));
          }

          final user = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(user.avatarUrl),
                  radius: 40,
                ),
                const SizedBox(height: 16),
                Text('Nombre: ${user.name}', style: TextStyle(fontSize: 20)),
                Text('Email: ${user.email}', style: TextStyle(fontSize: 18)),
                Text('Descripción: ${user.description}', style: TextStyle(fontSize: 18)),
                Text('Tipo de Usuario: ${user.userType}', style: TextStyle(fontSize: 18)),
                Text('Racha de Juego: ${user.gameStreak}', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.go('/edit-profile'); // O redirigir a otra página si es necesario
                  },
                  child: const Text('Editar Perfil'),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.go('/passchange'); // O redirigir a otra página si es necesario
                  },
                  child: const Text('Cambiar Contraseña'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
