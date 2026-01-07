import 'package:flutter/material.dart';

class GenreChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const GenreChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.orange.shade700 : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? Colors.orange.shade400 : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
