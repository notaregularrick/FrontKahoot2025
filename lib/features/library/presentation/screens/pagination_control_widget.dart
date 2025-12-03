import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFirstPage = currentPage <= 1;
    final bool isLastPage = currentPage >= totalPages;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: isFirstPage 
                ? null 
                : () => onPageChanged(currentPage - 1),
            color: AppColors.darkBlueText,
            disabledColor: AppColors.darkBlueText.withOpacity(0.3),
            iconSize: 30,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$currentPage / $totalPages',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlueText,
                fontSize: 20,
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: isLastPage 
                ? null 
                : () => onPageChanged(currentPage + 1),
            color: AppColors.darkBlueText,
            disabledColor: AppColors.darkBlueText.withOpacity(0.3),
            iconSize: 30,
          ),
        ],
      ),
    );
  }
}