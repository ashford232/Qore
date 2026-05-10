import 'package:animate_do/animate_do.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study/data/db/db_providers.dart';
import 'package:study/features/library/widgets/library_widgets.dart';

class Search extends ConsumerStatefulWidget {
  const Search({super.key});

  @override
  ConsumerState<Search> createState() => _SearchState();
}

class _SearchState extends ConsumerState<Search> {
  final serachController = TextEditingController();

  @override
  void initState() {
    super.initState();
    serachController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    serachController.dispose();
    super.dispose();
  }

  String filterType = "all";
  @override
  Widget build(BuildContext context) {
    final searchProvider = ref.watch(
      qoreSearchProvider(serachController.text.trim()),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(FluentIcons.chevron_left_24_filled),
        ),
        title: TextField(
          controller: serachController,
          keyboardType: TextInputType.webSearch,
          autofocus: true,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {});
            }
          },
          onChanged: (value) {
            if (value.isNotEmpty) {
              setState(() {});
            }
          },
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
          },
          decoration: InputDecoration(
            hintText: "Search",
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (serachController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                serachController.clear();
              },
              child: FadeIn(
                duration: Duration(milliseconds: 200),
                child: Icon(FluentIcons.dismiss_20_filled),
              ),
            ),

          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: searchProvider.when(
          data: (res) {
            if (serachController.text.isEmpty) {
              return Center(
                child: EmptyLibraryView(
                  text: "Search something",
                  subText: "Type in the search bar to find what you need",
                ),
              );
            }
            if (res.isEmpty) {
              return Center(
                child: EmptyLibraryView(
                  text: "No results found",

                  subText: "Try searching for something else",
                ),
              );
            }
            return BuildContentLayout(qores: res);
          },
          loading: () => Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 1,
              ),
            ),
          ),
          error: (error, stack) => Center(child: Text(error.toString())),
        ),
      ),
    );
  }
}
