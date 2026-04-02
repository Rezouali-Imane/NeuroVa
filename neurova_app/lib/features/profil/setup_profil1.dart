import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'setup_profil2.dart';
import '../onboarding/background.dart';
import '../../shared/widgets/entry_reveal.dart';

class SetupProfil extends StatefulWidget {
  const SetupProfil({super.key, this.prefilledFullName = ''});

  final String prefilledFullName;

  @override
  State<SetupProfil> createState() => _SetupProfilState();
}

class _SetupProfilState extends State<SetupProfil> {
  final _picker = ImagePicker();
  static const _takenUsernames = {
    'admin',
    'neurova',
    'test',
    'user',
  };

  File? _selectedImage;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+213');
  final _bioController = TextEditingController();
  bool? _isUsernameAvailable;
  int _currentStep = -1;

  @override
  void initState() {
    super.initState();
    final (firstName, lastName) = _splitFullName(widget.prefilledFullName);
    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _firstNameController.addListener(_onNameChanged);
    _lastNameController.addListener(_onNameChanged);
    _usernameController.addListener(_onUsernameChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _currentStep = 0;
      });
    });
  }

  void _onNameChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _onUsernameChanged() {
    final raw = _usernameController.text.trim().replaceFirst('@', '');

    bool? nextState;
    if (raw.isEmpty) {
      nextState = null;
    } else {
      final isValid = RegExp(r'^[a-zA-Z0-9_.]{3,20}$').hasMatch(raw);
      nextState = isValid && !_takenUsernames.contains(raw.toLowerCase());
    }

    if (_isUsernameAvailable != nextState && mounted) {
      setState(() {
        _isUsernameAvailable = nextState;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_onNameChanged);
    _lastNameController.removeListener(_onNameChanged);
    _usernameController.removeListener(_onUsernameChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _showPhotoSourceSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1725),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white70,
                  ),
                  title: const Text(
                    'Camera',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickFromCamera();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: Colors.white70,
                  ),
                  title: const Text(
                    'Gallery',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getInitials() {
    final first = _firstNameController.text;
    final last = _lastNameController.text;
    if (first.isEmpty && last.isEmpty) return '';
    return '${first.isNotEmpty ? first[0] : ''}'
            '${last.isNotEmpty ? last[0] : ''}'
        .toUpperCase();
  }

  Widget _photoButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontFamily: 'Syne',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _goToNextStep() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 520),
        reverseTransitionDuration: const Duration(milliseconds: 520),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SetupProfil2(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.985, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OnboardingBackground(
        child: SafeArea(
          child: EntryReveal(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final scale = (constraints.maxHeight / 860).clamp(0.8, 1.0);

                  return Align(
                    alignment: Alignment.topCenter,
                    child: Transform.scale(
                      alignment: Alignment.topCenter,
                      scale: scale,
                      child: SizedBox(
                          width: constraints.maxWidth / scale,
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 160,
                                  height: 48,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: SvgPicture.asset(
                                          'lib/features/onboarding/assets/logo.svg',
                                          width: 51.0,
                                          height: 39.0,
                                          colorFilter: const ColorFilter.mode(
                                            Colors.white,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                      const Positioned(
                                        left: 30,
                                        top: 28,
                                        child: Text(
                                          'NEUROVA',
                                          style: TextStyle(
                                            color: Color(0xFFFFFFF0),
                                            fontSize: 15,
                                            fontFamily: 'Syne',
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildStepIndicator(_currentStep),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "Set Up Your Profile",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "How others will see you on Neurova",
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: GestureDetector(
                                onTap: _showPhotoSourceSheet,
                                child: SizedBox(
                                  width: 122,
                                  height: 122,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 122,
                                        height: 122,
                                        child: CustomPaint(
                                          painter: DashedCirclePainter(),
                                        ),
                                      ),
                                      Container(
                                        width: 104,
                                        height: 104,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF2A2440),
                                        ),
                                        child: _selectedImage != null
                                            ? ClipOval(
                                                child: Image.file(
                                                  _selectedImage!,
                                                  fit: BoxFit.cover,
                                                  width: 104,
                                                  height: 104,
                                                ),
                                              )
                                            : Center(
                                                child: Text(
                                                  _getInitials(),
                                                  style: const TextStyle(
                                                    color: Color(0xFFB284BE),
                                                    fontSize: 28,
                                                    fontFamily: 'Syne',
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                      ),
                                      Positioned(
                                        bottom: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: _showPhotoSourceSheet,
                                          child: Container(
                                            width: 28,
                                            height: 28,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFF2A2440),
                                            ).copyWith(
                                              border: Border.all(
                                                color: Colors.white.withValues(
                                                  alpha: 0.15,
                                                ),
                                                width: 1,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.camera_alt_outlined,
                                              size: 15,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Center(
                              child: Text(
                                "Add a profile photo",
                                style: TextStyle(color: Color(0xFF9CA3AF)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _photoButton(
                                    'Camera',
                                    Icons.camera_alt_outlined,
                                    () {
                                      _pickFromCamera();
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  _photoButton(
                                    'Gallery',
                                    Icons.photo_library_outlined,
                                    () {
                                      _pickFromGallery();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: buildField(
                                    "First Name",
                                    controller: _firstNameController,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: buildField(
                                    "Last Name",
                                    controller: _lastNameController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            buildField(
                              "Username",
                              controller: _usernameController,
                              prefix: "@",
                              suffix: _isUsernameAvailable == null
                                ? null
                                : _isUsernameAvailable!
                                ? 'Available'
                                : 'Unavailable',
                              borderColor: _isUsernameAvailable == null
                                ? null
                                : _isUsernameAvailable!
                                ? const Color.fromRGBO(236, 235, 189, 0.953)
                                : const Color.fromARGB(255, 229, 143, 143),
                              suffixColor: _isUsernameAvailable == null
                                ? null
                                : _isUsernameAvailable!
                                ? const Color.fromRGBO(236, 235, 189, 0.953)
                                : const Color.fromARGB(255, 229, 143, 143),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Must be unique · letters, numbers, underscores only',
                              style: TextStyle(
                                color: Color(0xFF4B5563),
                                fontSize: 10,
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w500,
                                height: 1.50,
                              ),
                            ),
                            const SizedBox(height: 10),
                            buildField(
                              "Phone Number",
                              controller: _phoneController,
                              prefixIcon: SizedBox(
                                width: 18,
                                height: 18,
                                child: Center(
                                  child: SvgPicture.asset(
                                    'lib/features/onboarding/assets/phone.svg',
                                    width: 22,
                                    height: 20,
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFF9CA3AF),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Add Your Bio",
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              maxLines: 2,
                              controller: _bioController,
                              style: const TextStyle(color: Colors.white),
                              decoration: inputDecoration(
                                hint: "CS student · building things...",
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
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
                                  _goToNextStep();
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Continue',
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
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildStepIndicator(int currentPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == currentPage;
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          opacity: isActive ? 1.0 : 0.85,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isActive ? 1.0 : 0.30),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : const [],
            ),
          ),
        );
      }),
    );
  }

  static (String, String) _splitFullName(String fullName) {
    final normalized = fullName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) {
      return ('', '');
    }

    final parts = normalized.split(' ');
    if (parts.length == 1) {
      return (parts.first, '');
    }

    return (parts.first, parts.sublist(1).join(' '));
  }

  static Widget buildField(
    String label, {
    required TextEditingController controller,
    String? prefix,
    String? suffix,
    Widget? prefixIcon,
    Color? borderColor,
    Color? suffixColor,
  }) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      controller: controller,
      decoration: inputDecoration(
        hint: label,
        prefix: prefix,
        suffix: suffix,
        prefixIcon: prefixIcon,
        borderColor: borderColor,
        suffixColor: suffixColor,
      ),
    );
  }

  static InputDecoration inputDecoration({
    String? hint,
    String? prefix,
    String? suffix,
    Widget? prefixIcon,
    Color? borderColor,
    Color? suffixColor,
  }) {
    final effectiveBorderColor = borderColor ?? const Color(0x3FECEBBD);
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 12,
        fontFamily: 'Syne',
        fontWeight: FontWeight.w700,
        letterSpacing: 0.60,
      ),
      prefixText: prefix,
      suffixText: suffix,
      prefixIcon: prefixIcon,
      isDense: true,
      contentPadding: const EdgeInsets.only(
        top: 12,
        left: 15,
        right: 16,
        bottom: 12,
      ),
      filled: true,
      fillColor: const Color(0x5B2A2440),
      suffixStyle: TextStyle(
        color: suffixColor ?? const Color(0xFFECEBBD),
        fontSize: 12,
        fontFamily: 'Syne',
        fontWeight: FontWeight.w700,
      ),
      prefixStyle: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 14,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: effectiveBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: effectiveBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: effectiveBorderColor, width: 1.4),
      ),
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFA2ADD0)
      ..strokeWidth = 2.3
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    const dashCount = 28;
    const dashAngle = pi * 2 / dashCount;
    const gapRatio = 0.45;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * (1 - gapRatio);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DashedCirclePainter old) => false;
}
