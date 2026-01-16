import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/groups/presentation/providers/groups_notifier.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:frontkahoot2526/features/auth/presentation/providers/auth_providers.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh list on entry and on token change (switch user).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(groupsListProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth token changes and refresh groups when it changes
    ref.listen<String?>(
      authNotifierProvider.select((s) => s.token),
      (prev, next) {
        if (prev != next) {
          ref.invalidate(groupsListProvider);
        }
      },
    );
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
                        onTap: () {
                          // Siempre recargar datos del grupo (miembros, quices, ranking)
                          // cada vez que se entra al detalle.
                          ref.invalidate(groupDetailProvider(g.id));
                          context.go('/groups/${g.id}');
                        },
                      );
                    },
                  ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón de unirse abajo a la izquierda
              FloatingActionButton.extended(
                heroTag: 'join-group',
                onPressed: () async {
                  final token = await _showJoinDialog(context);
                  if (token == null || token.trim().isEmpty) return;
                  final cleanToken = _extractToken(token.trim());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Uniendo al grupo...')),
                  );
                  try {
                    await ref.read(groupsListProvider.notifier).joinWithInvite(cleanToken);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Te has unido al grupo')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      final msg = _prettyError(e);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No se pudo unir: $msg')),
                      );
                    }
                  }
                },
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryRed,
                icon: const Icon(Icons.link),
                label: const Text('Unirse con enlace'),
              ),
              // Espaciador para separar de la derecha
              FloatingActionButton(
                heroTag: 'create-group',
                onPressed: () async {
                  final result = await showDialog<Map<String, String>?>(
                    context: context,
                    builder: (ctx) {
                      final nameCtrl = TextEditingController();
                      final descCtrl = TextEditingController();
                      return AlertDialog(
                        title: const Text('Crear grupo'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: nameCtrl,
                              decoration: const InputDecoration(labelText: 'Nombre'),
                            ),
                            TextField(
                              controller: descCtrl,
                              decoration: const InputDecoration(labelText: 'Descripción'),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(
                              ctx,
                              {
                                'name': nameCtrl.text,
                                'desc': descCtrl.text,
                              },
                            ),
                            child: const Text('Crear'),
                          ),
                        ],
                      );
                    },
                  );

                  if (result != null && (result['name']?.trim().isNotEmpty ?? false)) {
                    await ref
                        .read(groupsListProvider.notifier)
                        .createGroup(result['name']!.trim(), result['desc']?.trim());
                  }
                },
                backgroundColor: AppColors.primaryRed,
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> _showJoinDialog(BuildContext context) async {
  final linkCtrl = TextEditingController();
  return showDialog<String?>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Unirse a un grupo'),
        content: TextField(
          controller: linkCtrl,
          decoration: const InputDecoration(
            labelText: 'Pega el enlace o token',
            hintText: 'https://.../join?invitationToken=abc',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, linkCtrl.text), child: const Text('Unirse')),
        ],
      );
    },
  );
}

String _extractToken(String raw) {
  // Try query param invitationToken
  try {
    final uri = Uri.parse(raw);
    final qp = uri.queryParameters['invitationToken'] ?? uri.queryParameters['token'] ?? uri.queryParameters['t'];
    if (qp != null && qp.isNotEmpty) return qp;
    if (uri.pathSegments.isNotEmpty) return uri.pathSegments.last;
  } catch (_) {}
  // Fallback: return raw
  return raw;
}

String _prettyError(Object e) {
  try {
    if (e is Exception) {
      final dynamic de = e;
      // Try to access DioException fields without import coupling
      final res = (de as dynamic).response;
      if (res != null) {
        final data = res.data;
        if (data is Map && data['message'] is String) return data['message'];
        if (data is String && data.isNotEmpty) return data;
        final sc = res.statusCode;
        if (sc != null) return 'HTTP $sc';
      }
    }
  } catch (_) {}
  return e.toString();
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

