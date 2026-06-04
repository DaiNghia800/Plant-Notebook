/// Tập hợp các hàm validate dùng chung cho toàn bộ ứng dụng.
class AppValidators {
  AppValidators._(); // Không cho khởi tạo

  // ── Họ và tên ───────────────────────────────────────────────────────────────

  static String? validateName(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Vui lòng nhập họ và tên';
    if (v.length < 2) return 'Tên phải có ít nhất 2 ký tự';
    final nameRegex = RegExp(
      r'^[a-zA-ZÀ-ỹà-ỹĂăÂâĐđÊêÔôƠơƯư\s]+$',
    );
    if (!nameRegex.hasMatch(v)) {
      return 'Tên không được chứa số hoặc ký tự đặc biệt';
    }
    return null;
  }

  // ── Email ────────────────────────────────────────────────────────────────────

  static String? validateEmail(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Vui lòng nhập email';
    final emailRegex = RegExp(r'^[\w.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(v)) {
      return 'Email không đúng định dạng (vd: abc@gmail.com)';
    }
    return null;
  }

  // ── Số điện thoại Việt Nam ──────────────────────────────────────────────────

  static String? validatePhone(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Vui lòng nhập số điện thoại';
    // 10 số, đầu 03x / 05x / 07x / 08x / 09x
    final phoneRegex = RegExp(
      r'^(0)(3[2-9]|5[6-9]|7[06-9]|8[0-9]|9[0-9])[0-9]{7}$',
    );
    if (!phoneRegex.hasMatch(v)) {
      return 'Số điện thoại không hợp lệ (vd: 0912345678)';
    }
    return null;
  }

  // ── Mật khẩu ────────────────────────────────────────────────────────────────

  static String? validatePassword(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (v.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    if (!RegExp(r'[A-Za-z]').hasMatch(v)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ cái';
    }
    if (!RegExp(r'[0-9]').hasMatch(v)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ số';
    }
    return null;
  }

  /// Validate mật khẩu chỉ cần không rỗng và tối thiểu 6 ký tự (dùng cho đăng nhập).
  static String? validatePasswordLogin(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (v.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    return null;
  }

  // ── Xác nhận mật khẩu ───────────────────────────────────────────────────────

  static String? validateConfirmPassword(String value, String password) {
    final v = value.trim();
    if (v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
    if (v != password.trim()) return 'Mật khẩu xác nhận không khớp';
    return null;
  }

  // ── Độ mạnh mật khẩu (0-4) ──────────────────────────────────────────────────

  /// Trả về số từ 0 đến 4 thể hiện độ mạnh của mật khẩu.
  static int passwordStrength(String password) {
    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) score++;
    return score;
  }
}
