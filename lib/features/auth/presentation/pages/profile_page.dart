import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_card.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileNotifierProvider);
    final auth = ref.watch(authNotifierProvider);

    final loginUser = auth.user;
    final displayName = loginUser?.name ?? state.profile?.name ?? 'Usuario';
    final displayEmail = loginUser?.email ?? state.profile?.email ?? '';
    final displayUserType = loginUser?.userType ?? state.profile?.userType ?? 'USER';

    if (state.profile == null && !state.isLoading && state.errorMessage == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(profileNotifierProvider.notifier).getUserProfile();
      });
    }

    // Estilos del tema
    final primaryColor = const Color(0xFFFF6A5F);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // FONDO CON GRADIENTE
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
                // CABECERA PERSONALIZADA
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mi Perfil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Cambiar backend',
                        icon: const Icon(Icons.settings_ethernet, color: Colors.white),
                        onPressed: () => context.push('/back-settings'),
                      ),
                    ],
                  ),
                ),

                // CONTENIDO PRINCIPAL
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : state.errorMessage != null
                          ? Center(child: Text('Error: ${state.errorMessage}'))
                          : SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                              physics: const AlwaysScrollableScrollPhysics(),
                              // Usamos el widget separado
                              child: ProfileCard(
                                state: state,
                                displayName: displayName,
                                displayEmail: displayEmail,
                                displayUserType: displayUserType,
                                primaryColor: primaryColor,
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