import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

class LibraryHomeScreen extends StatelessWidget {
  const LibraryHomeScreen({super.key});

  ButtonStyle _flatButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all(AppColors.primaryRed),
      foregroundColor: MaterialStateProperty.all(Colors.white),
      elevation: MaterialStateProperty.all(2),
      shadowColor: MaterialStateProperty.all(AppColors.primaryRed.withOpacity(0.25)),
      overlayColor: MaterialStateProperty.all(Colors.white12),
      padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 14, horizontal: 12)),
      shape: MaterialStateProperty.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mi Biblioteca', style: TextStyle(fontSize: 25)),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            _MenuButton(
              icon: Icons.quiz_outlined,
              label: 'Quices',
              onTap: () => context.go('/library/quices'),
              style: _flatButtonStyle(),
            ),
            const SizedBox(height: 12),
            _MenuButton(
              icon: Icons.groups_outlined,
              label: 'Grupos',
              onTap: () => context.go('/groups'),
              style: _flatButtonStyle(),
            ),
            const SizedBox(height: 12),
            _MenuButton(
              icon: Icons.bar_chart_outlined,
              label: 'Reportes',
              onTap: () => context.push('/reports'),
              style: _flatButtonStyle(),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.red.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.black54),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Accede rápido a tus quices, grupos y reportes. Puedes crear o asignar contenido desde cada sección.',
                        style: TextStyle(color: Colors.black87, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ButtonStyle style;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: style,
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
