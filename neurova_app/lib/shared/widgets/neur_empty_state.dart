import 'package:flutter/material.dart';
import 'neur_card.dart';
import 'neur_button.dart';

/// NeurEmptyState - Empty screen placeholder with icon, message, and optional action
class NeurEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? title;
  final double iconSize;

  const NeurEmptyState({
    super.key,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.title,
    this.iconSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    final nc = Theme.of(context).extension<NeuropaColors>()!;
    const kLilac = Color(0xFFC8B8E8);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with glow
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: nc.lilacSurface,
                boxShadow: [
                  BoxShadow(
                    color: kLilac.withOpacity(0.15),
                    blurRadius: 32,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: nc.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            // Title (optional)
            if (title != null) ...[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: nc.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
            ],
            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: nc.textSecondary,
                height: 1.5,
              ),
            ),
            // Action button (optional)
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              NeurButton(
                label: actionLabel!,
                onPressed: onAction!,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// NeurErrorState - Error display with retry button
class NeurErrorState extends StatelessWidget {
  final String message;
  final String? errorCode;
  final VoidCallback? onRetry;
  final bool showDetails;

  const NeurErrorState({
    super.key,
    required this.message,
    this.errorCode,
    this.onRetry,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final nc = Theme.of(context).extension<NeuropaColors>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon with red tint
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF5350).withOpacity(0.1),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 80,
                color: Color(0xFFEF5350),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              'Something went wrong',
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: nc.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: nc.textSecondary,
                height: 1.5,
              ),
            ),
            // Error code (optional, for debugging)
            if (showDetails && errorCode != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: nc.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: nc.divider),
                ),
                child: Text(
                  'Error: $errorCode',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: nc.textMuted,
                  ),
                ),
              ),
            ],
            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              NeurButton(
                label: 'Try Again',
                onPressed: onRetry!,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// NeurLoadingState - Centered loading indicator
class NeurLoadingState extends StatelessWidget {
  final String? message;

  const NeurLoadingState({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final nc = Theme.of(context).extension<NeuropaColors>()!;
    const kLilac = Color(0xFFC8B8E8);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kLilac),
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: nc.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
