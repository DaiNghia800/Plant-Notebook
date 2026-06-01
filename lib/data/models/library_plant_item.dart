class LibraryPlantItem {
  const LibraryPlantItem({
    required this.id,
    required this.name,
    required this.category,
    required this.shortDescription,
    required this.description,
    required this.lightLevel,
    required this.waterNeed,
    required this.difficulty,
    required this.careGuide,
    required this.funFacts,
    required this.imageUrl,
    this.scientificName,
    this.humidity,
    this.isTrending = false,
    this.isRare = false,
    this.temperatureRange,
    this.badge,
    this.humidityLevel,
    this.toxicity,
    this.wateringIntervalDays,
    this.wateringFrequencyLabel,
  });

  final String id;
  final String name;
  final String category;
  final String shortDescription;
  final String description;
  final String lightLevel;
  final String waterNeed;
  final String difficulty;
  final List<String> careGuide;
  final List<String> funFacts;
  final String imageUrl;
  final String? scientificName;
  final String? temperature;
  final String? humidity;
  final String? toxicity;
  final String? badge;
  final bool isTrending;
  final bool isRare;
  final String? temperatureRange;
  final String? badge;
  final String? scientificName;
  final String? humidityLevel;
  final String? toxicity;
  final int? wateringIntervalDays;
  final String? wateringFrequencyLabel;
}
