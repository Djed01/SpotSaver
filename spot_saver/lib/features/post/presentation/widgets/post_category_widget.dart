import 'package:spot_saver/core/constants/constants.dart';
import 'package:spot_saver/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class PostCategoryWidget extends StatefulWidget {
  final List<String> selectedCategories;
  final Function(String) onCategorySelected;
  final Function(String) onCategoryDeselected;
  const PostCategoryWidget({
    super.key,
    required this.selectedCategories,
    required this.onCategorySelected,
    required this.onCategoryDeselected,
  });

  @override
  State<PostCategoryWidget> createState() => _PostCategoryWidgetState();
}

class _PostCategoryWidgetState extends State<PostCategoryWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: Constants.categories
            .map(
              (e) => Padding(
                padding: const EdgeInsets.all(5.0),
                child: GestureDetector(
                  onTap: () {
                    if (widget.selectedCategories.contains(e)) {
                      widget.onCategoryDeselected(e);
                    } else {
                      widget.onCategorySelected(e);
                    }
                    setState(() {});
                  },
                  child: Chip(
                    color: widget.selectedCategories.contains(e)
                        ? const WidgetStatePropertyAll(AppPallete.gradient1)
                        : null,
                    label: Text(e),
                    side: widget.selectedCategories.contains(e)
                        ? null
                        : const BorderSide(color: AppPallete.borderColor),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
