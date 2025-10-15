// lib/providers/filter_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:butterflies_of_ziro/providers/filter_state.dart';

// The StateNotifierProvider that exposes the FilterState
final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>(
  (ref) => FilterNotifier(),
);

// The StateNotifier that holds and modifies the FilterState
class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void setFamily(String? family) {
    state = state.copyWith(family: family);
  }

  void setSeason(String? season) {
    state = state.copyWith(season: season);
  }

  void setSize(String? size) {
    state = state.copyWith(size: size);
  }

  void setHabitat(String? habitat) {
    state = state.copyWith(habitat: habitat);
  }

  void setAltitude(String? altitude) {
    state = state.copyWith(altitude: altitude);
  }

  void updateFromState(FilterState newFilters) {
    state = newFilters;
  }

  void clearFilters() {
    state = const FilterState();
  }
}
