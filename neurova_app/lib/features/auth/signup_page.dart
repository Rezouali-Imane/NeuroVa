import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login_page.dart';
import '../profil/setup_profil1.dart';
import '../onboarding/background.dart';
import '../../shared/widgets/entry_reveal.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1450),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hintColor = Colors.white.withValues(alpha: 0.4);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OnboardingBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: EntryReveal(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildStaggered(
                        index: 0,
                        child: const _BrandHeader(),
                      ),
                      const SizedBox(height: 18),
                      _buildStaggered(
                        index: 1,
                        child: const Text(
                          'join now',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFFFFF0),
                            fontSize: 56,
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w900,
                            height: 0.95,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildStaggered(
                        index: 2,
                        child: const Text(
                          'Start your AI-powered learning journey',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFFFFF0),
                            fontSize: 16,
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                            letterSpacing: -0.31,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15.04),
                      _buildStaggered(
                        index: 3,
                        child: _buildField(
                          controller: _nameController,
                          label: "Full Name",
                          hintColor: hintColor,
                          iconPath: 'lib/features/onboarding/assets/Icon1.svg',
                          validator: (v) =>
                              v == null || v.isEmpty ? "Name is required" : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStaggered(
                        index: 4,
                        child: _buildField(
                          controller: _emailController,
                          label: "Email address",
                          hintColor: hintColor,
                          iconPath: 'lib/features/onboarding/assets/Icon2.svg',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Email is required";
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStaggered(
                        index: 5,
                        child: _buildField(
                          controller: _passwordController,
                          label: "Password",
                          hintColor: hintColor,
                          iconPath: 'lib/features/onboarding/assets/Icon3.svg',
                          obscureText: _obscurePassword,
                          autovalidateMode:
                              AutovalidateMode.onUserInteraction,
                          suffix: _buildAnimatedEyeIcon(
                            isObscured: _obscurePassword,
                            onTap: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Password is required";
                            }
                            final passwordRegex = RegExp(
                              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]{8,}$',
                            );
                            final emojiRegex = RegExp(
                              r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
                              unicode: true,
                            );

                            if (emojiRegex.hasMatch(v)) {
                              return "Emojis are not allowed in the password.";
                            }

                            if (!passwordRegex.hasMatch(v)) {
                              return "Password must be at least 8 characters and include an uppercase letter, a lowercase letter, a number, and a special character (@\$!%*?&#).";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStaggered(
                        index: 6,
                        child: _buildField(
                          controller: _confirmController,
                          label: "Confirm Password",
                          hintColor: hintColor,
                          iconPath: 'lib/features/onboarding/assets/Icon3.svg',
                          obscureText: _obscureConfirm,
                          suffix: _buildAnimatedEyeIcon(
                            isObscured: _obscureConfirm,
                            onTap: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Confirm your password";
                            }
                            if (v != _passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildStaggered(
                        index: 7,
                        child: Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 10,
                            runSpacing: 4,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _agreeTerms = !_agreeTerms;
                                  });
                                },
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _agreeTerms
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: _agreeTerms
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.black,
                                        )
                                      : null,
                                ),
                              ),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 12,
                                  ),
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          debugPrint("Terms clicked");
                                        },
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          debugPrint("Privacy clicked");
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildStaggered(
                        index: 8,
                        child: SizedBox(
                          width: double.infinity,
                          height: 67.99,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                188,
                                241,
                                224,
                                228,
                              ),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (!_agreeTerms) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "You must agree to the terms",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SetupProfil(
                                      prefilledFullName:
                                          _nameController.text.trim(),
                                      signupEmail:
                                          _emailController.text.trim(),
                                      signupPassword:
                                          _passwordController.text,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Create Account",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SvgPicture.asset(
                                  'lib/features/onboarding/assets/fleche.svg',
                                  width: 20,
                                  height: 20,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildStaggered(
                        index: 9,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.white.withValues(alpha: 0.10),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'or sign up with',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.40),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.white.withValues(alpha: 0.10),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildStaggered(
                        index: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSocialButton(
                              'lib/features/onboarding/assets/google.svg',
                              'Google',
                            ),
                            _buildSocialButton(
                              'lib/features/onboarding/assets/github.svg',
                              'GitHub',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildStaggered(
                        index: 11,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: 'Log In',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Syne',
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaggered({
    required int index,
    required Widget child,
    double fromY = 28,
  }) {
    final start = (0.03 + (index * 0.06)).clamp(0.0, 0.88).toDouble();
    final end = (start + 0.24).clamp(0.0, 1.0).toDouble();

    return AnimatedBuilder(
      animation: _entranceController,
      child: child,
      builder: (context, animatedChild) {
        final anim = CurvedAnimation(
          parent: _entranceController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        );

        return Opacity(
          opacity: anim.value,
          child: Transform.translate(
            offset: Offset(0, fromY * (1 - anim.value)),
            child: Transform.scale(
              scale: 0.98 + (0.02 * anim.value),
              child: animatedChild,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedEyeIcon({
    required bool isObscured,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          scale: isObscured ? 1.0 : 1.1,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedRotation(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeInOutCubic,
                turns: isObscured ? 0.0 : 0.5,
                child: SvgPicture.asset(
                  'lib/features/onboarding/assets/Icon4.svg',
                  key: ValueKey<bool>(isObscured),
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Colors.white70,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                opacity: isObscured ? 1.0 : 0.0,
                child: Transform.rotate(
                  angle: -0.85,
                  child: Container(
                    width: 2.2,
                    height: 24,
                    decoration: BoxDecoration(
                      color:  Colors.white.withValues(alpha: 0.40),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required Color hintColor,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffix,
    String? Function(String?)? validator,
    AutovalidateMode? autovalidateMode,
    String? iconPath,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: autovalidateMode,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: hintColor),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        prefixIcon: iconPath != null
            ? Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(
                  iconPath,
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Colors.white70,
                    BlendMode.srcIn,
                  ),
                ),
              )
            : null,
        suffixIcon: suffix,
      ),
    );
  }

  Widget _buildSocialButton(String iconPath, String label) {
    return Container(
      width: 166.92,
      height: 51.988,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 0.752,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextButton.icon(
        onPressed: () {
          debugPrint("$label SignIn Clicked");
        },
        icon: SvgPicture.asset(
          iconPath,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        label: Text(
          label,
          style: const TextStyle(
            color: Color.fromRGBO(255, 255, 255, 0.8),
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 20 / 14,
            letterSpacing: -0.15,
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 147,
        height: 48,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: SvgPicture.asset(
                'lib/features/onboarding/assets/logo.svg',
                width: 51,
                height: 39,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const Positioned(
              left: 32,
              top: 24,
              child: SizedBox(
                width: 115,
                height: 24,
                child: Text(
                  'NEUROVA',
                  style: TextStyle(
                    color: Color(0xFFFFFFF0),
                    fontSize: 20,
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
