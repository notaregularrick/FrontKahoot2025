import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/groups/presentation/providers/groups_notifier.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';
import 'package:go_router/go_router.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupsListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final popped = await Navigator.maybePop(context);
            if (!popped) context.go('/library');
          },
        ),
        title: const Text('Mis Grupos', style: TextStyle(fontSize: 22)),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: groupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error cargando grupos: $e')),
        data: (groups) {
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(groupsListProvider.notifier).load();
            },
            child: groups.isEmpty
                ? ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                    children: [
                      const Icon(Icons.groups, size: 64, color: Colors.black26),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          'Aún no tienes grupos',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Crea tu primer grupo con el botón +',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: groups.length,
                    separatorBuilder: (_,__) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final g = groups[index];
                      return _GroupCard(
                        name: g.name,
                        description: g.description ?? '',
                        memberCount: g.memberCount,
                        role: g.role,
                        onTap: () => context.go('/groups/${g.id}'),
                      );
                    },
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<Map<String,String>?>(
            context: context,
            builder: (ctx) {
              final nameCtrl = TextEditingController();
              final descCtrl = TextEditingController();
              return AlertDialog(
                title: const Text('Crear grupo'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
                    TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción')),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                  ElevatedButton(onPressed: () => Navigator.pop(ctx, {'name': nameCtrl.text, 'desc': descCtrl.text}), child: const Text('Crear')),
                ],
              );
            }
          );

          if (result != null && (result['name']?.trim().isNotEmpty ?? false)) {
            await ref.read(groupsListProvider.notifier).createGroup(result['name']!.trim(), result['desc']?.trim());
          }
        },
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final String name;
  final String description;
  final int memberCount;
  final String role;
  final VoidCallback onTap;

  const _GroupCard({
    required this.name,
    required this.description,
    required this.memberCount,
    required this.role,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = Colors.red.shade50;
    final Color border = Colors.red.shade100;
    final bool isAdmin = role.toLowerCase().contains('admin');
    final Chip roleChip = Chip(
      label: Text(role),
      labelStyle: TextStyle(
        color: isAdmin ? Colors.red.shade900 : Colors.blueGrey.shade700,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: isAdmin ? Colors.red.shade100 : Colors.blueGrey.shade100,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description.isEmpty ? 'Sin descripción' : description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.groups, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text('$memberCount miembros', style: const TextStyle(color: Colors.black87)),
                  ],
                ),
                const SizedBox(height: 6),
                roleChip,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

