import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

class LibrarySearchBar extends StatefulWidget {
  final Function(String) onSearch; // Callback cuando el usuario busca
  final TextEditingController controller;

  const LibrarySearchBar({
    super.key,
    required this.onSearch,
    required this.controller,
  });

  @override
  State<LibrarySearchBar> createState() => _LibrarySearchBarState();
}

class _LibrarySearchBarState extends State<LibrarySearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
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
          fillColor: Colors.white.withValues(alpha: 0.9),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 16,
          ),
          prefixIcon:  Icon(Icons.search, color: AppColors.darkBlueText.withValues(alpha: 0.8), weight: 2.0,),

          suffixIcon: IconButton(
            icon:  Icon(Icons.clear, color: AppColors.darkBlueText.withValues(alpha: 0.8), weight: 2.0,),
            onPressed: () {
              widget.controller.clear();
              FocusManager.instance.primaryFocus?.unfocus();
              widget.onSearch('');
            },
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
