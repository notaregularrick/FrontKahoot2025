import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/backoffice_providers.dart';
import '../../domain/entities/backoffice_user.dart';

class BackofficeScreen extends ConsumerStatefulWidget {
  const BackofficeScreen({super.key});

  @override
  ConsumerState<BackofficeScreen> createState() => _BackofficeScreenState();
}

class _BackofficeScreenState extends ConsumerState<BackofficeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(backofficeNotifierProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(backofficeNotifierProvider);
    final notifier = ref.read(backofficeNotifierProvider.notifier);

    ref.listen(backofficeNotifierProvider, (previous, next) {
      if (next.errorMessage != null && !next.isLoading) {
        if (previous?.errorMessage != next.errorMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!.replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'CERRAR',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: "Ordenar por...",
            onSelected: notifier.onSortChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'createdAt', child: Text('Por Fecha de Creación')),
              const PopupMenuItem(value: 'name', child: Text('Por Nombre')),
              const PopupMenuItem(value: 'userType', child: Text('Por Rol')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: notifier.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: state.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          notifier.onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

          Expanded(
            child: state.isLoading && state.users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: notifier.refresh,
                    child: state.users.isEmpty
                        ? const Center(child: Text("No se encontraron usuarios."))
                        : ListView.separated(
                            controller: _scrollController,
                            itemCount: state.users.length + (state.hasMoreData ? 1 : 0),
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              if (index == state.users.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }

                              final user = state.users[index];
                              return _UserListTile(user: user);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _UserListTile extends ConsumerWidget {
  final BackofficeUserEntity user;

  const _UserListTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isActive = user.status == 'Active';
    final bool isAdmin = user.isAdmin;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isAdmin ? Colors.purple.shade100 : Colors.blue.shade100,
        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        child: user.avatarUrl == null
            ? Text(
                user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                style: TextStyle(
                  color: isAdmin ? Colors.purple : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        user.name.isNotEmpty ? user.name : user.username,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.email),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  user.userType.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              if (isAdmin) ...[
                const Icon(Icons.verified_user, size: 14, color: Colors.purple),
                const SizedBox(width: 4),
                const Text(
                  'ADMIN',
                  style: TextStyle(fontSize: 10, color: Colors.purple, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
              ],
              if (!isActive)
                const Text(
                  'BLOQUEADO',
                  style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                ),
            ],
          )
        ],
      ),
      // BOTONES DE ACCIÓN
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. DAR Admin
          if (!isAdmin && isActive)
            IconButton(
              icon: const Icon(Icons.security, color: Colors.blueAccent),
              tooltip: "Hacer Administrador",
              onPressed: () async {
                await ref.read(backofficeNotifierProvider.notifier).giveAdmin(user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Permisos de admin otorgados a ${user.username}')),
                  );
                }
              },
            ),

          // 2. QUITAR Admin
          if (isAdmin && isActive)
            IconButton(
              icon: const Icon(Icons.remove_moderator, color: Colors.orange),
              tooltip: "Quitar Administrador",
              onPressed: () async {
                await ref.read(backofficeNotifierProvider.notifier).removeAdmin(user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Permisos de admin revocados a ${user.username}')),
                  );
                }
              },
            ),

          // 3. BLOQUEAR
          if (isActive)
            IconButton(
              icon: const Icon(Icons.block, color: Colors.red),
              tooltip: "Bloquear Usuario",
              onPressed: () async {
                await ref.read(backofficeNotifierProvider.notifier).blockUser(user.id);
              },
            ),
          
          // 4. DESBLOQUEAR
          if (!isActive)
             IconButton(
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
              tooltip: "Desbloquear Usuario",
              onPressed: () async {
                await ref.read(backofficeNotifierProvider.notifier).unblockUser(user.id);
              },
            ),

          // 5. ELIMINAR
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.deepOrange),
            tooltip: "Eliminar permanentemente",
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('¿Eliminar usuario?'),
                  content: Text('¿Estás seguro que deseas eliminar a ${user.username}?\nEsta acción no se puede deshacer.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        await ref.read(backofficeNotifierProvider.notifier).deleteUser(user.id);
                      },
                      child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ID Usuario: ${user.id}')),
        );
      },
    );
  }
}