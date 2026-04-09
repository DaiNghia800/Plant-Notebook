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
    required this.imageUrl,
    this.isTrending = false,
    this.isRare = false,
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
  final String imageUrl;
  final bool isTrending;
  final bool isRare;
}
