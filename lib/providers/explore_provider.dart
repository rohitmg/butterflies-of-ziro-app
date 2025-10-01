// lib/providers/explore_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:butterflies_of_ziro/data/models/species_model.dart';
import 'package:butterflies_of_ziro/data/repositories/species_repository.dart';

part 'explore_provider.freezed.dart';

// State class using Freezed for immutability
@freezed
class ExploreState with _$ExploreState {
  const factory ExploreState({
    required bool isLoading,
    required List<SpeciesModel> speciesList,
  }) = _ExploreState;

  factory ExploreState.initial() => const ExploreState(
        isLoading: true,
        speciesList: [],
      );
}

// State Notifier
class ExploreNotifier extends StateNotifier<ExploreState> {
  final SpeciesRepository _repository;

  ExploreNotifier(this._repository) : super(ExploreState.initial());

  Future<void> loadSpecies() async {
    state = state.copyWith(isLoading: true);
    final species = await _repository.getAllSpecies();
    state = state.copyWith(isLoading: false, speciesList: species);
  }
}

// Provider for the SpeciesRepository
final speciesRepositoryProvider = Provider<SpeciesRepository>((ref) {
  // In a real app, this would return an instance of your repository
  return SpeciesRepository();
});

// The main provider for the UI state
final exploreProvider = StateNotifierProvider<ExploreNotifier, ExploreState>((ref) {
  final repository = ref.read(speciesRepositoryProvider);
  return ExploreNotifier(repository);
});