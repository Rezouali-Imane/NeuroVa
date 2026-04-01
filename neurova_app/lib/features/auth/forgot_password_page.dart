import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'confirm_mail.dart';
import '../onboarding/background.dart';
import '../../shared/widgets/entry_reveal.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _successMessage = "Email sent successfully!";
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmEmailPage(email: _emailController.text.trim()),
      ),
    );
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
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
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
                    "Back to login",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ),
              ),

              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    const Text(
                      "NEUROVA",
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      left: MediaQuery.of(context).size.width / 2 - 80,
                      top: -25,
                      child: SvgPicture.asset(
                        'lib/features/onboarding/assets/logo.svg',
                        width: 51,
                        height: 39,
                      ),
                    ),
                  ],
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

                          const Text(
                            "Forgot",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFFFFFF0),
                              fontSize: 54,
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w800,
                              height: 0.95,
                              letterSpacing: -0.6,
                            ),
                          ),

                          const Text(
                            "Password",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFFFFFF0),
                              fontSize: 54,
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w800,
                              height: 0.95,
                              letterSpacing: -0.6,
                            ),
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            "Enter your email and we'll send you a reset link",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFFFFFF0),
                              fontSize: 16,
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 30),

                          Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Email address",
                                labelStyle: TextStyle(color: hintColor),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SvgPicture.asset(
                                    'lib/features/onboarding/assets/Icon2.svg',
                                    width: 20,
                                    height: 20,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white70,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return "Email is required";
                                }
                                if (!RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                ).hasMatch(v)) {
                                  return "Enter a valid email";
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          if (_errorMessage != null)
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.redAccent),
                            ),

                          if (_successMessage != null)
                            Text(
                              _successMessage!,
                              style: const TextStyle(color: Colors.greenAccent),
                            ),

                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 68,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _sendResetLink,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  188,
                                  241,
                                  224,
                                  228,
                                ),
                                foregroundColor: const Color.fromARGB(
                                  255,
                                  255,
                                  255,
                                  255,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.black,
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Send Reset Link",
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
            ],
          ),
        ),
      ),
    );
  }
}
