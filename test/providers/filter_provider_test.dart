import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:butterflies_of_ziro/providers/filter_provider.dart';
import 'package:butterflies_of_ziro/providers/filter_state.dart';

void main() {
  ProviderContainer container = ProviderContainer();
  
  setUp(() {
    // Reset the container before each test
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });
  
  test('FilterNotifier initializes with all null filters', () {
    final filters = container.read(filterProvider);
    expect(filters, const FilterState(family: null, sizeMax: null, seasonStartMonth: null));
  });

  test('setFamily clears all lower taxonomic levels', () {
    final notifier = container.read(filterProvider.notifier);
    
    // 1. Set a deep, complex state first
    notifier.updateFromState(const FilterState(
      family: 'Nymphalidae', 
      subfamily: 'Danainae', 
      tribe: 'Danaini',
      sizeMin: 10,
    ));
    
    // 2. Set only the Family filter
    notifier.setFamily('Pieridae');
    
    final newState = container.read(filterProvider);
    
    // Assert lower levels are cleared, but non-taxonomic fields remain
    expect(newState.family, 'Pieridae');
    expect(newState.subfamily, isNull, reason: 'Subfamily must be cleared.');
    expect(newState.tribe, isNull, reason: 'Tribe must be cleared.');
    expect(newState.sizeMin, 10, reason: 'Size filter should be unaffected.');
  });
  
  test('updateFromState correctly overwrites all fields and clears non-provided ones', () {
    final notifier = container.read(filterProvider.notifier);
    
    // Set an initial state
    notifier.updateFromState(const FilterState(family: 'Old', sizeMin: 5));
    
    // Overwrite with a new state (where sizeMin is not provided, meaning it should clear)
    const newLocalState = FilterState(family: 'NewFamily', habitat: 'Mountain');
    notifier.updateFromState(newLocalState);
    
    final finalState = container.read(filterProvider);
    
    // Assert
    expect(finalState.family, 'NewFamily');
    expect(finalState.habitat, 'Mountain');
    expect(finalState.sizeMin, isNull, reason: 'SizeMin should be cleared by the update logic.');
    expect(finalState.subfamily, isNull, reason: 'Unset fields should be null.');
  });

  test('clearFilters resets to default empty state', () {
    final notifier = container.read(filterProvider.notifier);
    notifier.updateFromState(const FilterState(family: 'Set', sizeMin: 10));
    
    notifier.clearFilters();
    
    final newState = container.read(filterProvider);
    expect(newState, const FilterState(), reason: 'All fields must return to default null state.');
  });
}