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
    this.temperature,
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
  final String? humidityLevel;
  final int? wateringIntervalDays;
  final String? wateringFrequencyLabel;

  factory LibraryPlantItem.fromJson(Map<String, dynamic> json) {
    return LibraryPlantItem(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      shortDescription: json['shortDescription'] as String? ?? '',
      description: json['description'] as String? ?? '',
      lightLevel: json['lightLevel'] as String? ?? '',
      waterNeed: json['waterNeed'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? '',
      careGuide: (json['careGuide'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      funFacts: (json['funFacts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      imageUrl: json['imageUrl'] as String? ?? '',
      scientificName: json['scientificName'] as String?,
      temperature: json['temperature'] as String? ?? json['temperatureRange'] as String?,
      humidity: json['humidity'] as String? ?? json['humidityLevel'] as String?,
      toxicity: json['toxicity'] as String?,
      badge: json['badge'] as String?,
      isTrending: json['isTrending'] as bool? ?? false,
      isRare: json['isRare'] as bool? ?? false,
      temperatureRange: json['temperatureRange'] as String? ?? json['temperature'] as String?,
      humidityLevel: json['humidityLevel'] as String? ?? json['humidity'] as String?,
      wateringIntervalDays: json['wateringIntervalDays'] as int?,
      wateringFrequencyLabel: json['wateringFrequencyLabel'] as String?,
    );
  }
}
