// lib/features/explore/presentation/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/painting.dart';

import 'package:butterflies_of_ziro/data/models/species_model.dart';
import 'package:butterflies_of_ziro/providers/explore_provider.dart';
import 'package:butterflies_of_ziro/features/species_details/presentation/species_details_screen.dart';
import 'package:butterflies_of_ziro/core/app_colors.dart';
import 'dart:async';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final ScrollController _scrollController = ScrollController();
  final Set<String> _cachedImagePaths = {};
  final Set<String> _failedImageLoads = {};
  Timer? _debounce;
  int _firstVisibleIndex = 0;
  int _lastVisibleIndex = 0;
  int _visibleSpeciesCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exploreProvider.notifier).loadSpecies();
    });
    _scrollController.addListener(_debouncedScrollListener);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.removeListener(_debouncedScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _debouncedScrollListener() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), _updateVisibleItems);
  }

  void _manageImageCache() {
    final allSpecies = ref.read(exploreProvider).speciesList;
    if (!mounted || allSpecies.isEmpty) return;

    const int preloadBuffer = 2;
    final cacheStart = (_firstVisibleIndex - preloadBuffer).clamp(0, allSpecies.length - 1);
    final cacheEnd = (_lastVisibleIndex + preloadBuffer).clamp(0, allSpecies.length - 1);

    final newPathsToCache = <String>{};
    for (int i = cacheStart; i <= cacheEnd; i++) {
      final species = allSpecies[i];
      if (species.images.isNotEmpty && !_failedImageLoads.contains(species.images.first)) {
        newPathsToCache.add('assets/images/butterflies/${species.images.first}');
      }
    }

    _cachedImagePaths.forEach((path) {
      if (!newPathsToCache.contains(path)) {
        PaintingBinding.instance.imageCache.evict(AssetImage(path));
      }
    });

    newPathsToCache.forEach((path) {
      if (!_cachedImagePaths.contains(path)) {
        precacheImage(
          AssetImage(path),
          context,
          onError: (exception, stackTrace) {
            debugPrint('Failed to precache image: $path');
            setState(() {
              _failedImageLoads.add(path);
            });
          },
        );
      }
    });

    setState(() {
      _cachedImagePaths
        ..clear()
        ..addAll(newPathsToCache);
    });
  }

  void _updateVisibleItems() {
    final exploreState = ref.read(exploreProvider);
    final totalItems = exploreState.speciesList.length;

    if (!mounted || totalItems == 0 || !_scrollController.hasClients || _scrollController.position.viewportDimension == 0) return;

    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject == null || renderObject is! RenderBox) return;

    final RenderBox renderBox = renderObject;
    final viewportHeight = renderBox.size.height;
    final viewportWidth = renderBox.size.width;

    const crossAxisCount = 2;
    const crossAxisSpacing = 8.0;
    const mainAxisSpacing = 8.0;
    
    final itemWidth = (viewportWidth - (crossAxisSpacing * (crossAxisCount - 1))) / crossAxisCount;
    final itemHeight = itemWidth / (3 / 2); // Calculate height based on 3:2 ratio
    
    final firstVisibleIndex = (_scrollController.offset / itemHeight).floor() * crossAxisCount;
    final lastVisibleIndex = firstVisibleIndex + ((viewportHeight / itemHeight).ceil() * crossAxisCount);

    setState(() {
      _firstVisibleIndex = firstVisibleIndex.clamp(0, totalItems - 1).toInt();
      _lastVisibleIndex = lastVisibleIndex.clamp(0, totalItems - 1).toInt();
      _visibleSpeciesCount = (_lastVisibleIndex - _firstVisibleIndex).clamp(0, totalItems).toInt() + 1;
      _manageImageCache();
    });
  }

  @override
  Widget build(BuildContext context) {
    final exploreState = ref.watch(exploreProvider);

    if (exploreState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Butterflies of Ziro')),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              padding: const EdgeInsets.all(8.0),
              itemCount: exploreState.speciesList.length,
              itemBuilder: (context, index) {
                final species = exploreState.speciesList[index];
                final imageUrl = species.images.isNotEmpty
                    ? 'assets/images/butterflies/${species.images.first}'
                    : null;
                
                final cardColor = butterflyFamilyMap[species.family]?.variants['dull'] ?? Colors.grey;
                final textColor = butterflyFamilyMap[species.family]?.variants['dark'] ?? Colors.black;

                final isCached = imageUrl != null && _cachedImagePaths.contains(imageUrl);

                return Card(
                  elevation: 4.0,
                  color: cardColor.withOpacity(0.5),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SpeciesDetailScreen(species: species),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4.0)),
                            child: imageUrl != null && _cachedImagePaths.contains(imageUrl)
                                ? Image.asset(
                                    imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Center(child: Icon(Icons.broken_image, color: Colors.white70)),
                                  )
                                : const Center(child: CircularProgressIndicator(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                species.commonName,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                species.scientificName,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: textColor.withOpacity(0.7),
                                      fontStyle: FontStyle.italic,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildDebugArea(exploreState.speciesList),
        ],
      ),
    );
  }

  Widget _buildDebugArea(List<dynamic> allSpecies) {
    final List<SpeciesModel> speciesList = List<SpeciesModel>.from(allSpecies);
    final first = _firstVisibleIndex.clamp(0, speciesList.length - 1);
    final last = _lastVisibleIndex.clamp(0, speciesList.length - 1);
    final visibleSpecies = speciesList.sublist(
      first,
      (last + 1).clamp(0, speciesList.length),
    );

    return Container(
      color: Colors.deepPurple,
      padding: const EdgeInsets.all(8.0),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TOTAL: ${speciesList.length} | CACHED: ${_cachedImagePaths.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Visible: $_visibleSpeciesCount (${_firstVisibleIndex}-${_lastVisibleIndex})',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Failed Loads: ${_failedImageLoads.length}',
              style: const TextStyle(color: Colors.redAccent),
            ),
            Text(
              'Visible Species: ${visibleSpecies.map((s) => s.commonName).join(', ')}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}