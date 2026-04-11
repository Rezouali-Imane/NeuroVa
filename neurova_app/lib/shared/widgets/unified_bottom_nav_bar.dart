import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UnifiedBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onNavItemTapped;
  final bool isPositioned;

  const UnifiedBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onNavItemTapped,
    this.isPositioned = true,
  });

  @override
  Widget build(BuildContext context) {
    final navContainer = Container(
      height: 75,
      decoration: BoxDecoration(
        color: const Color(0xF40E0B16),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: const [
          BoxShadow(color: Color(0x7F000000), blurRadius: 20, offset: Offset(0, 4)),
          BoxShadow(color: Color(0xBF000000), blurRadius: 60, offset: Offset(0, 20)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: _buildNavItem(context, 0, Icons.home_outlined, 'Home', '/dashboard')),
          Expanded(child: _buildNavItem(context, 1, Icons.check_box_outlined, 'Tasks', '/tasks')),
          Expanded(child: _buildNavItem(context, 2, Icons.timer_outlined, 'Focus', '/focus')),
          Expanded(child: _buildNavItem(context, 3, Icons.auto_awesome_outlined, 'AI', '/ai')),
          Expanded(child: _buildNavItem(context, 4, Icons.person_outline, 'Profile', '/profile')),
        ],
      ),
    );

    if (isPositioned) {
      return Positioned(
        left: 16,
        right: 16,
        bottom: 14,
        child: navContainer,
      );
    }
    
    return navContainer;
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, String route) {
    bool isSelected = selectedIndex == index;
    
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        onNavItemTapped(index);
        context.go(route);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? const Color(0x14B284BE) : Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0x24B284BE) : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? const Color(0xFFB284BE) : Colors.white.withOpacity(0.50),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 8,
                  height: 1,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFFB284BE) : Colors.white.withOpacity(0.50),
                  letterSpacing: 0.20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
