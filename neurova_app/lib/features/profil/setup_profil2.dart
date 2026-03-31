import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'setup_profil3.dart';

class SetupProfil2 extends StatefulWidget {
  const SetupProfil2({super.key});

  @override
  State<SetupProfil2> createState() => _SetupProfil2State();
}

class _SetupProfil2State extends State<SetupProfil2> {
  int selectedIndex = 0;
  String? selectedField;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13111A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
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
                  Row(
                    children: [
                      dot(false),
                      const SizedBox(width: 6),
                      bar(),
                      const SizedBox(width: 6),
                      dot(false),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Your Academics',
                style: TextStyle(
                  color: Color(0xFFFFFFF0),
                  fontSize: 32,
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Helps your AI assistant find the right resources',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontFamily: 'Inter',
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Field of study',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              buildFieldDropdown(),
              const SizedBox(height: 20),
              const Text(
                'University',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              buildSearchField(),
              const SizedBox(height: 20),
              buildCard(0, "Université de Béjaïa", "Béjaïa, Algeria"),
              const SizedBox(height: 10),
              buildCard(1, "USTHB", "Alger, Algeria"),
              const SizedBox(height: 10),
              buildCard(2, "Université Tizi Ouzou", "Tizi Ouzou, Algeria"),
              const SizedBox(height: 10),
              buildCard(3, "ESI Alger", "Alger, Algeria"),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8A2C8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SetupProfile3Page(),
                      ),
                    );
                  },
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFFFF0),
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

  Widget buildFieldDropdown() {
    return Container(
      width: double.infinity,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: ShapeDecoration(
        color: const Color(0x5B2A2440),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0x3FECEBBD)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedField,
          hint: const Text(
            "Select your major",
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontFamily: 'Syne',
              fontWeight: FontWeight.w700,
            ),
          ),
          dropdownColor: const Color(0xFF13111A),
          icon: SvgPicture.asset(
            'lib/features/onboarding/assets/vector1.svg',
            width: 17,
            height: 9,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
          items: [
            "Computer Science",
            "Medicine",
            "Engineering",
            "Business",
          ].map((field) {
            return DropdownMenuItem(
              value: field,
              child: Text(
                field,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedField = value;
            });
          },
        ),
      ),
    );
  }

  Widget buildSearchField() {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: const Color(0x5B2A2440),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: TextField(
        controller: searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search university...",
          hintStyle: const TextStyle(color: Color(0xFF6B7280)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  Widget buildCard(int index, String name, String city) {
    bool selected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
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
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Syne',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  city,
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

  Widget dot(bool active) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget bar() {
    return Container(
      width: 32,
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFF0),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}