import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/library/presentation/providers/library_notifier.dart';
import 'package:frontkahoot2526/features/library/presentation/screens/pagination_control_widget.dart';
import 'package:frontkahoot2526/features/library/presentation/screens/quiz_card_widget.dart';
import 'package:frontkahoot2526/features/library/presentation/screens/quiz_options_widget.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const List<Tab> _tabs = <Tab>[
    Tab(text: 'Mis quices'),
    Tab(text: 'Favoritos'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _tabs.length);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _onTabChanged(_tabController.index);
      }
    });
  }

  void _onTabChanged(int index) {
    final notifier = ref.read(asyncLibraryProvider.notifier);
    switch (index) {
      case 0:
        notifier.loadMyCreations();
        break;
      case 1:
        notifier.loadFavorites();
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(asyncLibraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Biblioteca"),
        backgroundColor: Color.fromARGB(255, 244, 67, 54),
        foregroundColor: Colors.white,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // scroll horizontal
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _tabs,
        ),
      ),
      body: notifier.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stackTrace) {
          if(error is AppException){
            return Center(child: Text("Error: ${error.message} (Code: ${error.statusCode}), Details: ${error.error}"));
          }
          return Center(child: Text("Unexpected error: $error"));
        },

        data: (notifierState) {
          final quizList = notifierState.quizList;
          if (quizList.isEmpty) {
            return const Center(child: Text("No hay quices disponibles."));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: quizList.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final quizUiModel = quizList[index];
                    return QuizCard(
                      quiz: quizUiModel,
                      onTap: () {
                        QuizContextType contextType;
                        switch (_tabController.index) {
                          case 0:
                            contextType = QuizContextType.myCreations;
                            break;
                          case 1:
                            contextType = QuizContextType.favorites;
                            break;
                          default:
                            contextType = QuizContextType.myCreations;
                            break;
                        }
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return QuizOptionsSheet(
                              quiz: quizUiModel,
                              type: contextType,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              PaginationControls(
                currentPage: notifierState.currentPage,
                totalPages: notifierState.totalPages,
                onPageChanged: (newPage) {
                  ref.read(asyncLibraryProvider.notifier).changePage(newPage);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
