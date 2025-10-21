// lib/providers/filter_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'filter_state.freezed.dart';

// An immutable class to hold the state of all filters
@freezed
class FilterState with _$FilterState {
  const factory FilterState({
    @Default(null) String? superfamily,
    @Default(null) String? family,
    @Default(null) String? subfamily,
    @Default(null) String? tribe,
    @Default(null) String? genus,
    @Default(null) String? season,
    @Default(null) String? size,
    @Default(null) String? habitat,
    @Default(null) String? altitude,
    @Default(null) int? sizeMin,
    @Default(null) int? sizeMax,

    @Default(null) int? altitudeMin,
    @Default(null) int? altitudeMax,

    // --- SEASONAL RANGES (Using indices 1-12) ---
    @Default(null) int? seasonStartMonth, // 1=Jan, 12=Dec
    @Default(null) int? seasonEndMonth,   // 1=Jan, 12=Dec
  }) = _FilterState;
}