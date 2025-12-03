import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontkahoot2526/features/groups/presentation/providers/groups_notifier.dart';

class JoinGroupScreen extends ConsumerStatefulWidget {
  final String token;
  const JoinGroupScreen({super.key, required this.token});

  @override
  ConsumerState<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends ConsumerState<JoinGroupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) router.pop();
          },
        ),
        title: const Text('Unirse a grupo'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          const Text('Has abierto un enlace de invitación. Introduce tu nombre y opcionalmente tu email para unirte.'),
          const SizedBox(height: 12),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
          TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email (opcional)')),
          const SizedBox(height: 20),
          _loading ? const CircularProgressIndicator() : ElevatedButton(
            onPressed: () async {
              final name = _nameCtrl.text.trim();
              final email = _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Introduce un nombre')));
                return;
              }
              setState(() { _loading = true; });
              try {
                final summary = await ref.read(groupsRepositoryProvider).joinGroupWithToken(widget.token, name: name, email: email);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Te has unido al grupo')));
                // navigate to group detail
                context.go('/groups/${summary.id}');
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              } finally {
                if (mounted) setState(() { _loading = false; });
              }
            },
            child: const Text('Unirse'),
          ),
        ]),
      ),
    );
  }
}
