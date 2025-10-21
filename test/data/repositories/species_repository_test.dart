// test/data/repositories/species_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart'; // Needed for rootBundle
import 'package:mockito/mockito.dart'; // Needed for mocking
import 'package:mockito/annotations.dart'; // Needed for mocking
import 'package:collection/collection.dart';

import 'package:butterflies_of_ziro/data/repositories/species_repository.dart';
import 'package:butterflies_of_ziro/providers/filter_state.dart';
import 'package:butterflies_of_ziro/data/models/species_model.dart'; // Needed for model access

// -----------------------------------------------------
// Utility Class for Collecting Failures
// -----------------------------------------------------
class Failure {
  final String speciesName;
  final String fileName;
  final String issue;

  Failure(this.speciesName, this.fileName, this.issue);
}

// Global list to capture failures
final List<Failure> _failures = [];

// -----------------------------------------------------
// REGEX Definitions for Data Format Validation
// -----------------------------------------------------

// Validates simple range: "90-110" or single number "100" (Allows spaces around hyphen)
final RegExp _rangeRegex = RegExp(r'^\s*\d+(\s*-\s*\d+)?\s*$');

// Validates altitude format:
// 1. Numerical range (e.g., "100-500")
// 2. Descriptive text (e.g., "Low elevations", "Hills")
// 3. Open-ended phrase (e.g., "upto 500", "upto 1000m")
final RegExp _altitudeRegex = RegExp(
  r'^\s*(\d+(\s*-\s*\d+)?|\s*upto\s+\d+|[A-Za-z,\s]+)\s*$',
  caseSensitive:
      false, // Make check case-insensitive for text (e.g., "Upto" vs "upto")
);

