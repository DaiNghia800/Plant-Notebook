class PlantAnalysisResult {
  final String tenPhoThong;
  final String tenKhoaHoc;
  final String category;
  final String tinhTrangSucKhoe;
  final String benhDangGap;
  final String loiKhuyenChamSoc;
  final String banCoBiet;
  final String shortDescription;
  final String description;
  final String lightLevel;
  final String waterNeed;
  final String difficulty;
  final String temperature;
  final String humidity;
  final String toxicity;
  final List<String> careGuide;
  final List<String> funFacts;
  final List<Map<String, dynamic>> growthTimeline;

  PlantAnalysisResult({
    required this.tenPhoThong,
    required this.tenKhoaHoc,
    required this.category,
    required this.tinhTrangSucKhoe,
    required this.benhDangGap,
    required this.loiKhuyenChamSoc,
    required this.banCoBiet,
    required this.shortDescription,
    required this.description,
    required this.lightLevel,
    required this.waterNeed,
    required this.difficulty,
    required this.temperature,
    required this.humidity,
    required this.toxicity,
    required this.careGuide,
    required this.funFacts,
    required this.growthTimeline,
  });

  factory PlantAnalysisResult.fromJson(Map<String, dynamic> json) {
    // Parse careGuide
    List<String> rawCareGuide = [];
    if (json['careGuide'] != null) {
      rawCareGuide = List<String>.from(json['careGuide'].map((x) => x.toString()));
    }

    // Parse funFacts
    List<String> rawFunFacts = [];
    if (json['funFacts'] != null) {
      rawFunFacts = List<String>.from(json['funFacts'].map((x) => x.toString()));
    } else {
      rawFunFacts = [json['ban_co_biet'] ?? ''];
    }

    // Parse growthTimeline
    List<Map<String, dynamic>> rawGrowth = [];
    if (json['growthTimeline'] != null) {
      rawGrowth = List<Map<String, dynamic>>.from(
        json['growthTimeline'].map((x) => Map<String, dynamic>.from(x as Map)),
      );
    }

    return PlantAnalysisResult(
      tenPhoThong: json['ten_pho_thong'] ?? 'Không rõ',
      tenKhoaHoc: json['ten_khoa_hoc'] ?? 'Không rõ',
      category: json['category'] ?? 'Trong nhà',
      tinhTrangSucKhoe: json['tinh_trang_suc_khoe'] ?? 'Không đánh giá được',
      benhDangGap: json['benh_dang_gap'] ?? 'Không phát hiện bệnh',
      loiKhuyenChamSoc: json['loi_khuyen_cham_soc'] ?? 'Không có',
      banCoBiet: json['ban_co_biet'] ?? 'Bạn có biết: chưa có thông tin thêm cho cây này.',
      shortDescription: json['shortDescription'] ?? '',
      description: json['description'] ?? '',
      lightLevel: json['lightLevel'] ?? 'Sáng gián tiếp',
      waterNeed: json['waterNeed'] ?? 'Trung bình',
      difficulty: json['difficulty'] ?? 'Dễ',
      temperature: json['temperature'] ?? '20-30°C',
      humidity: json['humidity'] ?? 'Trung bình',
      toxicity: json['toxicity'] ?? 'Chưa xác định',
      careGuide: rawCareGuide,
      funFacts: rawFunFacts,
      growthTimeline: rawGrowth,
    );
  }
}
