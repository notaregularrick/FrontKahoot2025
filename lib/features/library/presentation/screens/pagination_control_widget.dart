import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  // Esta función avisa al padre (la pantalla) que el usuario quiere cambiar de página
  final Function(int) onPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    //final theme = Theme.of(context);
    final bool isFirstPage = currentPage <= 1;
    final bool isLastPage = currentPage >= totalPages;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- BOTÓN ANTERIOR ---
          IconButton(
            icon: const Icon(Icons.chevron_left),
            // Si es la primera página, deshabilitamos el botón (null)
            onPressed: isFirstPage 
                ? null 
                : () => onPageChanged(currentPage - 1),
            color: Colors.lightBlue[300],
            disabledColor: Colors.grey[300],
          ),

          // --- INDICADOR DE PÁGINA (Ej: "1 / 5") ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$currentPage / $totalPages',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),

          // --- BOTÓN SIGUIENTE ---
          IconButton(
            icon: const Icon(Icons.chevron_right),
            // Si es la última página, deshabilitamos el botón
            onPressed: isLastPage 
                ? null 
                : () => onPageChanged(currentPage + 1),
            color: Colors.lightBlue[300],
            disabledColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}