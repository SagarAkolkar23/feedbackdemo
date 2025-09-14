import 'package:feedbackdemo/features/details/presentation/provider/entityProvider.dart';
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
  final List<String> allTags = [
    "Dangerous",
    "Accident Risk",
    "Tag 1",
    "Tag 2",
    "Tag 3",
    "Alert",
    "Sad",
    "Painful",
    "Tag 4",
    "Tag 5",
    "Unsafe",
  ];

  final List<String> selectedTags = [];

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
  Widget build(BuildContext context) {
    final entityAsync = ref.watch(entityControllerProvider);
    final tagState = ref.watch(tagControllerProvider);

    final entity = entityAsync.value;
    final isButtonEnabled = selectedTags.isNotEmpty && entity != null;

    ref.listen(tagControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          selectedTags.clear();
          context.go("/get-otp");
        },
      );
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        return Scaffold(
          body: isWide
              ? Row(
                  children: [
                    Expanded(flex: 1, child: _buildLeftImage()),
                    Expanded(
                      flex: 1,
                      child: _buildRightPanel(
                        tagState,
                        entity,
                        isButtonEnabled,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    SizedBox(height: 200, child: _buildLeftImage()),
                    Expanded(
                      child: _buildRightPanel(
                        tagState,
                        entity,
                        isButtonEnabled,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  /// ✅ FIX: Return Container instead of Expanded
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

  /// ✅ Added proper typing for clarity
  Widget _buildRightPanel(
    AsyncValue tagState,
    dynamic entity,
    bool isButtonEnabled,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          // ✅ Transparent bar for selected tags
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
                    ? [
                        const Text(
                          "No tags selected yet",
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                      ]
                    : selectedTags.map((tag) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            label: Text(tag),
                            backgroundColor: Colors.blue.shade100,
                            labelStyle: const TextStyle(color: Colors.blue),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () => toggleTag(tag),
                          ),
                        );
                      }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ✅ Tags list
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: allTags.map((tag) {
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
                    shape: StadiumBorder(side: BorderSide(color: Colors.blue)),
                    onSelected: (_) => toggleTag(tag),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ✅ Safe null check for entity
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
