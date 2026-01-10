import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontkahoot2526/features/groups/presentation/providers/groups_notifier.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';
import 'package:flutter/services.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Future<void> _showEditDialog(BuildContext context, dynamic detail) async {
    final nameCtrl = TextEditingController(text: detail.name);
    final descCtrl = TextEditingController(text: detail.description ?? '');
    final notifier = ref.read(groupDetailProvider(widget.groupId).notifier);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar grupo'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
          TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () async {
            try {
              await notifier.updateGroup(name: nameCtrl.text.trim(), description: descCtrl.text.trim());
              Navigator.of(ctx).pop(true);
              if (mounted) _showSnack(context, 'Grupo actualizado');
            } catch (e) {
              Navigator.of(ctx).pop(false);
              if (mounted) _showSnack(context, 'Error al actualizar: $e');
            }
          }, child: const Text('Guardar')),
        ],
      ),
    );

    if (result == true) {
      // reload detail already done by notifier
    }
  }

  Future<void> _showInviteDialog(BuildContext context) async {
    final expiresCtrl = TextEditingController(text: '7d');
    final notifier = ref.read(groupDetailProvider(widget.groupId).notifier);

    await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setState) => AlertDialog(
          title: const Text('Generar link de invitación'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: expiresCtrl,
              decoration: const InputDecoration(
                labelText: 'Expira en',
                hintText: 'Ej: 7d, 24h',
              ),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx2).pop(false), child: const Text('Cerrar')),
            ElevatedButton(onPressed: () async {
              final expiresIn = expiresCtrl.text.trim().isEmpty ? '7d' : expiresCtrl.text.trim();
              try {
                final link = await notifier.generateInviteLink(expiresIn: expiresIn);
                await Clipboard.setData(ClipboardData(text: link));
                Navigator.of(ctx2).pop(true);
                if (mounted) _showSnack(context, 'Link copiado al portapapeles');
              } catch (e) {
                if (mounted) _showSnack(context, 'Error al generar link: $e');
              }
            }, child: const Text('Generar link')),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Borrar grupo'),
      content: const Text('¿Estás seguro que deseas borrar este grupo? Esta acción no se puede deshacer.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Borrar')),
      ],
    ));

    if (ok == true) {
      try {
        await ref.read(groupDetailProvider(widget.groupId).notifier).deleteGroup();
        if (!mounted) return;
        _showSnack(context, 'Grupo borrado');
        context.go('/groups');
      } catch (e) {
        if (mounted) _showSnack(context, 'Error al borrar: $e');
      }
    }
  }

  Future<bool> _confirmPromoteMember(BuildContext context, String memberName) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Promover miembro'),
      content: Text('¿Deseas promover a $memberName a admin?'),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('No')),
        ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Sí')),
      ],
    ));
    return ok == true;
  }

  Future<bool> _confirmRemoveMember(BuildContext context, String memberName) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Expulsar miembro'),
      content: Text('¿Deseas expulsar a $memberName del grupo?'),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Expulsar')),
      ],
    ));
    return ok == true;
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showAssignQuizDialog(BuildContext context) async {
    final notifier = ref.read(groupDetailProvider(widget.groupId).notifier);
    final creations = await notifier.loadMyCreations();
    final visible = creations.length > 5 ? creations.sublist(0, 5) : creations;
    String? selectedId;
    final availableFromCtrl = TextEditingController();
    final availableUntilCtrl = TextEditingController();

    Future<void> _pickDate(TextEditingController ctrl) async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(now.year - 5),
        lastDate: DateTime(now.year + 5),
      );
      if (picked != null) {
        final y = picked.year.toString().padLeft(4, '0');
        final m = picked.month.toString().padLeft(2, '0');
        final d = picked.day.toString().padLeft(2, '0');
        ctrl.text = '$y-$m-$d';
      }
    }

    String? _toIsoMidnight(String? dayText) {
      if (dayText == null || dayText.trim().isEmpty) return null;
      final t = dayText.trim();
      // Expect YYYY-MM-DD, convert to midnight UTC
      return '${t}T00:00:00Z';
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setState) => AlertDialog(
          title: const Text('Asignar uno de tus quices'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (visible.isEmpty)
                    const Text('No tienes quices creados')
                  else ...visible.map((q) => RadioListTile<String>(
                        title: Text(q.title),
                        value: q.id,
                        groupValue: selectedId,
                        onChanged: (val) => setState(() => selectedId = val),
                      )),
                  const SizedBox(height: 12),
                  TextField(
                    controller: availableFromCtrl,
                    readOnly: true,
                    onTap: () => _pickDate(availableFromCtrl),
                    decoration: const InputDecoration(
                      labelText: 'Disponible desde (día)',
                      hintText: 'Ej: 2026-01-17',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: availableUntilCtrl,
                    readOnly: true,
                    onTap: () => _pickDate(availableUntilCtrl),
                    decoration: const InputDecoration(
                      labelText: 'Disponible hasta (día)',
                      hintText: 'Ej: 2026-01-20',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx2).pop(false), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: selectedId == null
                  ? null
                  : () async {
                      try {
                        await notifier.assignQuiz(
                          selectedId!,
                          availableFrom: _toIsoMidnight(availableFromCtrl.text),
                          availableUntil: _toIsoMidnight(availableUntilCtrl.text),
                        );
                        Navigator.of(ctx2).pop(true);
                      } catch (e) {
                        if (mounted) _showSnack(context, 'Error asignando quiz: $e');
                      }
                    },
              child: const Text('Asignar'),
            ),
          ],
        ),
      ),
    );

    if (ok == true && mounted) {
      _showSnack(context, 'Quiz asignado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(groupDetailProvider(widget.groupId));

    return detailAsync.when(
      loading: () => Scaffold(appBar: AppBar(backgroundColor: AppColors.primaryRed), body: const Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(appBar: AppBar(backgroundColor: AppColors.primaryRed), body: Center(child: Text('Error: $e'))),
      data: (detail) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                final popped = await Navigator.maybePop(context);
                if (!popped) context.go('/groups');
              },
            ),
            title: Text(
              detail.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.primaryRed,
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.mustardYellow,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 14),
              tabs: const [
                Tab(icon: Icon(Icons.info_outline), text: 'Info'),
                Tab(icon: Icon(Icons.group_outlined), text: 'Miembros'),
                Tab(icon: Icon(Icons.quiz_outlined), text: 'Quices'),
                Tab(icon: Icon(Icons.emoji_events_outlined), text: 'Ranking'),
              ],
            ),
            actions: [
              if (detail.myRole == 'admin') ...[
                IconButton(
                  icon: const Icon(Icons.person_add),
                  tooltip: 'Invitar miembros',
                  onPressed: () => _showInviteDialog(context),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar grupo',
                  onPressed: () => _showEditDialog(context, detail),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Borrar grupo',
                  onPressed: () => _confirmDelete(context),
                ),
              ]
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          detail.myRole.toLowerCase().contains('admin')
                              ? Icons.shield_moon
                              : Icons.person_outline,
                          size: 18,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Mi rol: ${detail.myRole}',
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      detail.description?.isNotEmpty == true
                          ? detail.description!
                          : 'Sin descripción',
                      style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.35),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.groups, size: 18, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(
                            'Miembros: ${detail.totalMembers}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.assignment_turned_in_outlined, size: 18, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(
                            'Quices asignados: ${detail.totalAssignedQuizzes}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Miembros
              FutureBuilder<List<dynamic>>(
                future: ref.read(groupDetailProvider(widget.groupId).notifier).loadMembers(),
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
                  if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                  final members = snap.data ?? [];
                  if (members.isEmpty) return const Center(child: Text('No hay miembros'));
                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: members.length,
                    separatorBuilder: (_,__) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final m = members[i];
                      final isAdmin = detail.myRole == 'admin';
                      return ListTile(
                        title: Text(m.name),
                        subtitle: Text(m.email ?? ''),
                        trailing: isAdmin
                          ? PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'promote') {
                                  final ok = await _confirmPromoteMember(context, m.name);
                                  if (!ok) return;
                                  try {
                                    await ref.read(groupDetailProvider(widget.groupId).notifier).changeMemberRole(m.id, 'admin');
                                    if (!mounted) return;
                                    _showSnack(context, 'Miembro promovido a admin');
                                  } catch (e) {
                                    if (mounted) _showSnack(context, 'Error al promover: $e');
                                  }
                                } else if (value == 'remove') {
                                  final ok = await _confirmRemoveMember(context, m.name);
                                  if (!ok) return;
                                  try {
                                    await ref.read(groupDetailProvider(widget.groupId).notifier).removeMember(m.id);
                                    if (!mounted) return;
                                    _showSnack(context, 'Miembro eliminado');
                                  } catch (e) {
                                    if (mounted) _showSnack(context, 'Error al eliminar: $e');
                                  }
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'promote', child: Text('Promover a admin')),
                                const PopupMenuItem(value: 'remove', child: Text('Expulsar')),
                              ],
                            )
                          : Text(m.role),
                      );
                    }
                  );
                }
              ),

              // Quices
              FutureBuilder<List<dynamic>>(
                future: ref.read(groupDetailProvider(widget.groupId).notifier).loadQuizzes(),
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
                  if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                  final items = snap.data ?? [];
                  final isAdmin = detail.myRole == 'admin';
                  if (items.isEmpty) {
                    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text('No hay quices asignados'),
                      if (isAdmin) ...[
                        const SizedBox(height: 8),
                        ElevatedButton(onPressed: () => _showAssignQuizDialog(context), child: const Text('Asignar quiz')),
                      ]
                    ]));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length + (isAdmin ? 1 : 0),
                    separatorBuilder: (_,__) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      if (isAdmin && i == 0) {
                        return ElevatedButton(onPressed: () => _showAssignQuizDialog(context), child: const Text('Asignar quiz'));
                      }
                      final idx = isAdmin ? i - 1 : i;
                      final q = items[idx];
                      return ListTile(
                        title: Text(q.title),
                        subtitle: Text(q.description ?? ''),
                        trailing: Text(q.status),
                        onTap: () async {
                          // Show per-quiz internal ranking
                          try {
                            final rows = await ref.read(groupDetailProvider(widget.groupId).notifier).loadQuizLeaderboard(q.quizId ?? q.id);
                            if (!mounted) return;
                            // Present as a dialog
                            // ignore: use_build_context_synchronously
                            await showDialog<void>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Ranking de "${q.title}"'),
                                content: ConstrainedBox(
                                  constraints: const BoxConstraints(maxHeight: 420, minWidth: 320),
                                  child: rows.isEmpty
                                      ? const Text('Aún no hay resultados para este quiz')
                                      : ListView.separated(
                                          shrinkWrap: true,
                                          itemCount: rows.length,
                                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                                          itemBuilder: (ctx2, i) {
                                            final r = rows[i];
                                            return ListTile(
                                              leading: CircleAvatar(child: Text('${r.position}')),
                                              title: Text(r.userName),
                                              subtitle: Text('Completados: ${r.completedCount}'),
                                              trailing: Text('${r.totalScore} pts'),
                                            );
                                          },
                                        ),
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar')),
                                ],
                              ),
                            );
                          } catch (e) {
                            if (mounted) _showSnack(context, 'Error cargando ranking: $e');
                          }
                        },
                      );
                    }
                  );
                }
              ),

              // Ranking
              FutureBuilder<List<dynamic>>(
                future: ref.read(groupDetailProvider(widget.groupId).notifier).loadRanking(),
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
                  if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                  final rows = snap.data ?? [];
                  if (rows.isEmpty) return const Center(child: Text('Ranking vacío'));
                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: rows.length,
                    separatorBuilder: (_,__) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final r = rows[i];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${r.position}')),
                        title: Text(r.userName),
                        subtitle: Text('Completados: ${r.completedCount}'),
                        trailing: Text('${r.totalScore} pts'),
                      );
                    }
                  );
                }
              ),
            ],
          ),
        );
      }
    );
  }
}
