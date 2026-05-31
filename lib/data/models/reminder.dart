class GardenReminder {
  const GardenReminder({
    required this.wateringCycleDays,
    required this.fertilizingCycleDays,
    required this.pushNotificationEnabled,
    this.lastWateredAt,
    this.nextWateredAt,
    this.lastFertilizedAt,
    this.nextFertilizedAt,
  });

  final int wateringCycleDays;
  final int fertilizingCycleDays;
  final bool pushNotificationEnabled;
  final DateTime? lastWateredAt;
  final DateTime? nextWateredAt;
  final DateTime? lastFertilizedAt;
  final DateTime? nextFertilizedAt;

  factory GardenReminder.fromJson(List<dynamic> json) {
    int wateringCycleDays = 3;
    int fertilizingCycleDays = 14;
    bool pushNotificationEnabled = true;
    DateTime? lastWateredAt;
    DateTime? nextWateredAt;
    DateTime? lastFertilizedAt;
    DateTime? nextFertilizedAt;

    for (var reminder in json) {
      if (reminder is Map<String, dynamic>) {
        String type = reminder['type'] as String? ?? '';
        if (type == 'Tưới nước') {
          wateringCycleDays = (reminder['frequencyDays'] as num?)?.toInt() ?? 3;
          pushNotificationEnabled = reminder['isPushEnabled'] as bool? ?? true;
          lastWateredAt = DateTime.tryParse(
            reminder['lastActionAt']?.toString() ?? '',
          );
          if (lastWateredAt != null) {
            final int cycle = (reminder['frequencyDays'] as num?)?.toInt() ?? 3;
            nextWateredAt = lastWateredAt.add(Duration(days: cycle));
          }
        } else if (type == 'Bón phân') {
          fertilizingCycleDays =
              (reminder['frequencyDays'] as num?)?.toInt() ?? 14;
          lastFertilizedAt = DateTime.tryParse(
            reminder['lastActionAt']?.toString() ?? '',
          );
          if (lastFertilizedAt != null) {
            final int cycle = (reminder['frequencyDays'] as num?)?.toInt() ?? 3;
            nextFertilizedAt = lastFertilizedAt.add(Duration(days: cycle));
          }
        }
      }
    }

    return GardenReminder(
      wateringCycleDays: wateringCycleDays,
      fertilizingCycleDays: fertilizingCycleDays,
      pushNotificationEnabled: pushNotificationEnabled,
      lastWateredAt: lastWateredAt,
      nextWateredAt: nextWateredAt,
      lastFertilizedAt: lastFertilizedAt,
      nextFertilizedAt: nextFertilizedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'frequencyDays': wateringCycleDays,
      'isPushEnabled': pushNotificationEnabled,
    };
  }

  GardenReminder copyWith({
    int? wateringCycleDays,
    int? fertilizingCycleDays,
    bool? pushNotificationEnabled,
    DateTime? lastWateredAt,
    DateTime? nextWateredAt,
    DateTime? lastFertilizedAt,
    DateTime? nextFertilizedAt,
  }) {
    return GardenReminder(
      wateringCycleDays: wateringCycleDays ?? this.wateringCycleDays,
      fertilizingCycleDays: fertilizingCycleDays ?? this.fertilizingCycleDays,
      pushNotificationEnabled:
          pushNotificationEnabled ?? this.pushNotificationEnabled,
      lastWateredAt: lastWateredAt ?? this.lastWateredAt,
      nextWateredAt: nextWateredAt ?? this.nextWateredAt,
      lastFertilizedAt: lastFertilizedAt ?? this.lastFertilizedAt,
      nextFertilizedAt: nextFertilizedAt ?? this.nextFertilizedAt,
    );
  }
}
