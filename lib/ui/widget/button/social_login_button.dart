import 'package:daisy/data/model/auth/login_response_model.dart';
import 'package:flutter/material.dart';

/// Social login button types
enum SocialButtonType {
  apple,
  google,
  anonymous,
}

/// Social login button with platform-specific styling
/// 
/// Features:
/// - Platform-appropriate icons and colors
/// - Loading states
/// - Accessibility support
/// - Customizable styling
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    required this.type, required this.onPressed, super.key,
    this.isLoading = false,
    this.enabled = true,
    this.width,
    this.height = 50,
  });

  final SocialButtonType type;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = enabled && !isLoading;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: _getButtonStyle(theme),
        child: isLoading
            ? _LoadingIndicator(type: type)
            : _ButtonContent(type: type),
      ),
    );
  }

  ButtonStyle _getButtonStyle(ThemeData theme) {
    switch (type) {
      case SocialButtonType.apple:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        );

      case SocialButtonType.google:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!),
          ),
          elevation: 1,
        );

      case SocialButtonType.anonymous:
        return ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
          disabledBackgroundColor: Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        );
    }
  }
}

/// Button content with icon and text
class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.type});

  final SocialButtonType type;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _getIcon(),
        const SizedBox(width: 12),
        Text(
          _getText(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _getIcon() {
    switch (type) {
      case SocialButtonType.apple:
        return const Icon(
          Icons.apple,
          size: 20,
          color: Colors.white,
        );

      case SocialButtonType.google:
        // Since we don't have the Google SVG, we'll use a placeholder
        // In a real app, you'd want to include the official Google logo SVG
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
          child: const Center(
            child: Text(
              'G',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );

      case SocialButtonType.anonymous:
        return const Icon(
          Icons.person_outline,
          size: 20,
        );
    }
  }

  String _getText() {
    switch (type) {
      case SocialButtonType.apple:
        return 'Continue with Apple';
      case SocialButtonType.google:
        return 'Continue with Google';
      case SocialButtonType.anonymous:
        return 'Continue as Guest';
    }
  }
}

/// Loading indicator for social buttons
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({required this.type});

  final SocialButtonType type;

  @override
  Widget build(BuildContext context) {
    Color indicatorColor;
    switch (type) {
      case SocialButtonType.apple:
        indicatorColor = Colors.white;
      case SocialButtonType.google:
        indicatorColor = Colors.black87;
      case SocialButtonType.anonymous:
        indicatorColor = Theme.of(context).colorScheme.onSecondary;
    }

    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
      ),
    );
  }
}

/// Social login buttons section with all options
class SocialLoginButtonsSection extends StatelessWidget {
  const SocialLoginButtonsSection({
    required this.onApplePressed, required this.onGooglePressed, required this.onAnonymousPressed, super.key,
    this.isLoading = false,
    this.loadingType,
    this.showAnonymous = true,
  });

  final VoidCallback? onApplePressed;
  final VoidCallback? onGooglePressed;
  final VoidCallback? onAnonymousPressed;
  final bool isLoading;
  final SocialButtonType? loadingType;
  final bool showAnonymous;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Apple Sign In
        SocialLoginButton(
          type: SocialButtonType.apple,
          onPressed: onApplePressed,
          isLoading: isLoading && loadingType == SocialButtonType.apple,
          enabled: !isLoading,
        ),
        
        const SizedBox(height: 12),
        
        // Google Sign In
        SocialLoginButton(
          type: SocialButtonType.google,
          onPressed: onGooglePressed,
          isLoading: isLoading && loadingType == SocialButtonType.google,
          enabled: !isLoading,
        ),
        
        if (showAnonymous) ...[
          const SizedBox(height: 12),
          
          // Anonymous/Guest Sign In
          SocialLoginButton(
            type: SocialButtonType.anonymous,
            onPressed: onAnonymousPressed,
            isLoading: isLoading && loadingType == SocialButtonType.anonymous,
            enabled: !isLoading,
          ),
        ],
      ],
    );
  }
}

/// Helper extension for SocialButtonType
extension SocialButtonTypeExtension on SocialButtonType {
  LoginType get loginType {
    switch (this) {
      case SocialButtonType.apple:
        return LoginType.apple;
      case SocialButtonType.google:
        return LoginType.google;
      case SocialButtonType.anonymous:
        return LoginType.anonymous;
    }
  }

  String get displayName {
    switch (this) {
      case SocialButtonType.apple:
        return 'Apple';
      case SocialButtonType.google:
        return 'Google';
      case SocialButtonType.anonymous:
        return 'Guest';
    }
  }
}
