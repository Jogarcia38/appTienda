import 'package:flutter/material.dart';
import '../models/category.dart';

class StoreFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const StoreFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF243044),
          fontWeight: FontWeight.w600,
        ),
        selectedColor: primary,
        backgroundColor: Colors.white,
        side: BorderSide(color: isSelected ? primary : const Color(0xFFD5DBE5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StoreFilterChip(
      label: category.name,
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}
