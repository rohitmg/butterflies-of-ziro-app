// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:butterflies_of_ziro/features/explore/presentation/explore_screen.dart';
import 'package:butterflies_of_ziro/data/repositories/species_repository.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Butterflies of Ziro',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ExploreScreen(),
    );
  }
}

// Don't forget to define the speciesRepositoryProvider in your provider file.
// It should look something like this:
// final speciesRepositoryProvider = Provider<SpeciesRepository>((ref) {
//   return SpeciesRepository();
// });
