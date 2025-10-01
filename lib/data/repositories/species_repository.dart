// lib/data/repositories/species_repository.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:butterflies_of_ziro/data/models/species_model.dart';

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
}
