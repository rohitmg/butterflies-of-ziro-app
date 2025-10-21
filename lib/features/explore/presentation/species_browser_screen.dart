// lib/features/explore/presentation/species_browser_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import 'package:butterflies_of_ziro/data/models/species_model.dart';
import 'package:butterflies_of_ziro/core/app_colors.dart';
import 'package:butterflies_of_ziro/features/explore/widgets/browser_viewer.dart';
import 'package:butterflies_of_ziro/features/explore/widgets/browser_details_panel.dart';
import 'package:butterflies_of_ziro/features/explore/widgets/browser_thumbnail_bar.dart';

class SpeciesBrowserScreen extends StatefulWidget {
  final List<SpeciesModel> speciesList;

  const SpeciesBrowserScreen({super.key, required this.speciesList});

  @override
  State<SpeciesBrowserScreen> createState() => _SpeciesBrowserScreenState();
}

class _SpeciesBrowserScreenState extends State<SpeciesBrowserScreen> {
  // --- Main State Management ---
  late TransformationController _transformationController;
  int _currentIndex = 0;
  bool _isZoomed = false;
  late ScrollController _thumbnailScrollController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _thumbnailScrollController = ScrollController();
    _transformationController.addListener(_handleZoomChange);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_handleZoomChange);
    _transformationController.dispose();
    _thumbnailScrollController.dispose();
    super.dispose();
  }

  void _handleZoomChange() {
    final isScaled = _transformationController.value.getMaxScaleOnAxis() > 1.05;
    if (_isZoomed != isScaled) {
      setState(() {
        _isZoomed = isScaled;
      });
    }
  }

  void _resetImageZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _setSpeciesIndex(int index) {
    if (index.clamp(0, widget.speciesList.length - 1) == index &&
        _currentIndex != index) {
      setState(() {
        _currentIndex = index;
        _resetImageZoom();
      });
    }
  }

  void _scrollToCurrentThumbnail() {
    if (!_thumbnailScrollController.hasClients) return;

    const double thumbnailWidth = 60.0 + 8.0;
    final double targetOffset =
        _currentIndex * thumbnailWidth -
        (MediaQuery.of(context).size.width / 2) +
        (thumbnailWidth / 2);

    _thumbnailScrollController.animateTo(
      targetOffset.clamp(
        0.0,
        _thumbnailScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSpecies = widget.speciesList[_currentIndex];
    final familyColor =
        butterflyFamilyMap[currentSpecies.family]?.base ?? Colors.grey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentThumbnail();
    });

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. THUMBNAIL CAROUSEL AND NAVIGATION
          BrowserThumbnailBar(
            speciesList: widget.speciesList,
            currentIndex: _currentIndex,
            onIndexChanged: _setSpeciesIndex,
            familyColor: familyColor,
            scrollController: _thumbnailScrollController,
          ),

          // 2. INTERACTIVE IMAGE VIEWER
          BrowserImageViewer(
            species: currentSpecies,
            transformationController: _transformationController,
            isZoomed: _isZoomed,
            onResetZoom: _resetImageZoom,
          ),

          // 3. DETAILS AND RAW DATA PANEL (Corrected Prop Passing)
          BrowserDetailsPanel(
            species: currentSpecies,
            familyColor: familyColor,
            speciesList: widget.speciesList,
            currentIndex: _currentIndex,
            onIndexChanged: _setSpeciesIndex,
            // The rest of the details panel helpers were defined in the original monolith.
            // Since they are now in the panel widget itself, we don't need to pass them.
          ),
        ],
      ),
    );
  }
}