import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:study/data/dummy.dart';

PaintingEffect shimmerEffect(BuildContext context) {
  final theme = Theme.of(context);
  return ShimmerEffect(
    baseColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
    highlightColor: theme.colorScheme.onSurface.withValues(alpha: 0.2),
  );
}

Widget questionSkeleton(BuildContext context, {required bool isGrid}) {
  final theme = Theme.of(context);
  return Skeletonizer(
    effect: shimmerEffect(context),
    enabled: true,
    child: isGrid
        ? GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHigh,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            FluentIcons.document_pdf_24_regular,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text("Source:"),
                        ],
                      ),

                      const SizedBox(height: 4),
                      Text(
                        Dummy.dummyText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "5 questions to skeleton",
                            style: theme.textTheme.labelSmall,
                          ),
                          Text("Date", style: theme.textTheme.labelSmall),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        : ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHigh,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            FluentIcons.document_pdf_24_regular,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text("Source:"),
                        ],
                      ),

                      const SizedBox(height: 4),
                      Text(
                        Dummy.dummyText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "5 questions to skeleton",
                            style: theme.textTheme.labelSmall,
                          ),
                          Text(
                            "5 questions to skeleton",
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
  );
}

List<Color> bgForWhiteText(BuildContext context, {bool showFirstColor = true}) {
  final theme = Theme.of(context);

  return [
    if (showFirstColor) theme.colorScheme.surface,

    Color(0xFF5C7FA3), // muted blue
    Color(0xFF6F8FAF), // soft sky
    Color(0xFF5F9E8F), // calm teal
    Color(0xFF6FAF8F), // soft green
    Color(0xFF8C7AA9), // muted purple
    Color(0xFF9A86B8), // lavender toned down
    Color(0xFFA87C7C), // soft red
    Color(0xFFB08D57), // muted orange/gold
    Color(0xFF8F9FA3), // calm gray-blue
    Color(0xFF7FAF9A), // soft mint
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
