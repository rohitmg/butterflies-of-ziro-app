// lib/data/repositories/species_repository.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:math' as math; // Import dart:math for min/max functions
import 'package:collection/collection.dart'; // Import collection for whereNotNull

import 'package:butterflies_of_ziro/data/models/species_model.dart';
import 'package:butterflies_of_ziro/providers/filter_state.dart';

class SpeciesRepository {
  Database? _database;

  Future<void> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'butterflies.db');

    // Check if the database exists
    final exists = await databaseExists(path);
    if (!exists) {
      // Should only happen the first time you run the app
      print('Creating new copy from assets');

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(
        join("assets/db", "butterflies.db"),
      );
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      // Write and flush the bytes
      await File(path).writeAsBytes(bytes, flush: true);
    }

    _database = await openDatabase(path);
  }

  Future<List<SpeciesModel>> getAllSpecies() async {
    final db = await database;
    final sql = '''
      SELECT
          s.*,
          t.family,
          t.subfamily,
          t.tribe,
          t.genus,
          GROUP_CONCAT(i.filename) AS filenames,
          GROUP_CONCAT(p.name) AS photographers
      FROM
          Species AS s
      LEFT JOIN
          Taxonomy AS t ON s.taxonomy_id = t.id
      LEFT JOIN
          Images AS i ON s.id = i.species_id
      LEFT JOIN
          Photographers AS p ON i.photographer_id = p.id
      GROUP BY
          s.id;
    ''';

    final result = await db.rawQuery(sql);

    return result.map((map) => SpeciesModel.fromMap(map)).toList();
  }

  Future<List<SpeciesModel>> getFilteredSpecies(FilterState filters) async {
    final db = await database;

    // --- 1. Fetch ALL Species (No WHERE clause yet) ---
    final sql = '''
    SELECT s.*, t.family, t.subfamily, t.tribe, t.genus, 
           GROUP_CONCAT(i.filename) AS filenames, GROUP_CONCAT(p.name) AS photographers
    FROM Species AS s
    LEFT JOIN Taxonomy AS t ON s.taxonomy_id = t.id
    LEFT JOIN Images AS i ON s.id = i.species_id
    LEFT JOIN Photographers AS p ON i.photographer_id = p.id
    GROUP BY s.id;
  ''';
    final rawResult = await db.rawQuery(sql);
    List<SpeciesModel> allSpecies = rawResult
        .map((map) => SpeciesModel.fromMap(map))
        .toList();

    // --- 2. Dart Filtering Logic ---
    return allSpecies.where((species) {
      // --- 2a. TAXONOMIC FILTERS (Exact Match) ---
      if (filters.family != null && species.family != filters.family)
        return false;
      if (filters.subfamily != null && species.subfamily != filters.subfamily)
        return false;
      if (filters.tribe != null && species.tribe != filters.tribe) return false;
      if (filters.genus != null && species.genus != filters.genus) return false;

      // --- 2b. SIZE OVERLAP ---
      if (filters.sizeMin != null && filters.sizeMax != null) {
        final speciesRange = _parseNumericRange(species.size);
        if (!_checkNumericOverlap(
          speciesRange,
          filters.sizeMin!,
          filters.sizeMax!,
        ))
          return false;
      }

      // --- 2c. ALTITUDE OVERLAP ---
      if (filters.altitudeMin != null && filters.altitudeMax != null) {
        // NOTE: Altitude data like "Low elevations" must be mapped to a range (e.g., [0, 500])
        // on the INGESTION side for reliable numerical filtering.
        final speciesRange = _parseNumericRange(species.altitude);
        if (!_checkNumericOverlap(
          speciesRange,
          filters.altitudeMin!,
          filters.altitudeMax!,
        ))
          return false;
      }

      // --- 2d. SEASONAL OVERLAP ---
      if (filters.seasonStartMonth != null && filters.seasonEndMonth != null) {
        final speciesRange = _parseSeasonalRange(species.season);
        if (!_checkSeasonOverlap(
          speciesRange,
          filters.seasonStartMonth!,
          filters.seasonEndMonth!,
        ))
          return false;
      }

      // --- 2e. SIMPLE ENVIRONMENTAL FILTERS ---
      if (filters.habitat != null && species.habitat != filters.habitat)
        return false;
      // ... other simple filters

      return true; // Passed all active filters
    }).toList();
  }

  Future<SpeciesModel?> getSpeciesByScientificName(String name) async {
    final db = await database;
    final sql = '''
      SELECT
          s.*,
          t.family,
          t.subfamily,
          t.tribe,
          t.genus,
          GROUP_CONCAT(i.filename) AS filenames,
          GROUP_CONCAT(p.name) AS photographers
      FROM
          Species AS s
      LEFT JOIN
          Taxonomy AS t ON s.taxonomy_id = t.id
      LEFT JOIN
          Images AS i ON s.id = i.species_id
      LEFT JOIN
          Photographers AS p ON i.photographer_id = p.id
      WHERE
          s.scientific_name = ?
      GROUP BY
          s.id;
    ''';

    final result = await db.rawQuery(sql, [name]);

    if (result.isNotEmpty) {
      return SpeciesModel.fromMap(result.first);
    }
    return null;
  }

  // A getter to access the database instance
  Future<Database> get database async {
    if (_database == null) {
      await initDatabase();
    }
    return _database!;
  }

  // Map month name abbreviations to 1-based index (1=Jan, 12=Dec)
  final _monthIndexMap = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  // --- A. DATA PARSING HELPERS ---

  // Converts "10-50", "90", or "100m" to a numeric range [min, max]
  List<int> _parseNumericRange(String? value) {
    if (value == null) return [];

    // Clean up and standardize the input (e.g., "500-1000m" -> "500-1000")
    final cleaned = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^\d\-]'), '')
        .trim();
    final parts = cleaned.split('-');

    try {
      if (parts.length == 2) {
        final min = int.parse(parts[0].trim());
        final max = int.parse(parts[1].trim());
        return [min, max];
      } else if (parts.length == 1) {
        final val = int.parse(parts[0].trim());
        return [val, val];
      }
    } catch (_) {
      // Return empty list if parsing fails
    }
    return [];
  }

  // Converts "Jan-Jul" or "Mar, Apr" into a continuous range [start_index, end_index]
  // NOTE: This assumes the DB stores ONE dominant range.
  List<int> _parseSeasonalRange(String? season) {
    if (season == null) return [];
    season = season.trim().toLowerCase();

    // Special case for year-round
    if (season.contains('year-round')) return [1, 12];

    final parts = season
        .split(RegExp(r'[-,]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return [];

    final indices = parts
        .map((p) => _monthIndexMap[p.substring(0, 3)])
        .whereNotNull()
        .toList();
    if (indices.isEmpty) return [];

    // Find the min and max index for the continuous span (handling wrap-around)
    final start = indices.reduce(math.min);
    final end = indices.reduce(math.max);

    return [
      start,
      end,
    ]; // Returns a simplified [min_month, max_month] index pair
  }

  // --- B. OVERLAP LOGIC HELPERS ---

  // Checks if two numeric ranges [A_min, A_max] and [B_min, B_max] overlap.
  bool _checkNumericOverlap(List<int> rangeA, int minB, int maxB) {
    if (rangeA.length != 2) return false;
    final minA = rangeA[0];
    final maxA = rangeA[1];

    // Overlap condition: A_min <= B_max AND A_max >= B_min
    return minA <= maxB && maxA >= minB;
  }

  // Checks if two seasonal ranges overlap (complex due to 1-12 cycle)
  bool _checkSeasonOverlap(List<int> rangeA, int minB, int maxB) {
    if (rangeA.length != 2) return false;
    final startA = rangeA[0];
    final endA = rangeA[1];

    // 1. Convert everything to an absolute index array (1 to 12)
    Set<int> getIndices(int start, int end) {
      Set<int> indices = {};
      int current = start;
      while (true) {
        indices.add(current);
        if (current == end) break;
        current = (current % 12) + 1; // Cycle 12 back to 1
        if (indices.length > 12) break; // Safety break
      }
      return indices;
    }

    final indicesA = getIndices(startA, endA);
    final indicesB = getIndices(minB, maxB);

    // 2. Check for intersection
    return indicesA.intersection(indicesB).isNotEmpty;
  }
}
