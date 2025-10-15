// lib/features/explore/widgets/filter_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:butterflies_of_ziro/providers/filter_provider.dart';
import 'package:butterflies_of_ziro/providers/filter_state.dart';
import 'package:butterflies_of_ziro/providers/taxonomy_provider.dart';
import 'package:butterflies_of_ziro/features/explore/widgets/taxonomy_tree_selector.dart';
import 'package:butterflies_of_ziro/core/app_colors.dart';

void showFilterDialog({
  required BuildContext context,
  required WidgetRef ref,
  required bool isGridView,
  required Function(bool) onViewChanged,
}) {
  final taxonomyTree = ref.read(taxonomyProvider);

  // Initialize local filter state once when the dialog opens
  FilterState localFilters = ref.read(filterProvider);
  final selectedNodeNameNotifier = ValueNotifier<String?>(
    localFilters.genus ??
        localFilters.tribe ??
        localFilters.subfamily ??
        localFilters.family ??
        'Papilionoidea',
  );

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
                  Row(
                    children: [
                      _buildViewButton(
                        context,
                        Icons.grid_view,
                        true,
                        isGridView,
                        (isGrid) => onViewChanged(isGrid),
                      ),
                      const SizedBox(width: 8),
                      _buildViewButton(
                        context,
                        Icons.list,
                        false,
                        isGridView,
                        (isGrid) => onViewChanged(isGrid),
                      ),
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
                        selectedNodeNameNotifier: selectedNodeNameNotifier,
                        localFilters: localFilters,
                        onFiltersUpdated: (newFilters) {
                          setState(() {
                            localFilters = newFilters;
                          });
                        },
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
                          setState(() {
                            localFilters = const FilterState();
                            selectedNodeNameNotifier.value = null;
                          });
                        },
                        child: const Text('Clear'),
                      ),
                      TextButton(
                        onPressed: () {
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
  bool isGrid,
  bool currentView,
  Function(bool) onChanged,
) {
  return Expanded(
    child: Container(
      decoration: BoxDecoration(
        color: currentView == isGrid
            ? Theme.of(context).primaryColor.withOpacity(0.2)
            : null,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: () {
          onChanged(isGrid);
        },
      ),
    ),
  );
}
