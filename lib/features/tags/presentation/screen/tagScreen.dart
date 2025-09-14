import 'package:feedbackdemo/features/details/presentation/provider/entityProvider.dart';
import 'package:feedbackdemo/features/tags/presentation/provider/getTagProvider.dart';
import 'package:feedbackdemo/features/tags/presentation/provider/tagsProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TagSelectionPage extends ConsumerStatefulWidget {
  const TagSelectionPage({super.key});

  @override
  ConsumerState<TagSelectionPage> createState() => _TagSelectionPageState();
}

class _TagSelectionPageState extends ConsumerState<TagSelectionPage> {
  final List<String> selectedTags = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void toggleTag(String tag) {
    setState(() {
      if (selectedTags.contains(tag)) {
        selectedTags.remove(tag);
      } else {
        selectedTags.add(tag);
      }
    });
  }

  void _submitTags(String token) async {
    if (selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one tag.")),
      );
      return;
    }

    await ref
        .read(tagControllerProvider.notifier)
        .submitTags(selectedTags, token);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entityAsync = ref.watch(entityControllerProvider);
    final tagState = ref.watch(tagControllerProvider);
    final entity = entityAsync.value;
    final isButtonEnabled = selectedTags.isNotEmpty && entity != null;

    // Listen for successful tag submission
    ref.listen(tagControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          selectedTags.clear();
          context.go("/get-otp");
        },
      );
    });

    // Fetch tags from backend
    final tagsAsync = entity != null
        ? ref.watch(allTagsProvider(entity.token))
        : AsyncValue.data(<String>[]);

    final screenWidth = MediaQuery.of(context).size.width;
    final showImage = screenWidth > 600; // hide image on small screens

    return Scaffold(
      body: showImage
          ? Row(
              children: [
                Expanded(flex: 1, child: _buildLeftImage()),
                Expanded(
                  flex: 1,
                  child: _buildRightPanel(
                    tagState,
                    entity,
                    isButtonEnabled,
                    tagsAsync,
                  ),
                ),
              ],
            )
          : _buildRightPanel(tagState, entity, isButtonEnabled, tagsAsync),
    );
  }

  Widget _buildLeftImage() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/Image/sideImage.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(color: Colors.black.withOpacity(0.0)),
    );
  }

  Widget _buildRightPanel(
    AsyncValue tagState,
    dynamic entity,
    bool isButtonEnabled,
    AsyncValue<List<String>> tagsAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (MediaQuery.of(context).size.width > 600)
            Center(
              child: Image.asset(
                "assets/Image/Pictonion.png",
                height: 70,
                width: 300,
                fit: BoxFit.contain,
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            "Customize Your Feedback Tags",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            "Select relevant tags that define your services or areas of improvement. "
            "These tags will help users give quick and focused feedback.",
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Selected tags
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: selectedTags.isEmpty
                    ? const [
                        Text(
                          "No tags selected yet",
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                      ]
                    : selectedTags
                          .map(
                            (tag) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Chip(
                                label: Text(tag),
                                backgroundColor: Colors.blue.shade100,
                                labelStyle: const TextStyle(color: Colors.blue),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () => toggleTag(tag),
                              ),
                            ),
                          )
                          .toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search or add tags...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 16),

          // Tag list
          // Tag list
          Expanded(
            child: tagsAsync.when(
              data: (allTags) {
                final filteredTags = allTags
                    .where((tag) => tag.toLowerCase().contains(_searchQuery))
                    .toList();

                final canAddCustomTag =
                    _searchQuery.isNotEmpty &&
                    !allTags.map((e) => e.toLowerCase()).contains(_searchQuery);

                // Limit visible tags to 10
                final visibleTags = filteredTags.length > 10
                    ? filteredTags.sublist(0, 10)
                    : filteredTags;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: visibleTags.map((tag) {
                          final isSelected = selectedTags.contains(tag);
                          return ChoiceChip(
                            label: Text(tag),
                            selected: isSelected,
                            selectedColor: Colors.blue,
                            backgroundColor: Colors.transparent,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                            shape: StadiumBorder(
                              side: BorderSide(color: Colors.blue),
                            ),
                            onSelected: (_) => toggleTag(tag),
                          );
                        }).toList(),
                      ),
                      if (canAddCustomTag)
                        GestureDetector(
                          onTap: () {
                            final newTag = _searchController.text.trim();
                            if (newTag.isNotEmpty &&
                                !selectedTags.contains(newTag)) {
                              setState(() {
                                selectedTags.add(newTag);
                                _searchController.clear();
                                _searchQuery = "";
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Add '$_searchQuery' as a new tag",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      if (filteredTags.length > 10)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "+${filteredTags.length - 10} more...",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Text(
                "Error loading tags: $err",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Submit button
          tagState.when(
            data: (_) => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isButtonEnabled && entity != null
                    ? () => _submitTags(entity!.token)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.blue.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  "Save Tags & Continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) =>
                Text("Error: $err", style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
