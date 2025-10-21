// lib/features/explore/widgets/filter_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:butterflies_of_ziro/providers/filter_provider.dart';
import 'package:butterflies_of_ziro/providers/filter_state.dart';
import 'package:butterflies_of_ziro/providers/taxonomy_provider.dart';
import 'package:butterflies_of_ziro/features/explore/widgets/taxonomy_tree_selector.dart';
import 'package:butterflies_of_ziro/core/app_colors.dart';
import 'package:butterflies_of_ziro/core/constants.dart';

void showFilterDialog({
  required BuildContext context,
  required WidgetRef ref,
  required ViewType currentViewType, // Correctly use the enum
  required Function(ViewType) onViewChanged, // Correctly use the enum
}) {
  FilterState localFilters = ref.read(filterProvider);
  final taxonomyTree = ref.read(taxonomyProvider);

  // Create a ValueNotifier to manage the selected node's name
  final selectedNodeNameNotifier = ValueNotifier<String?>(localFilters.family);
  ViewType _localViewType = currentViewType;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext dialogContext, StateSetter setState) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'View as:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ToggleButtons(
                    isSelected: ViewType.values
                        .map((type) => type == _localViewType)
                        .toList(),
                    onPressed: (index) {
                      setState(() {
                        _localViewType = ViewType.values[index];
                      });
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.grid_view),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.list),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.photo_library_outlined),
                      ), // Light Box Icon
                    ],
                  ),
                  const Divider(),
                  const Text(
                    'Taxonomy Filter:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: SingleChildScrollView(
                      child: TaxonomyTreeSelector(
                        currentNode: taxonomyTree,
                        localFilters: localFilters,
                        onFiltersUpdated: (newFilters) {
                          setState(() {
                            localFilters = newFilters;
                          });
                        },
                        // Pass the local ValueNotifier down to the tree selector
                        selectedNodeNameNotifier: selectedNodeNameNotifier,
                        baseColor: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Clear the local state and the ValueNotifier
                          selectedNodeNameNotifier.value = null;
                          setState(() {
                            localFilters = const FilterState();
                          });
                        },
                        child: const Text('Clear'),
                      ),
                      TextButton(
                        onPressed: () {
                          onViewChanged(_localViewType);
                          ref
                              .read(filterProvider.notifier)
                              .updateFromState(localFilters);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildViewButton(
  BuildContext context,
  IconData icon,
  ViewType viewType, // Use the new enum
  ViewType currentView, // Use the new enum
  Function(ViewType) onChanged, // Use the new enum
) {
  return Expanded(
    child: Container(
      decoration: BoxDecoration(
        color: currentView == viewType
            ? Theme.of(context).primaryColor.withOpacity(0.2)
            : null,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: () {
          onChanged(viewType);
        },
      ),
    ),
  );
}
