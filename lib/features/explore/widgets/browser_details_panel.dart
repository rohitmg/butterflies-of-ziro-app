// lib/features/explore/widgets/browser_details_panel.dart

import 'package:flutter/material.dart';
import 'package:butterflies_of_ziro/data/models/species_model.dart';
import 'package:butterflies_of_ziro/core/app_colors.dart';
import 'package:butterflies_of_ziro/features/explore/widgets/species_size_visualizer.dart';
import 'package:butterflies_of_ziro/features/explore/widgets/seasonal_clock.dart'; // Import the new widget

// --- MAIN WIDGET: BrowserDetailsPanel ---

class BrowserDetailsPanel extends StatelessWidget {
  final SpeciesModel species;
  final Color familyColor;
  
  // --- ADDED REQUIRED PROPERTIES ---
  final List<SpeciesModel> speciesList;
  final int currentIndex;
  final Function(int) onIndexChanged;
  // ---------------------------------

  const BrowserDetailsPanel({
    super.key,
    required this.species,
    required this.familyColor,
    required this.speciesList,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. NAMES AND NAVIGATION BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Button (Left)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                onPressed: currentIndex > 0
                    ? () => onIndexChanged(currentIndex - 1)
                    : null,
                color: familyColor,
              ),

              // Centered Names
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      species.commonName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: familyColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      species.scientificName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: familyColor.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Next Button (Right)
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 20),
                onPressed: currentIndex < speciesList.length - 1
                    ? () => onIndexChanged(currentIndex + 1)
                    : null,
                color: familyColor,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. TAXONOMY BREADCRUMBS
          const Text(
            'Taxonomy:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          _buildTaxonomyBreadcrumbs(species, familyColor),
          const SizedBox(height: 16),

          // 3. PHYSICAL & ENVIRONMENT DETAILS
          const Text(
            'Physical & Environment Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seasonal Clock (Using the new widget)
              SeasonalClock(
                seasonString: species.season ?? 'N/A',
                primaryColor: familyColor,
              ),
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Size Visualizer
                    SpeciesSizeVisualizer(
                      sizeRange: species.size ?? 'N/A',
                      primaryColor: familyColor,
                    ),
                    const SizedBox(height: 16),

                    // Detail Rows
                    _buildDetailRow('Habitat', species.habitat ?? 'N/A'),
                    _buildDetailRow('Altitude', species.altitude ?? 'N/A'),
                    _buildDetailRow('Season', species.season ?? 'N/A'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. DESCRIPTION AND HOST PLANTS
          const Text(
            'Description',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(species.description ?? 'No description available.'),

          const SizedBox(height: 16),
          const Text(
            'Host Plants',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(species.hostPlants ?? 'No data available.'),
        ],
      ),
    );
  }

  // --- HELPER BUILD METHODS (Required here, not the Clock or Painter) ---

  Widget _buildTaxonomyBreadcrumbs(SpeciesModel species, Color color) {
    // ... (Your existing breadcrumbs logic)
    final taxaNames = [
      species.family,
      species.subfamily,
      species.tribe,
      species.genus,
    ].where((e) => e != null && e!.isNotEmpty).toList();

    if (taxaNames.isEmpty) return const SizedBox.shrink();

    return Text.rich(
      TextSpan(
        children: taxaNames.expand((name) {
          final isLast = name == taxaNames.last;
          return [
            TextSpan(
              text: name!,
              style: TextStyle(
                color: color,
                fontWeight: isLast ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            if (!isLast)
              TextSpan(
                text: ' > ',
                style: TextStyle(
                  color: color.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
          ];
        }).toList(),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}