// lib/features/species_details/presentation/species_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:butterflies_of_ziro/data/models/species_model.dart';
import 'package:butterflies_of_ziro/core/app_colors.dart';
import 'package:butterflies_of_ziro/features/explore/widgets/browser_viewer.dart';

class SpeciesDetailScreen extends StatefulWidget {
  final List<SpeciesModel> speciesList;
  final int initialIndex;

  const SpeciesDetailScreen({
    super.key,
    required this.speciesList,
    required this.initialIndex,
  });

  @override
  State<SpeciesDetailScreen> createState() => _SpeciesDetailScreenState();
}

class _SpeciesDetailScreenState extends State<SpeciesDetailScreen> {
  late int _currentIndex;
  late TransformationController _transformationController;
  late ScrollController _thumbnailScrollController;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
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

  // ---- HANDLERS ----

  void _handleZoomChange() {
    final isScaled = _transformationController.value.getMaxScaleOnAxis() > 1.05;
    if (isScaled != _isZoomed) {
      setState(() => _isZoomed = isScaled);
    }
  }

  void _resetImageZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _setSpeciesIndex(int newIndex) {
    if (newIndex.clamp(0, widget.speciesList.length - 1) == newIndex &&
        newIndex != _currentIndex) {
      setState(() {
        _currentIndex = newIndex;
        _resetImageZoom();
      });
    }
  }

  // ---- BUILD ----

  @override
  Widget build(BuildContext context) {
    final currentSpecies = widget.speciesList[_currentIndex];
    final familyColor =
        butterflyFamilyMap[currentSpecies.family]?.base ?? Colors.grey;

    // Because images are 1200x800 (3:2), we can maintain this aspect ratio.
    final mediaQuery = MediaQuery.of(context);
    final imageWidth = mediaQuery.size.width;
    final imageHeight = imageWidth * (2 / 3); // 3:2 aspect ratio

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- IMAGE AREA ----
            SizedBox(
              width: imageWidth,
              height: imageHeight,
              child: BrowserImageViewer(
                species: currentSpecies,
                transformationController: _transformationController,
                isZoomed: _isZoomed,
                onResetZoom: _resetImageZoom,
                // fit: BoxFit.contain, // ensure full image visible, no cropping
              ),
            ),

            // ---- NAVIGATION BAR ----
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: familyColor.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(color: familyColor.withOpacity(0.3)),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Previous Button (fixed width for symmetry)
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _currentIndex > 0
                          ? () => _setSpeciesIndex(_currentIndex - 1)
                          : null,
                      color: _currentIndex > 0
                          ? familyColor
                          : Colors.grey.shade400,
                    ),
                  ),

                  // --- Names Stack (Flex column) ---
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Common Name (prominent)
                          Text(
                            currentSpecies.commonName,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: familyColor,
                                ),
                          ),

                          // Scientific Name (italic, subdued)
                          Text(
                            currentSpecies.scientificName,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black87,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Next Button (fixed width for symmetry)
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _currentIndex < widget.speciesList.length - 1
                          ? () => _setSpeciesIndex(_currentIndex + 1)
                          : null,
                      color: _currentIndex < widget.speciesList.length - 1
                          ? familyColor
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),

            // ---- DETAILS AREA ----
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    _buildSectionTitle(context, 'Taxonomy', familyColor),
                    _buildTaxonomyTable(context, currentSpecies),
                    const SizedBox(height: 20),

                    _buildSectionTitle(
                      context,
                      'Habitat & Ecology',
                      familyColor,
                    ),
                    _buildDetailRow(context, 'Habitat', currentSpecies.habitat),
                    _buildDetailRow(
                      context,
                      'Altitude',
                      currentSpecies.altitude,
                    ),
                    _buildDetailRow(context, 'Season', currentSpecies.season),
                    const SizedBox(height: 20),

                    _buildSectionTitle(context, 'Description', familyColor),
                    Text(
                      currentSpecies.description ??
                          'No detailed description available.',
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 20),

                    _buildSectionTitle(context, 'Host Plants', familyColor),
                    Text(
                      currentSpecies.hostPlants ?? 'Data unavailable.',
                      style: const TextStyle(fontSize: 15),
                    ),

                    const SizedBox(height: 60), // bottom scroll buffer
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- HELPERS ----

  Widget _buildSectionTitle(BuildContext context, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A', style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxonomyTable(BuildContext context, SpeciesModel species) {
    return Column(
      children: [
        _buildDetailRow(context, 'Family', species.family),
        _buildDetailRow(context, 'Subfamily', species.subfamily),
        _buildDetailRow(context, 'Tribe', species.tribe),
        _buildDetailRow(context, 'Genus', species.genus),
      ],
    );
  }
}
