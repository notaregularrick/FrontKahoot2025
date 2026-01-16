import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';

class ProfileCard extends ConsumerWidget {
  final dynamic state;
  final String displayName;
  final String displayEmail;
  final String displayUserType;
  final Color primaryColor;

  const ProfileCard({
    super.key,
    required this.state,
    required this.displayName,
    required this.displayEmail,
    required this.displayUserType,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shadow = BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 16,
      offset: const Offset(0, 10),
    );

    final isAdmin = displayUserType.toUpperCase() == 'ADMIN';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [shadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- AVATAR CON BORDE ---
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: primaryColor.withValues(alpha: 0.2), width: 3),
              ),
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: (state.profile?.avatarUrl.isNotEmpty == true)
                    ? NetworkImage(state.profile!.avatarUrl)
                    : null,
                child: (state.profile?.avatarUrl.isEmpty ?? true)
                    ? Icon(Icons.person, size: 45, color: Colors.grey.shade400)
                    : null,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- DATOS PRINCIPALES ---
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayEmail,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                displayUserType.toUpperCase(),
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 20),

          // --- INFORMACIÓN ADICIONAL ---
          _InfoRow(
            icon: Icons.description_outlined,
            label: 'Descripción',
            value: state.profile?.description.isEmpty ?? true
                ? 'Sin descripción'
                : state.profile!.description,
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.local_fire_department_outlined,
            label: 'Racha',
            value: '${state.profile?.gameStreak ?? 0} días',
            valueColor: Colors.orange,
          ),

          const SizedBox(height: 32),

          // --- BOTONES DE ACCIÓN ---

          // 0. Panel de Admin (SOLO SI ES ADMIN)
          //if (isAdmin) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/backoffice'),
                icon: const Icon(Icons.admin_panel_settings, size: 20),
                label: const Text('Panel de Administración'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          //],

          // 1. Editar Perfil
          ElevatedButton.icon(
            onPressed: () => context.push('/edit-profile'),
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: const Text('Editar Perfil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 2. Cambiar Contraseña
          OutlinedButton.icon(
            onPressed: () => context.push('/passchange'),
            icon: const Icon(Icons.lock_outline, size: 20),
            label: const Text('Cambiar Contraseña'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 3. Cerrar Sesión
          TextButton.icon(
            onPressed: () async {
              final notifier = ref.read(authNotifierProvider.notifier);
              await notifier.logout();
              if (context.mounted) {
                context.go('/inicio');
              }
            },
            icon: Icon(Icons.logout, size: 20, color: Colors.red.shade400),
            label: Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red.shade400),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar privado (solo se usa dentro de la card)
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}