import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BackofficeMenuScreen extends StatelessWidget {
  const BackofficeMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AdminOptionCard(
            icon: Icons.people_alt,
            title: 'Gestión de Usuarios',
            subtitle: 'Ver, bloquear y administrar roles',
            color: Colors.blue,
            onTap: () => context.push('/backoffice/users'),
          ),
          const SizedBox(height: 16),
          _AdminOptionCard(
            icon: Icons.notifications_active,
            title: 'Notificaciones Masivas',
            subtitle: 'Historial de mensajes enviados',
            color: Colors.orange,
            onTap: () => context.push('/backoffice/notifications'),
          ),
        ],
      ),
    );
  }
}

class _AdminOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}