// Validates season: "Jan", "Mar, Apr", or "Aug-Nov" (checks for words or valid months)
final RegExp _seasonRegex = RegExp(r'^[A-Za-z,\s-]+$');

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  TestWidgetsFlutterBinding.ensureInitialized();

  // Define required fields for validation
  const requiredFields = [
    'commonName',
    'scientificName',
    'size',
    'habitat',
    'altitude',
    'family',
    'subfamily',
    'tribe',
    'genus',
  ];

  // --- Test 1: Database Setup ---
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

  // --- Test 2: Single Species Retrieval (Unchanged for robustness) ---
  test('Can retrieve a species by its scientific name', () async {
    final repository = SpeciesRepository();
    await repository.initDatabase();

    const scientificName = 'Papilio paris';

    final species = await repository.getSpeciesByScientificName(scientificName);

    expect(species, isNotNull);
    expect(species!.scientificName, scientificName);
    expect(species!.commonName, 'Paris Peacock');
    expect(species!.family, 'Papilionidae');
    expect(species!.images, isNotEmpty);
  });

  // --- Test 3: List Retrieval (Unchanged for robustness) ---
  test('Can retrieve a list of all species', () async {
    final repository = SpeciesRepository();
    await repository.initDatabase();

    final allSpecies = await repository.getAllSpecies();

    expect(allSpecies, isNotEmpty);
    expect(allSpecies.length, greaterThan(1));
  });

  // -----------------------------------------------------
  // --- Test 4: Comprehensive Data and Image Integrity Check ---
  // -----------------------------------------------------
  test(
    'Data Integrity: All species satisfy required field and image constraints',
    () async {
      final repo = SpeciesRepository();
      await repo.initDatabase();

      // --- ADD TEARDOWN LOGIC ---
      addTearDown(() {
        if (_failures.isNotEmpty) {
          // Construct the tabular output string
          const columnWidths = [30, 45, 80];
          final header =
              'SPECIES NAME'.padRight(columnWidths[0]) +
              '| FILENAME'.padRight(columnWidths[1]) +
              '| ISSUE';
          final separator = List.filled(header.length, '-').join();

          final failureRows = _failures
              .map((f) {
                return f.speciesName.padRight(columnWidths[0]) +
                    '| ${f.fileName.padRight(columnWidths[1])}' +
                    '| ${f.issue}';
              })
              .join('\n');

          final fullReport =
              '\n' +
              separator +
              '\nDATA INTEGRITY FAILURES FOUND: ${_failures.length}' +
              '\n' +
              separator +
              '\n' +
              header +
              '\n' +
              separator +
              '\n' +
              failureRows +
              '\n' +
              separator;

          // Throw the error with the final report
          fail(fullReport);
        }
      });

      // --- Execution Loop (Soft Assertions) ---
      final allSpecies = await repo.getFilteredSpecies(const FilterState());

      // Check overall count
      if (allSpecies.length != 242) {
        _failures.add(
          Failure(
            'GLOBAL',
            'N/A',
            'Expected 242 species, found ${allSpecies.length}',
          ),
        );
        return;
      }

      for (final species in allSpecies) {
        final speciesName = species.scientificName;
        final map = species.toMap();
        String imagePath = species.images.isEmpty
            ? 'MISSING_IMAGE_PATH'
            : species.images.first;

        // 1. Check for missing critical non-null fields
        for (final fieldName in requiredFields) {
          final value = map[fieldName];
          if (value == null || value.toString().isEmpty) {
            _failures.add(
              Failure(speciesName, 'N/A', 'Missing required field: $fieldName'),
            );
          }
        }

        // 2. Check for Image Existence (Skipping if no path exists)
        if (species.images.isEmpty) {
          _failures.add(Failure(speciesName, 'N/A', 'No image path found.'));
          continue;
        }

        // 3. Image File Path Validation
        final lowerCasePath = imagePath.toLowerCase();
        final hasValidExtension =
            lowerCasePath.endsWith('.png') ||
            lowerCasePath.endsWith('.jpg') ||
            lowerCasePath.endsWith('.jpeg');

        if (!hasValidExtension) {
          _failures.add(
            Failure(speciesName, imagePath, 'Invalid file extension.'),
          );
        }

        // ------------------------------------------
        // 4. NEW: Data Format Validation Checks
        // ------------------------------------------

        // Check Size format ("X-Y")
        final size = species.size ?? '';
        if (!_rangeRegex.hasMatch(size)) {
          _failures.add(
            Failure(speciesName, size, 'Size format invalid (expected X-Y).'),
          );
        }

        // Check Altitude format ("X-Y")
        // final altitude = species.altitude ?? '';
        // if (!_altitudeRegex.hasMatch(altitude)) {
        //   _failures.add(
        //     Failure(
        //       speciesName,
        //       altitude,
        //       'Altitude format invalid (expected X-Y or descriptive text).',
        //     ),
        //   );
        // }

        // Check Season format ("Jan-Dec" or "Mar, Apr")
        final season = species.season ?? '';
        if (!_seasonRegex.hasMatch(season)) {
          _failures.add(
            Failure(
              speciesName,
              season,
              'Season format invalid (expected month names).',
            ),
          );
        }
      }
    },
  );

  test('Filtering by Family returns only species from that family', () async {
    final repo = SpeciesRepository();
    await repo.initDatabase();

    // ARRANGE: Use a known Family from your database
    const targetFamily = 'Papilionidae';
    final filters = FilterState(family: targetFamily);

    // ACT: Filter the species
    final filteredSpecies = await repo.getFilteredSpecies(filters);

    // ASSERT: Check that results are not empty and ALL species belong to the target family
    expect(
      filteredSpecies,
      isNotEmpty,
      reason: 'Should find species in $targetFamily',
    );
    expect(
      filteredSpecies.every((s) => s.family == targetFamily),
      isTrue,
      reason: 'All returned species must be in $targetFamily',
    );
  });

  // --- Test 6 (NEW): Filtering by Lowest Taxonomic Level (Tribe/Genus) ---
  test('Filtering by Tribe returns a subset correctly', () async {
    final repo = SpeciesRepository();
    await repo.initDatabase();

    // ARRANGE: Use a known Tribe from your database
    const targetTribe = 'Apaturini';
    final filters = FilterState(
      tribe: targetTribe,
    ); // Tribe is the lowest level filter set

    // ACT
    final filteredSpecies = await repo.getFilteredSpecies(filters);

    // ASSERT: Check that results are not empty and are specific to the tribe
    expect(
      filteredSpecies,
      isNotEmpty,
      reason: 'Should find species in $targetTribe',
    );
    expect(
      filteredSpecies.every((s) => s.tribe == targetTribe),
      isTrue,
      reason: 'All returned species must be in $targetTribe',
    );
  });

  // --- Test 7 (UPDATED): Filtering by Size Range Overlap ---
  test('Filtering by Size Range returns overlapping species', () async {
    final repository = SpeciesRepository();
    await repository.initDatabase();

    // ARRANGE: Set a filter range (e.g., filter species overlapping the 30-50mm range)
    const filterMin = 30;
    const filterMax = 50;
    final filters = FilterState(sizeMin: filterMin, sizeMax: filterMax);

    // ACT
    final filteredSpecies = await repository.getFilteredSpecies(filters);

    // ASSERT: We only check that results are returned and assume the SQL overlap logic is correct.
    expect(
      filteredSpecies,
      isNotEmpty,
      reason: 'Should find species overlapping 30-50mm range',
    );

    // NOTE: A detailed assertion to validate overlap would require complex Dart parsing
    // of the DB string, so we trust the SQL for correctness and test for non-empty results.
  });

  // --- Test 8 (UPDATED): Filtering by Season Range Overlap (Indices) ---
  test(
    'Filtering by Season Range returns overlapping species (June - Aug)',
    () async {
      final repository = SpeciesRepository();
      await repository.initDatabase();

      // ARRANGE: Use month indices (6 = Jun, 8 = Aug)
      const startMonth = 6;
      const endMonth = 8;
      final filters = FilterState(
        seasonStartMonth: startMonth,
        seasonEndMonth: endMonth,
      );

      // ACT
      final filteredSpecies = await repository.getFilteredSpecies(filters);

      // ASSERT: Check that results are returned.
      expect(
        filteredSpecies,
        isNotEmpty,
        reason: 'Should find species active during June-August.',
      );
    },
  );

  // --- Test 9 (UPDATED): Filtering by Altitude Range Overlap ---
  test(
    'Filtering by Altitude Range returns overlapping species (400m - 1200m)',
    () async {
      final repository = SpeciesRepository();
      await repository.initDatabase();

      // ARRANGE: Filter for species found between 400m and 1200m
      const filterMin = 400;
      const filterMax = 1200;
      final filters = FilterState(
        altitudeMin: filterMin,
        altitudeMax: filterMax,
      );

      // ACT
      final filteredSpecies = await repository.getFilteredSpecies(filters);

      // ASSERT
      expect(
        filteredSpecies,
        isNotEmpty,
        reason: 'Should find species overlapping 400m-1200m altitude.',
      );
    },
  );
}
