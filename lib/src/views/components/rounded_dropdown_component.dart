import 'package:flutter/material.dart';

import 'package:chore_champ_app/src/constants/app_colors.dart';

/// Dropdown genérico reutilizável com bordas arredondadas.
class RoundedDropdownComponent<T> extends StatelessWidget {
  const RoundedDropdownComponent({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.labelText,
    this.borderRadius = 12,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final String? labelText;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: hint != null ? Text(hint!) : null,
          isExpanded: true,
          borderRadius: BorderRadius.circular(borderRadius),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
