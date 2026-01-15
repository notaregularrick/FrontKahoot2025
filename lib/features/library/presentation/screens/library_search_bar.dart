import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

class LibrarySearchBar extends StatefulWidget {
  final Function(String) onSearch; // Callback cuando el usuario busca
  final TextEditingController controller;
  final EdgeInsetsGeometry padding;

  const LibrarySearchBar({
    super.key,
    required this.onSearch,
    required this.controller,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  });

  @override
  State<LibrarySearchBar> createState() => _LibrarySearchBarState();
}

class _LibrarySearchBarState extends State<LibrarySearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: Material(
        elevation: 6,
        shadowColor: AppColors.primaryRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        child: TextField(
          controller: widget.controller,
          style: const TextStyle(color: Colors.black),
          onSubmitted: (value) {
            widget.onSearch(value);
          },
          decoration: InputDecoration(
            hintText: "Buscar...",
            hintStyle: TextStyle(color: Colors.grey.shade500),
            filled: true,
            fillColor: AppColors.softPink,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.primaryRed,
              weight: 2.0,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                color: AppColors.darkBlueText.withOpacity(0.8),
                weight: 2.0,
              ),
              onPressed: () {
                widget.controller.clear();
                FocusManager.instance.primaryFocus?.unfocus();
                widget.onSearch('');
              },
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: AppColors.primaryRed, width: 1.4),
            ),
          ),
        ),
      ),
    );
  }
}
