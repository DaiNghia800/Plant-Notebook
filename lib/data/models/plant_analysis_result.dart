class PlantAnalysisResult {
  final String tenPhoThong;
  final String tenKhoaHoc;
  final String tinhTrangSucKhoe;
  final String benhDangGap;
  final String loiKhuyenChamSoc;
  final String banCoBiet;

  PlantAnalysisResult({
    required this.tenPhoThong,
    required this.tenKhoaHoc,
    required this.tinhTrangSucKhoe,
    required this.benhDangGap,
    required this.loiKhuyenChamSoc,
    required this.banCoBiet,
  });

  factory PlantAnalysisResult.fromJson(Map<String, dynamic> json) {
    return PlantAnalysisResult(
      tenPhoThong: json['ten_pho_thong'] ?? 'Không rõ',
      tenKhoaHoc: json['ten_khoa_hoc'] ?? 'Không rõ',
      tinhTrangSucKhoe: json['tinh_trang_suc_khoe'] ?? 'Không đánh giá được',
      benhDangGap: json['benh_dang_gap'] ?? 'Không phát hiện bệnh',
      loiKhuyenChamSoc: json['loi_khuyen_cham_soc'] ?? 'Không có',
      banCoBiet: json['ban_co_biet'] ?? 'Bạn có biết: chưa có thông tin thêm cho cây này.',
    );
  }
}
