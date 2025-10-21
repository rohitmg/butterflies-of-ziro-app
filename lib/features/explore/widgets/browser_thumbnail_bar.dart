import 'package:flutter/material.dart';
import 'package:butterflies_of_ziro/data/models/species_model.dart';

// --- CONSTANTS FOR THUMBNAIL BAR ---
const double _thumbnailWidth = 72.0; // 60 * 1.2 = 72 (20% increase)
const double _thumbnailHeight = 48.0; // 40 * 1.2 = 48 (maintaining 3:2 aspect ratio)
const double _thumbnailMargin = 4.0; 

class BrowserThumbnailBar extends StatelessWidget {
  final List<SpeciesModel> speciesList;
  final int currentIndex;
  final Function(int) onIndexChanged;
  final Color familyColor;
  final ScrollController scrollController;

  const BrowserThumbnailBar({
    super.key,
    required this.speciesList,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.familyColor,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Distinct, slightly darker background color
      color: Colors.grey.shade500, 
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Column(
        children: [
          // 1. HORIZONTAL SCROLLING THUMBNAIL LIST (MAXIMIZED SPACE)
          SizedBox(
            height: _thumbnailHeight, 
            child: ListView.builder(
              
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: speciesList.length,
              itemBuilder: (context, index) {
                return _buildThumbnail(
                  index, 
                  speciesList[index], 
                  familyColor,
                );
              },
            ),
          ),
          
          const SizedBox(height: 8),

          // 2. SEQUENCE INDICATOR (Below the maximized carousel)
          Center(
            child: Text(
              '${currentIndex + 1} / ${speciesList.length}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(int index, SpeciesModel species, Color familyColor) {
    final bool isActive = index == currentIndex;
    final String? thumbUrl = species.images.isNotEmpty
        ? 'assets/images/butterflies/${species.images.first}'
        : null;
        
    return GestureDetector(
      onTap: () => onIndexChanged(index),
      child: Container(
        // Use increased dimensions
        width: _thumbnailWidth, 
        height: _thumbnailHeight, 
        margin: const EdgeInsets.symmetric(horizontal: _thumbnailMargin), 
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(6.0),
          border: isActive 
              ? Border.all(color: familyColor, width: 3.0) 
              : Border.all(color: Colors.transparent, width: 3.0),
          image: thumbUrl != null
              ? DecorationImage(
                  image: AssetImage(thumbUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: thumbUrl == null 
            ? const Center(child: Icon(Icons.photo_library_outlined, size: 20, color: Colors.grey)) 
            : null,
      ),
    );
  }
}