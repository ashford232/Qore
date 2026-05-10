import 'package:flutter/material.dart';

List<Color> bgForWhiteText(BuildContext context, {bool showFirstColor = true}) {
  final theme = Theme.of(context);

  return [
    if (showFirstColor) theme.colorScheme.surface,

    Color(0xFF5C7FA3),
    Color(0xFF6F8FAF),
    Color(0xFF5F9E8F),
    Color(0xFF6FAF8F),
    Color(0xFF8C7AA9),
    Color(0xFF9A86B8),
    Color(0xFFA87C7C),
    Color(0xFFB08D57),
    Color(0xFF8F9FA3),
    Color(0xFF7FAF9A),
  ];
}

List<Color> bgForBlackText(BuildContext context, {bool showFirstColor = true}) {
  final theme = Theme.of(context);
  return [
    if (showFirstColor) theme.colorScheme.surface,

    Color(0xFFFDEDEC),
    Color(0xFFEBF5FB),
    Color(0xFFE8F8F5),
    Color(0xFFEAFAF1),
    Color(0xFFFCF3CF),
    Color(0xFFF6DDCC),
    Color(0xFFF5EEF8),
    Color(0xFFFEF9E7),
    Color(0xFFF4F6F7),
    Color(0xFFFFF5E1),
  ];
}

class BuildTags extends StatelessWidget {
  const BuildTags({super.key, required this.tags, this.limit});

  final List<String> tags;
  final int? limit;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...List.generate(limit ?? tags.length, (index) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Text(
              "#${tags[index]}",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          );
        }),
      ],
    );
  }
}
