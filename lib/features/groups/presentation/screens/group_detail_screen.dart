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
      )
    );

    if (result == true) {
      // reload detail already done by notifier; optionally refresh tab view
    }
  }

  Future<void> _showInviteDialog(BuildContext context) async {
    final emailCtrl = TextEditingController();
    String role = 'student';
    final notifier = ref.read(groupDetailProvider(widget.groupId).notifier);

    await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setState) => AlertDialog(
          title: const Text('Invitar a miembros'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email (opcional)')),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: role,
              decoration: const InputDecoration(labelText: 'Rol'),
              items: const [
                DropdownMenuItem(value: 'admin', child: Text('admin')),
                DropdownMenuItem(value: 'teacher', child: Text('teacher')),
                DropdownMenuItem(value: 'student', child: Text('student')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => role = v);
              },
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx2).pop(false), child: const Text('Cerrar')),
            ElevatedButton(onPressed: () async {
              final email = emailCtrl.text.trim();
              final selectedRole = role.trim().isEmpty ? 'student' : role.trim();
              try {
                if (email.isNotEmpty) {
                  await notifier.inviteMember(email, selectedRole);
                  Navigator.of(ctx2).pop(true);
                  if (mounted) _showSnack(context, 'Invitación enviada a $email');
                } else {
                  final link = await notifier.generateInviteLink(role: selectedRole);
                  await Clipboard.setData(ClipboardData(text: link));
                  Navigator.of(ctx2).pop(true);
                  if (mounted) _showSnack(context, 'Link copiado al portapapeles');
                }
              } catch (e) {
                if (mounted) _showSnack(context, 'Error al invitar: $e');
              }
            }, child: const Text('Enviar / Generar link')),
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
    final quizzes = List.generate(6, (i) => {'id': 'q$i', 'title': 'Quiz $i'});
    final selected = await showDialog<String?>(context: context, builder: (ctx) => SimpleDialog(
      title: const Text('Seleccionar quiz para asignar'),
      children: quizzes.map((q) => SimpleDialogOption(onPressed: () => Navigator.of(ctx).pop(q['id'] as String), child: Text(q['title'] as String))).toList(),
    ));
    if (selected != null) {
      try {
        await notifier.assignQuiz(selected);
        if (mounted) _showSnack(context, 'Quiz asignado');
      } catch (e) {
        if (mounted) _showSnack(context, 'Error asignando quiz: $e');
      }
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
          backgroundColor: AppColors.creamBackground.withOpacity(0.3),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                final popped = await Navigator.maybePop(context);
                if (!popped) context.go('/groups');
              },
            ),
            title: Text(detail.name),
            backgroundColor: AppColors.primaryRed,
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [Tab(text: 'Info'), Tab(text: 'Miembros'), Tab(text: 'Quices'), Tab(text: 'Ranking')],
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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(detail.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(detail.description ?? ''),
                  const SizedBox(height: 12),
                  Text('Mi rol: ${detail.myRole}'),
                  const SizedBox(height: 8),
                  Text('Miembros: ${detail.totalMembers}  •  Quices asignados: ${detail.totalAssignedQuizzes}'),
                ]),
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
                        onTap: () {
                          // TODO: open quiz detail (reuse kahoot inspect flow)
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
