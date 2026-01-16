import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/controllers/quiz_detail_notifier.dart';
import '../../domain/entities/quiz_entity.dart';
import '../providers/quiz_providers.dart';

class QuizDetailScreen extends ConsumerWidget {
  final String quizId;
  final QuizEntity? quizSummary;

  const QuizDetailScreen({
    super.key, 
    required this.quizId, 
    this.quizSummary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = QuizDetailFamilyParams(id: quizId, quiz: quizSummary);
    
    final state = ref.watch(quizDetailProvider(params));

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // ESTADO DE CARGA (Solo pasará si entras sin objeto quiz)
    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ESTADO DE ERROR (Si entras sin objeto y la API falla)
    if (state.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sentiment_dissatisfied, size: 60, color: Colors.grey),
                const SizedBox(height: 20),
                Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text("Volver a Explorar"),
                )
              ],
            ),
          ),
        ),
      );
    }

    // ESTADO DE ÉXITO
    final quiz = state.quiz;
    if (quiz == null) return const SizedBox();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // IMAGEN DE PORTADA
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                quiz.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    quiz.coverImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade800,
                      child: const Center(child: Icon(Icons.image_not_supported, color: Colors.white, size: 50)),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (context.canPop()) context.pop();
                else context.go('/home');
              },
            ),
          ),

          // CONTENIDO
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría
                  Row(
                    children: [
                      Chip(
                        label: Text(quiz.categoryName),
                        backgroundColor: colorScheme.primaryContainer,
                        labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Título
                  Text(
                    quiz.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Autor y Fecha
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey.shade300,
                        child: Text(quiz.authorName.isNotEmpty ? quiz.authorName[0].toUpperCase() : "?"),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Creado por ${quiz.authorName}',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatDate(quiz.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Descripción
                  if (quiz.description.isNotEmpty) ...[
                    Text(
                      'Descripción',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      quiz.description,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Estadísticas
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          icon: Icons.play_circle_fill,
                          value: '${quiz.playCount}',
                          label: 'Jugadas',
                        ),
                        const _StatItem(icon: Icons.star, value: '4.8', label: 'Rating'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // BOTONES DE ACCIÓN
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        context.push('/library/singleplayer/$quizId');
                      },
                      icon: const Icon(Icons.person),
                      label: const Text('Práctica Individual', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.push('/hostGame/$quizId'); 
                      },
                      icon: const Icon(Icons.groups),
                      label: const Text('Crear Sala Multijugador'),
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey.shade700),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }
}