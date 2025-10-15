import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

import 'package:butterflies_of_ziro/data/models/species_model.dart';
import 'package:butterflies_of_ziro/data/repositories/species_repository.dart';
import 'package:butterflies_of_ziro/providers/filter_state.dart';
import 'package:butterflies_of_ziro/providers/filter_provider.dart';

part 'explore_provider.freezed.dart';

@freezed
class ExploreState with _$ExploreState {
  const factory ExploreState({
    @Default(true) bool isLoading,
    @Default([]) List<SpeciesModel> speciesList,
  }) = _ExploreState;
}

class ExploreNotifier extends StateNotifier<ExploreState> {
  final SpeciesRepository _repository;
  ExploreNotifier(this._repository) : super(const ExploreState());

  Future<void> loadSpecies() async {
    state = state.copyWith(isLoading: true);
    final species = await _repository.getAllSpecies();
    state = state.copyWith(isLoading: false, speciesList: species);
  }
}

final exploreProvider = StateNotifierProvider<ExploreNotifier, ExploreState>((ref) {
  final repository = ref.read(speciesRepositoryProvider);
  return ExploreNotifier(repository);
});

final speciesRepositoryProvider = Provider<SpeciesRepository>((ref) {
  return SpeciesRepository();
});

// The filtered list provider now depends on both the repository and the filter state
final filteredSpeciesProvider = FutureProvider<List<SpeciesModel>>((ref) async {
  final filters = ref.watch(filterProvider);
  final repository = ref.read(speciesRepositoryProvider);

  // --- DEBUGGING LOGS BEGIN HERE ---
  debugPrint('DEBUG: Filter provider triggered.');
  debugPrint('DEBUG: Current filters state: $filters');

  // Fetch the data from the repository with the current filters
  final species = await repository.getFilteredSpecies(filters);
  
  debugPrint('DEBUG: Species returned from repository: ${species.length}');
  
  // Your original filtering logic in the provider is now gone,
  // since the repository handles it. We just return the list.
  return species;
});