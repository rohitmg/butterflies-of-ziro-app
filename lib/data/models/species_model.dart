// lib/data/models/species_model.dart

class SpeciesModel {
  final int id;
  final String commonName;
  final String scientificName;
  final String family;
  final String? subfamily;
  final String? tribe;
  final String? genus;
  final String? description;
  final String? season;
  final String? size;
  final String? habitat;
  final String? altitude;
  final String? lifeCycle;
  final String? hostPlants;
  final List<String> images;
  final List<String> photographers;

  SpeciesModel({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.family,
    this.subfamily,
    this.tribe,
    this.genus,
    this.description,
    this.season,
    this.size,
    this.habitat,
    this.altitude,
    this.lifeCycle,
    this.hostPlants,
    this.images = const [],
    this.photographers = const [],
  });

  factory SpeciesModel.fromMap(Map<String, dynamic> map) {
    return SpeciesModel(
      id: map['id'],
      commonName: map['common_name'],
      scientificName: map['scientific_name'],
      family: map['family'],
      subfamily: map['subfamily'],
      tribe: map['tribe'],
      genus: map['genus'],
      description: map['description'],
      season: map['season'],
      size: map['size'],
      habitat: map['habitat'],
      altitude: map['altitude'],
      lifeCycle: map['life_cycle'],
      hostPlants: map['host_plants'],
      images: map['filenames'] != null ? (map['filenames'] as String).split(',').toList() : [],
      photographers: map['photographers'] != null ? (map['photographers'] as String).split(',').toList() : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'commonName': commonName,
      'scientificName': scientificName,
      'family': family,
      'subfamily': subfamily,
      'tribe': tribe,
      'genus': genus,
      'season': season,
      'size': size,
      'habitat': habitat,
      'altitude': altitude,
      'description': description,
      'lifeCycle': lifeCycle,
      'hostPlants': hostPlants,
      // Note: Images and Photographers are lists/sets, often excluded or converted to strings for raw DB storage
      'images': images, 
      'photographers': photographers,
    };
  }
}