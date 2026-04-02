import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'setup_profil3.dart';
import '../onboarding/background.dart';
import '../../shared/widgets/entry_reveal.dart';

class SetupProfil2 extends StatefulWidget {
  const SetupProfil2({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.signupEmail,
    required this.signupPassword,
    this.phoneNumber,
    this.bio,
  });

  final String firstName;
  final String lastName;
  final String username;
  final String signupEmail;
  final String signupPassword;
  final String? phoneNumber;
  final String? bio;

  @override
  State<SetupProfil2> createState() => _SetupProfil2State();
}

class _SetupProfil2State extends State<SetupProfil2> {
  final List<University> _universities = [
    const University(name: 'Université de Béjaïa', location: 'Béjaïa, Algeria'),
    const University(name: 'USTHB', location: 'Alger, Algeria'),
    const University(name: 'Université Tizi Ouzou', location: 'Tizi Ouzou, Algeria'),
    const University(name: 'ESI Alger', location: 'Alger, Algeria'),
  ];

  final List<String> _fields = [
    'Computer Science',
    'Medicine',
    'Engineering',
    'Business',
    'Biology',
    'Physics',
    'Chemistry',
    'Mathematics',
  ];

  University? _selectedUniversity;
  String? selectedField;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _fieldSearchController = TextEditingController();
  bool _isFieldDropdownOpen = false;
  int _currentStep = 0;

  List<University> get _filteredUniversities {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _universities;
    }

