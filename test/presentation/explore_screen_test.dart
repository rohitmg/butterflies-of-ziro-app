// test/presentation/explore_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:butterflies_of_ziro/data/models/species_model.dart';
import 'package:butterflies_of_ziro/data/repositories/species_repository.dart';
import 'package:butterflies_of_ziro/providers/explore_provider.dart';
import 'package:butterflies_of_ziro/features/explore/presentation/explore_screen.dart';
import 'package:butterflies_of_ziro/features/species_details/presentation/species_details_screen.dart';

import 'explore_screen_test.mocks.dart';

@GenerateMocks(
  [SpeciesRepository],
  // Use customMocks to create a "nice mock" for NavigatorObserver
  customMocks: [MockSpec<NavigatorObserver>(as: #MockNavigatorObserver)],
)
void main() {
  final mockSpeciesList = [
    SpeciesModel(
      id: 1,
      commonName: 'Paris Peacock',
      scientificName: 'Papilio paris',
      family: 'Papilionidae',
      images: ['papilio_paris.jpg'],
    ),
    SpeciesModel(
      id: 2,
      commonName: 'Great Mormon',
      scientificName: 'Papilio memnon',
      family: 'Papilionidae',
      images: ['papilio_memnon.jpg'],
    ),
  ];

  testWidgets('ExploreScreen displays a list of species', (
    WidgetTester tester,
  ) async {
    final mockRepository = MockSpeciesRepository();
    when(mockRepository.getAllSpecies()).thenAnswer((_) async => mockSpeciesList);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exploreProvider.overrideWith(
            (ref) => ExploreNotifier(
              mockRepository,
            )..state = ExploreState(isLoading: false, speciesList: mockSpeciesList),
          ),
        ],
        child: const MaterialApp(home: ExploreScreen()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Paris Peacock'), findsOneWidget);
    expect(find.text('Papilio paris'), findsOneWidget);
    expect(find.text('Great Mormon'), findsOneWidget);
    expect(find.text('Papilio memnon'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('ExploreScreen displays a loading indicator when loading', (
    WidgetTester tester,
  ) async {
    final mockRepository = MockSpeciesRepository();
    when(mockRepository.getAllSpecies()).thenAnswer((_) async => []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exploreProvider.overrideWith(
            (ref) => ExploreNotifier(mockRepository)
              ..state = const ExploreState(isLoading: true, speciesList: []),
          ),
        ],
        child: const MaterialApp(home: ExploreScreen()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // testWidgets('Tapping a list tile navigates to SpeciesDetailScreen', (
  //   WidgetTester tester,
  // ) async {
  //   // Arrange
  //   final mockRepository = MockSpeciesRepository();
  //   final mockNavigatorObserver = MockNavigatorObserver();
    
  //   when(mockRepository.getAllSpecies()).thenAnswer((_) async => mockSpeciesList);
    
  //   // We no longer need to manually create MockNavigatorState
  //   when(mockNavigatorObserver.didPush(any, any)).thenAnswer((_) {});

  //   await tester.pumpWidget(
  //     ProviderScope(
  //       overrides: [
  //         exploreProvider.overrideWith(
  //           (ref) => ExploreNotifier(
  //             mockRepository,
  //           )..state = ExploreState(isLoading: false, speciesList: mockSpeciesList),
  //         ),
  //       ],
  //       child: MaterialApp(
  //         home: const ExploreScreen(),
  //         navigatorObservers: [mockNavigatorObserver],
  //       ),
  //     ),
  //   );

  //   await tester.pumpAndSettle();

  //   await tester.tap(find.byType(ListTile).first);
  //   await tester.pumpAndSettle();

  //   verify(mockNavigatorObserver.didPush(any, any)).called(1);
  //   expect(find.byType(SpeciesDetailScreen), findsOneWidget);
  // });

}