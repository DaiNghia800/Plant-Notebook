import 'package:flutter/material.dart';
import 'package:plant_notebook/routes/route_constant.dart';
import 'package:plant_notebook/data/services/google_auth_service.dart';
import 'package:plant_notebook/common/widgets/widget.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plant_notebook/data/services/email_auth_service.dart';
import 'package:plant_notebook/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final EmailAuthService _emailAuthService = EmailAuthService();
  bool _obscurePassword = true;
  bool _isGoogleSigningIn = false;
  bool _isEmailSigningIn = false;

  // Validation error messages
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _googleAuthService.onCurrentUserChanged.listen((
      GoogleSignInAccount? googleUser,
    ) async {
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      if (googleUser != null) {
        if (_isGoogleSigningIn) return;
        setState(() {
          _isGoogleSigningIn = true;
        });
        try {
          await _googleAuthService.handleGoogleAuthResult(googleUser);
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed(appViewRoute);
        } catch (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi đăng nhập Google: $error')),
          );
        } finally {
          if (mounted) {
            setState(() {
              _isGoogleSigningIn = false;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    final emailErr = AppValidators.validateEmail(_emailController.text);
    final passwordErr = AppValidators.validatePasswordLogin(_passwordController.text);
    setState(() {
      _emailError = emailErr;
      _passwordError = passwordErr;
    });
    return emailErr == null && passwordErr == null;
  }

  Future<void> _onLoginPressed() async {
    if (_isEmailSigningIn) return;
    if (!_validateForm()) return;

    final identifier = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isEmailSigningIn = true;
    });

    try {
      await _emailAuthService.login(identifier: identifier, password: password);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(appViewRoute);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isEmailSigningIn = false;
        });
      }
    }
  }

  Future<void> _onGoogleLoginPressed() async {
    if (_isGoogleSigningIn) {
      return;
    }

    setState(() {
      _isGoogleSigningIn = true;
    });

    try {
      final GoogleAuthResult? result = await _googleAuthService
          .signInWithGoogle();

      if (!mounted) {
        return;
      }

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Người dùng đã hủy đăng nhập Google')),
        );
        return;
      }

      Navigator.of(context).pushReplacementNamed(appViewRoute);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi đăng nhập Google: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleSigningIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F6),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9DF09E),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.yard_outlined,
                      size: 40,
                      color: Color(0xFF135022),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Titles
                const Text(
                  'Chào mừng trở lại',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111C14),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tiếp tục hành trình chăm sóc khu vườn của bạn',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Color(0xFF4B6255)),
                ),
                const SizedBox(height: 32),

                // Form Card
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
                      // Email Field
                      const Text(
                        'EMAIL CỦA BẠN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Color(0xFF334B3B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) {
                          if (_emailError != null) {
                            setState(() => _emailError = null);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'example@gmail.com',
                          hintStyle: const TextStyle(color: Color(0xFF90A496)),
                          filled: true,
                          fillColor: _emailError != null
                              ? const Color(0xFFFFF0F0)
                              : const Color(0xFFEFF4F0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: _emailError != null
                                ? const BorderSide(
                                    color: Color(0xFFE53935),
                                    width: 1.5,
                                  )
                                : BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: _emailError != null
                                  ? const Color(0xFFE53935)
                                  : const Color(0xFF267A32),
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: _emailError != null
                                ? const Color(0xFFE53935)
                                : const Color(0xFF7A8D81),
                            size: 22,
                          ),
                        ),
                      ),
                      if (_emailError != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 14,
                              color: Color(0xFFE53935),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _emailError!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Password Field
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'MẬT KHẨU',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: Color(0xFF334B3B),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushNamed(forgotPasswordViewRoute);
                            },
                            child: const Text(
                              'Quên mật khẩu?',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF186F2F),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onChanged: (_) {
                          if (_passwordError != null) {
                            setState(() => _passwordError = null);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: const TextStyle(color: Color(0xFF90A496)),
                          filled: true,
                          fillColor: _passwordError != null
                              ? const Color(0xFFFFF0F0)
                              : const Color(0xFFEFF4F0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: _passwordError != null
                                ? const BorderSide(
                                    color: Color(0xFFE53935),
                                    width: 1.5,
                                  )
                                : BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: _passwordError != null
                                  ? const Color(0xFFE53935)
                                  : const Color(0xFF267A32),
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_rounded,
                            color: _passwordError != null
                                ? const Color(0xFFE53935)
                                : const Color(0xFF7A8D81),
                            size: 22,
                          ),
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
                      ),
                      if (_passwordError != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 14,
                              color: Color(0xFFE53935),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _passwordError!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 32),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: _isEmailSigningIn
                              ? () {}
                              : _onLoginPressed,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF267A32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: _isEmailSigningIn
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: const [
                          Expanded(child: Divider(color: Color(0xFFE5ECE7))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'hoặc',
                              style: TextStyle(
                                color: Color(0xFF6B8071),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Color(0xFFE5ECE7))),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Social Login
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: GoogleSignInButton(
                          onPressed: _isGoogleSigningIn
                              ? () {}
                              : _onGoogleLoginPressed,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isGoogleSigningIn)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                const GoogleLogoWidget(size: 20.0),
                              const SizedBox(width: 12),
                              Text(
                                _isGoogleSigningIn
                                    ? 'Đang đăng nhập...'
                                    : 'Đăng nhập với Google',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Bạn chưa có tài khoản? ',
                      style: TextStyle(color: Color(0xFF4B6255), fontSize: 15),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(registerViewRoute);
                      },
                      child: const Text(
                        'Tham gia ngay',
                        style: TextStyle(
                          color: Color(0xFF186F2F),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