    return _universities
        .where(
          (u) =>
              u.name.toLowerCase().contains(query) ||
              u.location.toLowerCase().contains(query),
        )
        .toList();
  }

  bool get _showAddOption =>
      _searchController.text.trim().isNotEmpty && _filteredUniversities.isEmpty;

  List<String> get _filteredFields {
    final query = _fieldSearchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _fields;
    }
    return _fields
        .where((f) => f.toLowerCase().contains(query))
        .toList();
  }

  void _commitTypedField({bool closeDropdown = true}) {
    final typed = _fieldSearchController.text.trim();
    if (typed.isEmpty) {
      if (closeDropdown) {
        setState(() {
          _isFieldDropdownOpen = false;
        });
      }
      return;
    }

    final existingMatch = _fields.cast<String?>().firstWhere(
      (f) => f!.toLowerCase() == typed.toLowerCase(),
      orElse: () => null,
    );

    setState(() {
      final selectedValue = existingMatch ?? typed;
      if (existingMatch == null) {
        _fields.add(selectedValue);
      }
      selectedField = selectedValue;
      _fieldSearchController.text = selectedValue;
      if (closeDropdown) {
        _isFieldDropdownOpen = false;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fieldSearchController.dispose();
    super.dispose();
  }

  void _addCustomUniversity() {
    final name = _searchController.text.trim();
    if (name.isEmpty) return;
    final custom = University(name: name, location: 'Custom');
    setState(() {
      _universities.add(custom);
      _selectedUniversity = custom;
      _searchController.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedUniversity = _universities.first;
    _searchController.addListener(() {
      setState(() {});
    });
    _fieldSearchController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _currentStep = 1;
      });
    });
  }

  void _goToNextStep() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 520),
        reverseTransitionDuration: const Duration(milliseconds: 520),
        pageBuilder: (context, animation, secondaryAnimation) =>
            SetupProfile3Page(
              firstName: widget.firstName,
              lastName: widget.lastName,
              username: widget.username,
              email: widget.signupEmail,
              password: widget.signupPassword,
              phoneNumber: widget.phoneNumber,
              bio: widget.bio,
              fieldOfStudy: selectedField,
              university: _selectedUniversity?.name,
            ),
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
                  final scale = (constraints.maxHeight / 900).clamp(0.80, 1.0);

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
                                          width: 51,
                                          height: 39,
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
                            const SizedBox(height: 20),
                            const Text(
                              'Your Academics',
                              style: TextStyle(
                                color: Color(0xFFFFFFF0),
                                fontSize: 32,
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Helps your AI assistant find the right resources',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontFamily: 'Inter',
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Field of study',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            buildFieldDropdown(),
                            const SizedBox(height: 16),
                            const Text(
                              'University',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            buildSearchField(),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView(
                                physics: const BouncingScrollPhysics(),
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                padding: EdgeInsets.zero,
                                children: [
                                  ..._filteredUniversities.asMap().entries.map((entry) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: entry.key == _filteredUniversities.length - 1
                                            ? 0
                                            : 12,
                                      ),
                                      child: buildCard(entry.value),
                                    );
                                  }),
                                  if (_showAddOption)
                                    GestureDetector(
                                      onTap: _addCustomUniversity,
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: const Color(0xFFB284BE).withValues(
                                              alpha: 0.4,
                                            ),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: const Color(0xFFB284BE)
                                                    .withValues(alpha: 0.15),
                                              ),
                                              child: const Icon(
                                                Icons.add,
                                                size: 16,
                                                color: Color(0xFFB284BE),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Add your university',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'Syne',
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    _searchController.text.trim(),
                                                    style: const TextStyle(
                                                      color: Colors.white38,
                                                      fontFamily: 'Syne',
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
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
                                  _commitTypedField();
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

  Widget _buildStepIndicator(int currentPage) {
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

  Widget buildFieldDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: ShapeDecoration(
            color: const Color(0x5B2A2440),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: _isFieldDropdownOpen
                    ? const Color(0xFFB284BE).withValues(alpha: 0.6)
                    : const Color(0x3FECEBBD),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _fieldSearchController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Select or type your major',
                    hintStyle: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  onTap: () {
                    setState(() {
                      _isFieldDropdownOpen = true;
                    });
                  },
                  onChanged: (_) {
                    setState(() {
                      _isFieldDropdownOpen = true;
                    });
                  },
                  onSubmitted: (_) => _commitTypedField(),
                  onEditingComplete: () => _commitTypedField(),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isFieldDropdownOpen = !_isFieldDropdownOpen;
                  });
                  if (!_isFieldDropdownOpen) {
                    _commitTypedField(closeDropdown: true);
                  }
                },
                child: AnimatedRotation(
                  turns: _isFieldDropdownOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: SvgPicture.asset(
                    'lib/features/onboarding/assets/vector1.svg',
                    width: 17,
                    height: 9,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isFieldDropdownOpen)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: ShapeDecoration(
              color: const Color(0xFF13111A),
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  color: Color(0x3FECEBBD),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      ..._filteredFields.map((field) {
                        final isSelected = selectedField == field;
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            hoverColor: const Color(0xFFB284BE)
                                .withValues(alpha: 0.18),
                            splashColor: const Color(0xFFB284BE)
                                .withValues(alpha: 0.14),
                          onTap: () {
                            setState(() {
                              selectedField = field;
                              _fieldSearchController.text = field;
                              _isFieldDropdownOpen = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            color: isSelected
                                ? const Color(0xFFB284BE).withValues(alpha: 0.15)
                                : Colors.transparent,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    field,
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFFB284BE)
                                          : Colors.white,
                                      fontFamily: 'Syne',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check,
                                    color: Color(0xFFB284BE),
                                    size: 16,
                                  ),
                              ],
                            ),
                          ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget buildSearchField() {
    return Container(
      width: double.infinity,
      height: 46,
      decoration: ShapeDecoration(
        color: const Color(0x5B2A2440),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF2D2D44)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search university...",
          hintStyle: const TextStyle(color: Color(0xFF6B7280)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              'lib/features/onboarding/assets/search.svg',
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCard(University university) {
    final selected = _selectedUniversity == university;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUniversity = university;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: ShapeDecoration(
          color: const Color(0x5B2A2440),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: selected
                  ? const Color(0xFFECEBBD)
                  : const Color(0x3FF8B878),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  university.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Syne',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  university.location,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (selected)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFECEBBD)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFECEBBD),
                      shape: BoxShape.circle,
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

class University {
  final String name;
  final String location;

  const University({required this.name, required this.location});
}
