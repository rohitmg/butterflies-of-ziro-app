import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:butterflies_of_ziro/data/models/species_model.dart';
import 'package:butterflies_of_ziro/features/species_details/presentation/species_details_screen.dart';
void main() {
  testWidgets('SpeciesDetailScreen displays species information correctly', (WidgetTester tester) async {
    // Arrange
    final testSpecies = SpeciesModel(
      id: 1,
      commonName: 'Paris Peacock',
      scientificName: 'Papilio paris',
      family: 'Papilionidae',
      subfamily: 'Papilioninae',
      description: 'A beautiful butterfly with a vibrant blue patch on its hindwings.',
      images: ['papilio_paris_1.jpg', 'papilio_paris_2.jpg'],
      photographers: ['John Smith', 'Jane Doe'],
    );

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: SpeciesDetailScreen(species: testSpecies),
      ),
    );

    // Assert
    expect(find.text('Paris Peacock'), findsOneWidget);
    expect(find.text('Papilio paris'), findsOneWidget);
    expect(find.text('Family: Papilionidae'), findsOneWidget);
    expect(find.text('Subfamily: Papilioninae'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('A beautiful butterfly with a vibrant blue patch on its hindwings.'), findsOneWidget);
  });
}