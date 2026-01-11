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
      ref.read(exploreNotifierProvider.notifier).loadInitialData(); //Carga en paralelo
    });
    _scrollController.addListener(_onScroll); //Paginacion Infinita
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  //Paginacion inf
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(exploreNotifierProvider.notifier).loadQuizzes(isLoadMore: true);
    }
  }
  //Debounce
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.refresh,
          )
        ],
      ),
      body: Column(
        children: [
          // 1. BARRA DE BÚSQUEDA
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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

          // 2. FILTROS DE CATEGORÍAS (Horizontal Chips)
          // Solo mostramos si hay categorías cargadas
          if (state.availableCategories.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.availableCategories.length,
                separatorBuilder: (c, i) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = state.availableCategories[index];
                  final isSelected = state.selectedCategory == category.id;
                  
                  return FilterChip(
                    label: Text(category.name),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      notifier.onCategorySelected(category.id);
                    },
                    selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                  );
                },
              ),
            ),

          const SizedBox(height: 8),

          // 3. CONTENIDO PRINCIPAL (Listas)
          Expanded(
            child: state.isLoading && state.quizzes.isEmpty && state.featuredQuizzes.isEmpty
                ? const Center(child: CircularProgressIndicator())
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
                        child: ListView(
                          controller: _scrollController, //Paginacion Infinita
                          padding: const EdgeInsets.only(bottom: 20),
                          children: [
                            
                            // A. SECCIÓN DESTACADOS (Solo si no hay filtros activos)
                            if (state.searchQuery.isEmpty && state.selectedCategory == null && state.featuredQuizzes.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Text(
                                  "Destacados",
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                height: 300,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: state.featuredQuizzes.length,
                                  itemBuilder: (context, index) {
                                    final quiz = state.featuredQuizzes[index];
                                    return SizedBox(
                                      width: 280,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 12.0),
                                        child: QuizCard(
                                          quiz: quiz,
                                          isFeatured: true,
                                          onTap: () => context.push('/quiz/${quiz.id}'),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(),
                            ],

                            // B. LISTA GENERAL
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              child: Text(
                                state.searchQuery.isNotEmpty 
                                    ? "Resultados de búsqueda" 
                                    : state.selectedCategory != null 
                                        ? "Categoría: ${state.selectedCategory}"
                                        : "Explorar todos",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),

                            if (state.quizzes.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Center(child: Text("No se encontraron resultados")),
                              )
                            else
                              ...List.generate(state.quizzes.length, (index) {
                                final quiz = state.quizzes[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: QuizCard(
                                    quiz: quiz,
                                    onTap: () => context.push('/quiz/${quiz.id}'),
                                  ),
                                );
                              }),

                            if (state.hasMoreData && state.quizzes.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}