import 'package:flutter/material.dart';
import 'neur_card.dart';

/// NeurChip - Tag/filter chip with selection state
/// Selected: filled kLilac (with kLilacMuted text). Unselected: bordered kSurface
class NeurChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const NeurChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final nc = Theme.of(context).extension<NeuropaColors>()!;
    final kLilac = const Color(0xFFC8B8E8);
    final kLilacMuted = const Color(0xFF6A5890);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (backgroundColor ?? kLilac)
              : nc.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected
                ? (backgroundColor ?? kLilac)
                : nc.surface,
            width: selected ? 0 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: kLilac.withValues(alpha: 0.20),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected ? kLilacMuted : nc.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor ??
                    (selected ? kLilacMuted : nc.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// MultiSelectChipGroup - horizontal scrollable chip group for filtering
class NeurChipGroup extends StatefulWidget {
  final List<String> chips;
  final List<String> selectedChips;
  final ValueChanged<List<String>> onSelectionChanged;
  final ScrollController? scrollController;

  const NeurChipGroup({
    super.key,
    required this.chips,
    required this.selectedChips,
    required this.onSelectionChanged,
    this.scrollController,
  });

  @override
  State<NeurChipGroup> createState() => _NeurChipGroupState();
}

class _NeurChipGroupState extends State<NeurChipGroup> {
  late List<String> _selectedChips;

  @override
  void initState() {
    super.initState();
    _selectedChips = List.from(widget.selectedChips);
  }

  void _toggleChip(String chip) {
    setState(() {
      if (_selectedChips.contains(chip)) {
        _selectedChips.remove(chip);
      } else {
        _selectedChips.add(chip);
      }
    });
    widget.onSelectionChanged(_selectedChips);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: widget.scrollController,
      child: Row(
        children: [
          const SizedBox(width: 20),
          ...widget.chips.map((chip) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: NeurChip(
                  label: chip,
                  selected: _selectedChips.contains(chip),
                  onTap: () => _toggleChip(chip),
                ),
              )),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
