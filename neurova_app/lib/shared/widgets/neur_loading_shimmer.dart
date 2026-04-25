import 'package:flutter/material.dart';
import 'neur_card.dart';

/// NeurLoadingShimmer - Skeleton loader with animated gradient sweep
class NeurLoadingShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  final bool isCircle;

  const NeurLoadingShimmer({
    super.key,
    required this.width,
    required this.height,
    this.radius = 12,
    this.isCircle = false,
  });

  @override
  State<NeurLoadingShimmer> createState() => _NeurLoadingShimmerState();
}

class _NeurLoadingShimmerState extends State<NeurLoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nc = Theme.of(context).extension<NeuropaColors>()!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius:
                widget.isCircle ? null : BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: const Alignment(-1, 0),
              end: const Alignment(1, 0),
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value.clamp(0.0, 1.0),
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
              colors: [
                nc.surface,
                nc.surfaceElevated,
                nc.surface,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// NeurLoadingShimmerList - Multiple shimmer items stacked
class NeurLoadingShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;

  const NeurLoadingShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(
          bottom: index < itemCount - 1 ? spacing : 0,
          left: 20,
          right: 20,
        ),
        child: NeurLoadingShimmer(
          width: double.infinity,
          height: itemHeight,
          radius: 16,
        ),
      ),
    );
  }
}

/// NeurCardShimmer - Skeleton card with multiple lines (e.g., for lists)
class NeurCardShimmer extends StatelessWidget {
  final bool hasAvatar;
  final int lineCount;

  const NeurCardShimmer({
    super.key,
    this.hasAvatar = true,
    this.lineCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final nc = Theme.of(context).extension<NeuropaColors>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: nc.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with optional avatar
          Row(
            children: [
              if (hasAvatar)
                NeurLoadingShimmer(
                  width: 48,
                  height: 48,
                  radius: 24,
                  isCircle: true,
                ),
              if (hasAvatar) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NeurLoadingShimmer(
                      width: 150,
                      height: 14,
                      radius: 8,
                    ),
                    const SizedBox(height: 8),
                    NeurLoadingShimmer(
                      width: 100,
                      height: 10,
                      radius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Content lines
          ...List.generate(
            lineCount,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index < lineCount - 1 ? 8 : 0),
              child: NeurLoadingShimmer(
                width: index == lineCount - 1
                    ? 200
                    : double.infinity,
                height: 12,
                radius: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
