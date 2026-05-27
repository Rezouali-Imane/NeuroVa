import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/entry_reveal.dart';
import '../onboarding/background.dart';
import 'state/auth_notifier.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String email;
  final String code;

  const ResetPasswordPage({super.key, this.email = '', this.code = ''});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
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
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.email.isEmpty || widget.code.isEmpty) {
      print('[Reset Password] Reset session expired. Please request a new code.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authNotifierProvider.notifier)
          .resetPassword(
            email: widget.email,
            code: widget.code,
            newPassword: _passwordController.text,
          );

      if (!mounted) return;

      context.go('/resetpassword-success');
    } catch (error) {
      print('[Reset Password Error] ${error.toString().replaceFirst('Exception: ', '')}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hintColor = Colors.white.withValues(alpha: 0.4);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OnboardingBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 16,
                child: _buildStaggered(
                  index: 0,
                  fromY: 10,
                  child: TextButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: SvgPicture.asset(
                      'lib/features/onboarding/assets/fleche2.svg',
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        Colors.white70,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: const Text(
                      'Back to login',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: _buildStaggered(
                  index: 1,
                  fromY: 16,
                  child: const _BrandHeader(),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: EntryReveal(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Column(
                        children: [
                          const SizedBox(height: 120),
                          _buildStaggered(
                            index: 2,
                            child: const Text(
                              'Reset',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFFFFFF0),
                                fontSize: 50,
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w800,
                                height: 0.95,
                                letterSpacing: -0.6,
                              ),
                            ),
                          ),
                          _buildStaggered(
                            index: 3,
                            child: const Text(
                              'Password',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFFFFFF0),
                                fontSize: 42,
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w800,
                                height: 0.95,
                                letterSpacing: -0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStaggered(
                            index: 4,
                            child: const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 24),
                          _buildStaggered(
                            index: 5,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'New Password',
                                      hintStyle: TextStyle(color: hintColor),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      filled: true,
                                      fillColor: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 18,
                                            horizontal: 16,
                                          ),
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: SvgPicture.asset(
                                          'lib/features/onboarding/assets/Icon3.svg',
                                          width: 20,
                                          height: 20,
                                          colorFilter: const ColorFilter.mode(
                                            Colors.white70,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                      suffixIcon: _buildAnimatedEyeIcon(
                                        isObscured: _obscurePassword,
                                        onTap: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Password is required';
                                      }
                                      if (v.length < 6) {
                                        return 'Minimum 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: _confirmController,
                                    obscureText: _obscureConfirm,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'Confirm Password',
                                      hintStyle: TextStyle(color: hintColor),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      filled: true,
                                      fillColor: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 18,
                                            horizontal: 16,
                                          ),
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: SvgPicture.asset(
                                          'lib/features/onboarding/assets/Icon3.svg',
                                          width: 20,
                                          height: 20,
                                          colorFilter: const ColorFilter.mode(
                                            Colors.white70,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                      suffixIcon: _buildAnimatedEyeIcon(
                                        isObscured: _obscureConfirm,
                                        onTap: () {
                                          setState(() {
                                            _obscureConfirm = !_obscureConfirm;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Confirm your password';
                                      }
                                      if (v != _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          _buildStaggered(
                            index: 6,
                            child: SizedBox(
                              width: double.infinity,
                              height: 67.99,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _resetPassword,
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
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.black,
                                      )
                                    : const Text(
                                        'Reset Password',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
        child: Icon(
          isObscured
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: Colors.white70,
          size: 22,
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
