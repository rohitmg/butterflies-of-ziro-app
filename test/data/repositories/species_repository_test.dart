// test/data/repositories/species_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import this package
import 'package:path/path.dart';

import 'package:butterflies_of_ziro/data/repositories/species_repository.dart';

// Your test should be inside a main function
void main() {
  // Initialize FFI database factory for testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  TestWidgetsFlutterBinding.ensureInitialized();

  test('Database is copied from assets and can be opened', () async {
    // Arrange
    final dbPath = join(await getDatabasesPath(), 'butterflies.db');

    // Act
    await SpeciesRepository().initDatabase();

    // Assert
    final db = await openDatabase(dbPath);
    expect(db.isOpen, isTrue);
    await db.close();
  });

  test('Can retrieve a species by its scientific name', () async {
    // Arrange
    final repository = SpeciesRepository();
    await repository.initDatabase(); // Ensure the database is initialized

    const scientificName = 'Papilio paris'; // A species you know is in your DB

    // Act
    final species = await repository.getSpeciesByScientificName(scientificName);

    // Assert
    expect(species, isNotNull);
    expect(species!.scientificName, scientificName);
    expect(species!.commonName, 'Paris Peacock');
    expect(species!.family, 'Papilionidae');
    // Add more assertions for other fields (description, etc.)
    expect(species!.images, isNotEmpty);
  });

  test('Can retrieve a list of all species', () async {
    // Arrange
    final repository = SpeciesRepository();
    await repository.initDatabase();

    // Act
    final allSpecies = await repository.getAllSpecies();

    // Assert
    expect(allSpecies, isNotEmpty);
    expect(
      allSpecies.length,
      greaterThan(1),
    ); // Assuming you have more than one species in your DB
  });
}
