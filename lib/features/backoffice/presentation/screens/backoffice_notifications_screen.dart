import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/backoffice_providers.dart';
import 'send_notifications_screen.dart';

class BackofficeNotificationsScreen extends ConsumerStatefulWidget {
  const BackofficeNotificationsScreen({super.key});

  @override
  ConsumerState<BackofficeNotificationsScreen> createState() => _BackofficeNotificationsScreenState();
}

class _BackofficeNotificationsScreenState extends ConsumerState<BackofficeNotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(backofficeNotificationsProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(backofficeNotificationsProvider);
    final notifier = ref.read(backofficeNotificationsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Notificaciones'),
      ),
      // BOTÓN FLOTANTE PARA CREAR NUEVA
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SendNotificationScreen()),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      body: state.isLoading && state.notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(child: Text('Error: ${state.errorMessage}'))
              : RefreshIndicator(
                  onRefresh: notifier.refresh,
                  child: state.notifications.isEmpty
                      ? const Center(child: Text("No hay notificaciones enviadas."))
                      : ListView.separated(
                          controller: _scrollController,
                          itemCount: state.notifications.length + (state.hasMoreData ? 1 : 0),
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            if (index == state.notifications.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            final notification = state.notifications[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: notification.sender.imageUrl != null 
                                    ? NetworkImage(notification.sender.imageUrl!) 
                                    : null,
                                child: notification.sender.imageUrl == null 
                                    ? const Icon(Icons.send) 
                                    : null,
                              ),
                              title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(notification.message),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Enviado por: ${notification.sender.name} - ${_formatDate(notification.createdAt)}",
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }
}