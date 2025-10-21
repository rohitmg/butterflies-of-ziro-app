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

  // --- 1. TAXONOMIC FILTERS (Unchanged - Cascading Clear Logic) ---

  void setFamily(String? family) {
    state = state.copyWith(
      family: family,
      subfamily: null,
      tribe: null,
      genus: null,
    );
  }

  void setSubfamily(String? subfamily) {
    state = state.copyWith(subfamily: subfamily, tribe: null, genus: null);
  }

  void setTribe(String? tribe) {
    state = state.copyWith(tribe: tribe, genus: null);
  }

  void setGenus(String? genus) {
    state = state.copyWith(genus: genus);
  }

  // --- 2. NEW: NUMERIC RANGE FILTERS (Using structured Min/Max) ---

  void setSizeRange({int? min, int? max}) {
    state = state.copyWith(sizeMin: min, sizeMax: max);
  }

  void setAltitudeRange({int? min, int? max}) {
    state = state.copyWith(altitudeMin: min, altitudeMax: max);
  }

  // --- 3. NEW: SEASONAL RANGE FILTER (Using month indices 1-12) ---

  void setSeasonRange({int? startMonth, int? endMonth}) {
    state = state.copyWith(
      seasonStartMonth: startMonth,
      seasonEndMonth: endMonth,
    );
  }

  // --- 4. SIMPLE ENVIRONMENTAL FILTERS (Retained) ---

  void setHabitat(String? habitat) {
    state = state.copyWith(habitat: habitat);
  }

  // --- 5. UTILITIES ---

  void updateFromState(FilterState newFilters) {
    state = newFilters;
  }

  void clearFilters() {
    state = const FilterState();
  }
}
