import 'package:flutter/material.dart';
import 'package:plant_notebook/common/styles/app_colors.dart';
import 'package:plant_notebook/routes/route_constant.dart';
import 'package:plant_notebook/data/services/google_auth_service.dart';
import 'package:plant_notebook/common/widgets/widget.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plant_notebook/data/services/email_auth_service.dart';
import 'package:plant_notebook/utils/validators.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/profile_controller.dart';

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
  bool _obscureConfirm = true;
  bool _isGoogleRegistering = false;
  bool _isEmailRegistering = false;

  // Validation error messages
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmError;

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
          ).showSnackBar(SnackBar(content: Text('${context.read<ProfileController>().tr('google_reg_error')}$error')));
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

  // ── Validators ──────────────────────────────────────────────────────────────

  bool _validateForm() {
    final nameErr = AppValidators.validateName(_nameController.text);
    final emailErr = AppValidators.validateEmail(_emailController.text);
    final phoneErr = AppValidators.validatePhone(_phoneController.text);
    final passwordErr = AppValidators.validatePassword(_passwordController.text);
    final confirmErr = AppValidators.validateConfirmPassword(
      _confirmController.text,
      _passwordController.text,
    );
    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _phoneError = phoneErr;
      _passwordError = passwordErr;
      _confirmError = confirmErr;
    });
    return nameErr == null &&
        emailErr == null &&
        phoneErr == null &&
        passwordErr == null &&
        confirmErr == null;
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _onRegisterPressed() async {
    if (_isEmailRegistering) return;
    if (!_validateForm()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

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
          SnackBar(content: Text(context.read<ProfileController>().tr('google_reg_cancel'))),
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
      ).showSnackBar(SnackBar(content: Text('${context.read<ProfileController>().tr('google_reg_error')}$error')));
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleRegistering = false;
        });
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<ProfileController>();
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
                    Text(
                      lang.tr('create_account_desc'),
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
                            errorText: _nameError,
                            onChanged: (_) {
                              if (_nameError != null) setState(() => _nameError = null);
                            },
                          ),
                          _buildErrorText(_nameError),
                          const SizedBox(height: 18),

                          // Email Field
                          _buildLabel(lang.tr('email').toUpperCase()),
                          _buildTextField(
                            controller: _emailController,
                            hintText: 'example@gmail.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            errorText: _emailError,
                            onChanged: (_) {
                              if (_emailError != null) setState(() => _emailError = null);
                            },
                          ),
                          _buildErrorText(_emailError),
                          const SizedBox(height: 18),

                          // Phone Field
                          _buildLabel('SỐ ĐIỆN THOẠI'),
                          _buildTextField(
                            controller: _phoneController,
                            hintText: '0912345678',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            errorText: _phoneError,
                            onChanged: (_) {
                              if (_phoneError != null) setState(() => _phoneError = null);
                            },
                          ),
                          _buildErrorText(_phoneError),
                          const SizedBox(height: 18),

                          // Password Field
                          _buildLabel(lang.tr('password_label')),
                          _buildTextField(
                            controller: _passwordController,
                            hintText: '••••••••',
                            prefixIcon: Icons.lock_rounded,
                            obscureText: _obscurePassword,
                            errorText: _passwordError,
                            onChanged: (_) {
                              if (_passwordError != null) setState(() => _passwordError = null);
                              // Re-validate confirm nếu đã nhập
                              if (_confirmController.text.isNotEmpty) {
                                setState(() {
                                  _confirmError = AppValidators.validateConfirmPassword(
                                    _confirmController.text,
                                    _passwordController.text,
                                  );
                                });
                              }
                            },
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
                          _buildErrorText(_passwordError),
                          if (_passwordError == null && _passwordController.text.isNotEmpty)
                            _buildPasswordStrengthIndicator(_passwordController.text),
                          const SizedBox(height: 18),

                          // Confirm Password Field
                          _buildLabel(lang.tr('confirm_password_label')),
                          _buildTextField(
                            controller: _confirmController,
                            hintText: '••••••••',
                            prefixIcon: Icons.history_rounded,
                            obscureText: _obscureConfirm,
                            errorText: _confirmError,
                            onChanged: (_) {
                              if (_confirmError != null) setState(() => _confirmError = null);
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color(0xFF90A496),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirm = !_obscureConfirm;
                                });
                              },
                            ),
                          ),
                          _buildErrorText(_confirmError),
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
                                      children: [
                                        Text(
                                          lang.tr('register'),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        const Icon(
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
                              Text(
                                lang.tr('already_have_account'),
                                style: TextStyle(
                                  color: Color(0xFF4B6255),
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  lang.tr('login_now'),
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
                      children: [
                        const Expanded(child: Divider(color: Color(0xFFE5ECE7))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            lang.tr('or_register_with'),
                            style: TextStyle(
                              color: Color(0xFF6B8071),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: Color(0xFFE5ECE7))),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Social Buttons Row
                    GoogleSignInButton(
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

  // ── Helpers ──────────────────────────────────────────────────────────────────

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

  Widget _buildErrorText(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 14, color: Color(0xFFE53935)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              error,
              style: const TextStyle(fontSize: 12, color: Color(0xFFE53935)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator(String password) {
    final strength = AppValidators.passwordStrength(password);

    final labels = ['Yếu', 'Trung bình', 'Khá mạnh', 'Mạnh'];
    final colors = [
      const Color(0xFFE53935),
      const Color(0xFFFF9800),
      const Color(0xFF8BC34A),
      const Color(0xFF267A32),
    ];
    final idx = (strength - 1).clamp(0, 3);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(4, (i) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: i < strength
                        ? colors[idx]
                        : const Color(0xFFE0E8E3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Text(
            'Độ mạnh: ${labels[idx]}',
            style: TextStyle(fontSize: 11, color: colors[idx]),
          ),
        ],
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
    String? errorText,
    void Function(String)? onChanged,
  }) {
    final hasError = errorText != null;
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFB0C2B6)),
        filled: true,
        fillColor: hasError ? const Color(0xFFFFF0F0) : const Color(0xFFF1F6F3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: hasError
              ? const BorderSide(color: Color(0xFFE53935), width: 1.5)
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: hasError ? const Color(0xFFE53935) : const Color(0xFF2E7B36),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: hasError ? const Color(0xFFE53935) : const Color(0xFF7A8D81),
          size: 22,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
