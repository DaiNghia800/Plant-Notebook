import 'package:flutter/material.dart';
import 'package:plant_notebook/common/styles/app_colors.dart';
import 'package:plant_notebook/routes/route_constant.dart';
import 'package:plant_notebook/data/services/google_auth_service.dart';
import 'package:plant_notebook/common/widgets/widget.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plant_notebook/data/services/email_auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final EmailAuthService _emailAuthService = EmailAuthService();

  bool _obscurePassword = true;
  bool _isGoogleRegistering = false;
  bool _isEmailRegistering = false;

  @override
  void initState() {
    super.initState();
    _googleAuthService.onCurrentUserChanged.listen((
      GoogleSignInAccount? googleUser,
    ) async {
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      if (googleUser != null) {
        if (_isGoogleRegistering) return;
        setState(() {
          _isGoogleRegistering = true;
        });
        try {
          await _googleAuthService.handleGoogleAuthResult(googleUser);
          if (!mounted) return;
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(appViewRoute, (route) => false);
        } catch (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi đăng ký Google: $error')));
        } finally {
          if (mounted) {
            setState(() {
              _isGoogleRegistering = false;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onRegisterPressed() async {
    if (_isEmailRegistering) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu xác nhận không khớp')),
      );
      return;
    }

    setState(() {
      _isEmailRegistering = true;
    });

    try {
      await _emailAuthService.register(
        email: email,
        phone: phone,
        password: password,
        name: name,
      );
      if (!mounted) return;

      // Đồng bộ user sang PostgreSQL
      await _emailAuthService.syncToPostgres(
        email: email,
        displayName: name,
        uid: password, // dùng password làm uid tạm
      );

      // Sau khi đăng ký thành công, tự động đăng nhập
      await _emailAuthService.login(identifier: email, password: password);
      if (!mounted) return;

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(appViewRoute, (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isEmailRegistering = false;
        });
      }
    }
  }

  Future<void> _onGoogleRegisterPressed() async {
    if (_isGoogleRegistering) {
      return;
    }

    setState(() {
      _isGoogleRegistering = true;
    });

    try {
      final GoogleAuthResult? result = await _googleAuthService
          .signInWithGoogle();

      if (!mounted) {
        return;
      }

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Người dùng đã hủy đăng ký Google')),
        );
        return;
      }

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(appViewRoute, (route) => false);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi đăng ký Google: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleRegistering = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF135022)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Sổ tay cây trồng',
          style: TextStyle(
            color: Color(0xFF135022),
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Background leaf watermark placeholder at bottom
          Positioned(
            bottom: -50,
            left: 0,
            right: 0,
            child: Icon(
              Icons.energy_savings_leaf_rounded,
              size: 240,
              color: Colors.black.withOpacity(0.03),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Logo
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.yard_rounded,
                          size: 36,
                          color: Color(0xFF135022),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Titles
                    const Text(
                      'Bắt đầu hành trình',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111C14),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tạo tài khoản để quản lý khu vườn của bạn',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Color(0xFF4B6255)),
                    ),
                    const SizedBox(height: 28),

                    // Form Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name Field
                          _buildLabel('HỌ VÀ TÊN'),
                          _buildTextField(
                            controller: _nameController,
                            hintText: 'Nguyễn Văn A',
                            prefixIcon: Icons.person_rounded,
                          ),
                          const SizedBox(height: 18),

                          // Email Field
                          _buildLabel('EMAIL CỦA BẠN'),
                          _buildTextField(
                            controller: _emailController,
                            hintText: 'example@gmail.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 18),

                          // Phone Field
                          _buildLabel('SỐ ĐIỆN THOẠI'),
                          _buildTextField(
                            controller: _phoneController,
                            hintText: '09...',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 18),

                          // Password Field
                          _buildLabel('MẬT KHẨU'),
                          _buildTextField(
                            controller: _passwordController,
                            hintText: '••••••••',
                            prefixIcon: Icons.lock_rounded,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color(0xFF90A496),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Confirm Password Field
                          _buildLabel('XÁC NHẬN MẬT KHẨU'),
                          _buildTextField(
                            controller: _confirmController,
                            hintText: '••••••••',
                            prefixIcon: Icons.history_rounded,
                            obscureText: _obscurePassword,
                          ),
                          const SizedBox(height: 28),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed: _isEmailRegistering
                                  ? () {}
                                  : _onRegisterPressed,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7B36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: _isEmailRegistering
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          'Đăng ký',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Already have account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Đã có tài khoản? ',
                                style: TextStyle(
                                  color: Color(0xFF4B6255),
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Đăng nhập ngay',
                                  style: TextStyle(
                                    color: Color(0xFF186F2F),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    // Social Divider
                    Row(
                      children: const [
                        Expanded(child: Divider(color: Color(0xFFE5ECE7))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'HOẶC ĐĂNG KÝ BẰNG',
                            style: TextStyle(
                              color: Color(0xFF6B8071),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFFE5ECE7))),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Social Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: GoogleSignInButton(
                            onPressed: _onGoogleRegisterPressed,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                GoogleLogoWidget(size: 20.0),
                                SizedBox(width: 8),
                                Text(
                                  'Google',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111C14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SocialButton(
                            label: 'Facebook',
                            iconData: Icons.facebook,
                            iconColor: const Color(0xFF1877F2),
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
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
        fillColor: const Color(0xFFF1F6F3),
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
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.onTap,
    this.iconData,
    this.iconColor,
    this.iconWidget,
  });

  final String label;
  final IconData? iconData;
  final Color? iconColor;
  final Widget? iconWidget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F6F3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconWidget != null)
              iconWidget!
            else if (iconData != null)
              Icon(iconData, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111C14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
