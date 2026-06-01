import 'package:flutter/material.dart';
import 'package:plant_notebook/data/services/email_auth_service.dart';

enum ForgotPasswordStep { email, otp, newPassword }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final EmailAuthService _emailAuthService = EmailAuthService();
  
  ForgotPasswordStep _currentStep = ForgotPasswordStep.email;
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Vui lòng nhập email');
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      await _emailAuthService.sendForgotPasswordOtp(email: email);
      if (!mounted) return;
      setState(() => _currentStep = ForgotPasswordStep.otp);
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVerifyOtp() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      _showError('Vui lòng nhập mã OTP');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _emailAuthService.verifyOtp(email: email, otp: otp);
      if (!mounted) return;
      setState(() => _currentStep = ForgotPasswordStep.newPassword);
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      _showError('Vui lòng nhập mật khẩu mới');
      return;
    }
    if (password != confirm) {
      _showError('Mật khẩu xác nhận không khớp');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _emailAuthService.resetPassword(
        email: email,
        otp: otp,
        newPassword: password,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt lại mật khẩu thành công! Vui lòng đăng nhập lại.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF135022)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Quên mật khẩu',
          style: TextStyle(
            color: Color(0xFF135022),
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF9DF09E),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock_reset_rounded,
                    size: 40,
                    color: Color(0xFF135022),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _currentStep == ForgotPasswordStep.email
                    ? 'Tìm lại tài khoản'
                    : _currentStep == ForgotPasswordStep.otp
                        ? 'Xác thực OTP'
                        : 'Đặt mật khẩu mới',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111C14),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currentStep == ForgotPasswordStep.email
                    ? 'Nhập email đã đăng ký để nhận mã OTP'
                    : _currentStep == ForgotPasswordStep.otp
                        ? 'Nhập mã 6 số được gửi đến email của bạn'
                        : 'Tạo mật khẩu mới cho tài khoản',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Color(0xFF4B6255)),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentStep == ForgotPasswordStep.email) ...[
                      _buildLabel('EMAIL CỦA BẠN'),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'example@gmail.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 32),
                      _buildButton(
                        text: 'Gửi mã OTP',
                        onPressed: _handleSendOtp,
                      ),
                    ] else if (_currentStep == ForgotPasswordStep.otp) ...[
                      _buildLabel('MÃ OTP'),
                      _buildTextField(
                        controller: _otpController,
                        hintText: '123456',
                        prefixIcon: Icons.password_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 32),
                      _buildButton(
                        text: 'Xác nhận OTP',
                        onPressed: _handleVerifyOtp,
                      ),
                    ] else ...[
                      _buildLabel('MẬT KHẨU MỚI'),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: '••••••••',
                        prefixIcon: Icons.lock_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: const Color(0xFF90A496),
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildLabel('XÁC NHẬN MẬT KHẨU MỚI'),
                      _buildTextField(
                        controller: _confirmController,
                        hintText: '••••••••',
                        prefixIcon: Icons.history_rounded,
                        obscureText: _obscurePassword,
                      ),
                      const SizedBox(height: 32),
                      _buildButton(
                        text: 'Đổi mật khẩu',
                        onPressed: _handleResetPassword,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: Color(0xFF334B3B),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFB0C2B6)),
        filled: true,
        fillColor: const Color(0xFFEFF4F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF7A8D81), size: 22),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: _isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF267A32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
