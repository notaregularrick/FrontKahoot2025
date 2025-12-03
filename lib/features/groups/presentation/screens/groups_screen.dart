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
      backgroundColor: AppColors.creamBackground.withOpacity(0.3),
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
          if (groups.isEmpty) return const Center(child: Text('No tienes grupos aún.'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: groups.length,
            separatorBuilder: (_,__) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final g = groups[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(g.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(g.description ?? ''),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${g.memberCount} miembros'),
                      const SizedBox(height: 6),
                      Text(g.role, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  onTap: () => context.go('/groups/${g.id}'),
                ),
              );
            },
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

