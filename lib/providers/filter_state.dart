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
  }) = _FilterState;
}