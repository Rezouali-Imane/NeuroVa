import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';

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

    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/forgot-password');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text.trim()}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _successMessage = "A password reset link has been sent to your email.";
        });

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) context.go('/login');
        });
      } else {
        throw Exception(responseData['message'] ?? 'Failed to send reset link.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '').trim();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13111A),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 16,
              child: TextButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
                label: const Text("Back to login", style: TextStyle(color: Colors.white70, fontSize: 15)),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "NEUROVA",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFFFF0),
                          letterSpacing: 2.0,
                        ),
                      ),

                      const SizedBox(height: 60),

                      const Text(
                        "Forgot Password",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Enter your email and we'll send you\na reset link",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFAFAFAF),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.send,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Email address",
                            labelStyle: const TextStyle(color: Color(0xFFAFAFAF)),
                            prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFFAFAFAF)),
                            filled: true,
                            fillColor: const Color(0xFF1E1E1E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF05BFDB), width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return "Please enter your email";
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) return "Please enter a valid email";
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 32),

                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 14), textAlign: TextAlign.center),
                        ),

                      if (_successMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(_successMessage!, style: const TextStyle(color: Colors.greenAccent, fontSize: 14), textAlign: TextAlign.center),
                        ),

                      const SizedBox(height: 24),

                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFC8A2C8), Color(0xFFB07AB0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendResetLink,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Send Reset Link",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                                  ],
                                ),
                        ),
                      ),
                    ],
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