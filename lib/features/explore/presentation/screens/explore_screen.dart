import 'dart:async'; // Para el Timer (Debounce)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/explore_providers.dart';
import '../widgets/quiz_card.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exploreNotifierProvider.notifier).loadQuizzes();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Lógica para detectar fin de lista
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(exploreNotifierProvider.notifier).loadQuizzes(isLoadMore: true);
    }
  }

  // Lógica de búsqueda con retraso (Debounce)
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(exploreNotifierProvider.notifier).onSearchChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exploreNotifierProvider);
    final notifier = ref.read(exploreNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Descubrir'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- BARRA DE BÚSQUEDA ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar kahoots...',
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
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),

          // --- CONTENIDO PRINCIPAL ---
          Expanded(
            child: state.isLoading && state.quizzes.isEmpty
                ? const Center(child: CircularProgressIndicator()) // Carga inicial
                : state.errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Ocurrió un error: ${state.errorMessage}'),
                            TextButton(
                              onPressed: notifier.refresh,
                              child: const Text('Reintentar'),
                            )
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: notifier.refresh,
                        child: state.quizzes.isEmpty
                            ? ListView(
                                children: const [
                                  SizedBox(height: 100),
                                  Center(child: Text("No se encontraron resultados")),
                                ],
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: state.quizzes.length + (state.hasMoreData ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == state.quizzes.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                    );
                                  }

                                  final quiz = state.quizzes[index];
                                  return QuizCard(
                                    quiz: quiz,
                                    onTap: () {
                                      context.push('/quiz/${quiz.id}');
                                    },
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }
}