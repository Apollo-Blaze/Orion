// lib/components/search_bar.dart
import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode focusNode;
  final String hintText;
  final Function(String) onSearchQueryChanged;

  CustomSearchBar({
    required this.searchController,
    required this.focusNode,
    required this.hintText,
    required this.onSearchQueryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: TextField(
          controller: searchController,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.white54),
            filled: true,
            fillColor: const Color.fromARGB(113, 63, 63, 63),
            prefixIcon: focusNode.hasFocus
                ? IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      focusNode.unfocus();
                      searchController.clear();
                      onSearchQueryChanged(''); // Clear the search query
                    },
                  )
                : Icon(Icons.search, color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
            onSearchQueryChanged(value); // Notify parent screen of search query change
          },
          onTap: () {
            focusNode.requestFocus();
          },
        ),
      ),
    );
  }
}