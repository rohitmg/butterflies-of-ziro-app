// lib/features/explore/widgets/taxonomy_tree_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:butterflies_of_ziro/data/models/taxonomy_node.dart';
import 'package:butterflies_of_ziro/providers/filter_state.dart';
import 'package:butterflies_of_ziro/core/app_colors.dart';

// --- CONSTANTS ---
const double _treeNodeIconSize = 16.0;
const double _treeNodeIconWidth = 40.0;
const double _treeNodeRowHeight = 40.0;
const double _treeNodeIndentation = 16.0;

class TaxonomyTreeSelector extends ConsumerStatefulWidget {
  final TaxonomyNode currentNode;
  final FilterState localFilters;
  final Function(FilterState) onFiltersUpdated;
  final ValueNotifier<String?> selectedNodeNameNotifier;
  final int level;
  final Color baseColor;

  const TaxonomyTreeSelector({
    super.key,
    required this.currentNode,
    required this.localFilters,
    required this.onFiltersUpdated,
    required this.selectedNodeNameNotifier,
    this.level = 0,
    required this.baseColor,
  });

  @override
  ConsumerState<TaxonomyTreeSelector> createState() =>
      _TaxonomyTreeSelectorState();
}

class _TaxonomyTreeSelectorState extends ConsumerState<TaxonomyTreeSelector> {
  final Set<String> _expandedNodes = {};

  @override
  void initState() {
    super.initState();
    // Initialize expansion state only on the root element
    if (widget.level == 0) {
      _initializeExpansion();
    }
  }

  void _initializeExpansion() {
    // Logic to automatically expand the path to the currently selected filter
    _expandedNodes.clear();
    List<String> path = [];
    if (widget.localFilters.family != null) {
      path.add(widget.localFilters.family!);
      if (widget.localFilters.subfamily != null) {
        path.add(widget.localFilters.subfamily!);
        if (widget.localFilters.tribe != null) {
          path.add(widget.localFilters.tribe!);
          if (widget.localFilters.genus != null) {
            path.add(widget.localFilters.genus!);
          }
        }
      }
    }
    setState(() {
      _expandedNodes.addAll(path);
      if (widget.currentNode.level == 'Root') {
        _expandedNodes.add(widget.currentNode.name);
      }
    });
  }

  void _selectNode(TaxonomyNode? node) {
    FilterState newFilters = widget.localFilters;
    String? nodeName = node?.name;

    // 1. Determine the NEW FilterState based on the selected node
    if (node == null || node.level == 'Root') {
      newFilters = const FilterState();
      nodeName = 'Papilionoidea';
    } else {
      // Create a fresh filter state to avoid accidental inheritance
      newFilters = const FilterState();

      switch (node.level) {
        case 'Family':
          newFilters = newFilters.copyWith(family: node.name);
          break;
        case 'Subfamily':
          newFilters = newFilters.copyWith(subfamily: node.name);
          break;
        case 'Tribe':
          newFilters = newFilters.copyWith(tribe: node.name);
          break;
        case 'Genus':
          newFilters = newFilters.copyWith(genus: node.name);
          break;
      }
    }

    // 2. Update the external (dialog) state and notifier
    widget.onFiltersUpdated(newFilters);
    widget.selectedNodeNameNotifier.value = nodeName;
  }

  void _toggleExpansion(String nodeName) {
    setState(() {
      if (_expandedNodes.contains(nodeName)) {
        _expandedNodes.remove(nodeName);
      } else {
        _expandedNodes.add(nodeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentNode.children.isEmpty && widget.level > 0) {
      return const SizedBox.shrink();
    }

    final List<TaxonomyNode> nodesToDisplay = [
      if (widget.level == 0)
        TaxonomyNode(
          name: 'Papilionoidea',
          level: 'Root',
          children: widget.currentNode.children,
        ),
      ...widget.currentNode.children,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: nodesToDisplay.map((node) {
        final isExpanded = _expandedNodes.contains(node.name);
        final hasSubChildren = node.children.isNotEmpty;

        // Determine the color for the next level's children
        final Color nextLevelColor = node.level == 'Family'
            ? butterflyFamilyMap[node.name]?.base ?? Colors.black
            : widget.baseColor;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Node Tile ---
            _buildNodeTile(
              context,
              node,
              widget.baseColor,
              onTap: (selectedNode) {
                // Tapping selects the node
                if (widget.selectedNodeNameNotifier.value ==
                    selectedNode.name) {
                  _selectNode(null); // Deselect
                } else {
                  _selectNode(selectedNode);
                }
              },
              onExpand: hasSubChildren
                  ? () => _toggleExpansion(node.name)
                  : null,
              hasChildren: hasSubChildren,
            ),

            // --- Recursive Children Container ---
            if (hasSubChildren && isExpanded)
              Padding(
                padding: EdgeInsets
                    .zero, // Padding is handled internally by the child widget's level
                child: TaxonomyTreeSelector(
                  currentNode: node,
                  localFilters: widget.localFilters,
                  onFiltersUpdated: widget.onFiltersUpdated,
                  level: widget.level + 1,
                  baseColor: nextLevelColor, // Pass the color down
                  selectedNodeNameNotifier: widget.selectedNodeNameNotifier,
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildNodeTile(
    BuildContext context,
    TaxonomyNode node,
    Color textColor, {
    required Function(TaxonomyNode) onTap,
    required Function()? onExpand,
    required bool hasChildren,
  }) {
    final isSelected = node.name == widget.selectedNodeNameNotifier.value;
    final isExpanded = _expandedNodes.contains(node.name);

    return InkWell(
      onTap: () => onTap(node),
      child: Container(
        height: _treeNodeRowHeight,
        color: isSelected ? textColor.withOpacity(0.15) : null,
        padding: EdgeInsets.only(left: _treeNodeIndentation * widget.level),
        child: Row(
          children: [
            // ICON/EXPAND BUTTON (Fixed Width)
            SizedBox(
              width: _treeNodeIconWidth,
              height: _treeNodeRowHeight,
              child: Center(
                child: onExpand != null
                    ? Container(
                        // Subtle background circle
                        width: _treeNodeIconWidth * 0.7,
                        height: _treeNodeIconWidth * 0.7,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isExpanded ? Icons.remove : Icons.add,
                            color: Colors.grey.shade700,
                            size: _treeNodeIconSize,
                          ),
                          onPressed: onExpand,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints.tightFor(
                            width: _treeNodeIconWidth * 0.7,
                            height: _treeNodeIconWidth * 0.7,
                          ),
                        ),
                      )
                    : SizedBox(
                        width: _treeNodeIconWidth,
                        height: _treeNodeRowHeight,
                      ), // Placeholder
              ),
            ),

            // TEXT
            Expanded(
              child: Text(
                node.name,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
