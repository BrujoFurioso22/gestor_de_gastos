import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../constants/app_constants.dart';

class SearchInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onChanged;
  final VoidCallback? onClear;

  const SearchInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: HugeIcon(icon: HugeIconsStrokeRounded.search01, size: 20),
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: HugeIcon(icon: HugeIconsStrokeRounded.cancel01, size: 20),
                onPressed: () {
                  controller.clear();
                  onClear?.call();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      onChanged: (value) {
        onChanged?.call();
      },
    );
  }
}
