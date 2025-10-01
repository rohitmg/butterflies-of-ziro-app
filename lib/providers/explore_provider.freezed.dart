// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'explore_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ExploreState {
  bool get isLoading => throw _privateConstructorUsedError;
  List<SpeciesModel> get speciesList => throw _privateConstructorUsedError;

  /// Create a copy of ExploreState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExploreStateCopyWith<ExploreState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExploreStateCopyWith<$Res> {
  factory $ExploreStateCopyWith(
    ExploreState value,
    $Res Function(ExploreState) then,
  ) = _$ExploreStateCopyWithImpl<$Res, ExploreState>;
  @useResult
  $Res call({bool isLoading, List<SpeciesModel> speciesList});
}

/// @nodoc
class _$ExploreStateCopyWithImpl<$Res, $Val extends ExploreState>
    implements $ExploreStateCopyWith<$Res> {
  _$ExploreStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExploreState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? isLoading = null, Object? speciesList = null}) {
    return _then(
      _value.copyWith(
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            speciesList: null == speciesList
                ? _value.speciesList
                : speciesList // ignore: cast_nullable_to_non_nullable
                      as List<SpeciesModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExploreStateImplCopyWith<$Res>
    implements $ExploreStateCopyWith<$Res> {
  factory _$$ExploreStateImplCopyWith(
    _$ExploreStateImpl value,
    $Res Function(_$ExploreStateImpl) then,
  ) = __$$ExploreStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isLoading, List<SpeciesModel> speciesList});
}

/// @nodoc
class __$$ExploreStateImplCopyWithImpl<$Res>
    extends _$ExploreStateCopyWithImpl<$Res, _$ExploreStateImpl>
    implements _$$ExploreStateImplCopyWith<$Res> {
  __$$ExploreStateImplCopyWithImpl(
    _$ExploreStateImpl _value,
    $Res Function(_$ExploreStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExploreState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? isLoading = null, Object? speciesList = null}) {
    return _then(
      _$ExploreStateImpl(
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        speciesList: null == speciesList
            ? _value._speciesList
            : speciesList // ignore: cast_nullable_to_non_nullable
                  as List<SpeciesModel>,
      ),
    );
  }
}

/// @nodoc

class _$ExploreStateImpl implements _ExploreState {
  const _$ExploreStateImpl({
    required this.isLoading,
    required final List<SpeciesModel> speciesList,
  }) : _speciesList = speciesList;

  @override
  final bool isLoading;
  final List<SpeciesModel> _speciesList;
  @override
  List<SpeciesModel> get speciesList {
    if (_speciesList is EqualUnmodifiableListView) return _speciesList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_speciesList);
  }

  @override
  String toString() {
    return 'ExploreState(isLoading: $isLoading, speciesList: $speciesList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExploreStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality().equals(
              other._speciesList,
              _speciesList,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isLoading,
    const DeepCollectionEquality().hash(_speciesList),
  );

  /// Create a copy of ExploreState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExploreStateImplCopyWith<_$ExploreStateImpl> get copyWith =>
      __$$ExploreStateImplCopyWithImpl<_$ExploreStateImpl>(this, _$identity);
}

abstract class _ExploreState implements ExploreState {
  const factory _ExploreState({
    required final bool isLoading,
    required final List<SpeciesModel> speciesList,
  }) = _$ExploreStateImpl;

  @override
  bool get isLoading;
  @override
  List<SpeciesModel> get speciesList;

  /// Create a copy of ExploreState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExploreStateImplCopyWith<_$ExploreStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
