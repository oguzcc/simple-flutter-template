import 'package:daisy/core/config/auth_config.dart';
import 'package:daisy/core/config/app_flavor.dart';
import 'package:daisy/core/enum/common_enum.dart';
import 'package:daisy/feature/auth/cubit/auth_cubit.dart';
import 'package:daisy/router/screens.dart';
import 'package:daisy/ui/widget/button/social_login_button.dart';
import 'package:daisy/ui/widget/gap/gap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Enhanced login screen with social login capabilities
/// 
/// Features:
/// - Social login buttons (Apple, Google, Anonymous)
/// - Loading states and error handling
/// - Dummy credential warnings for development
/// - Responsive design
/// - Accessibility support
class EnhancedLoginScreen extends StatefulWidget {
  const EnhancedLoginScreen({super.key});

  @override
  State<EnhancedLoginScreen> createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends State<EnhancedLoginScreen> {
  SocialButtonType? _loadingType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            // Handle successful authentication
            if (state.authStatus == AuthStatus.authenticated) {
              _showSuccessSnackBar(context, state);
              // Navigate to home screen
              context.goNamed(Screens.home.name);
            }
            
            // Handle errors
            if (state.status == Status.error && state.errorMessage != null) {
              _showErrorSnackBar(context, state.errorMessage!);
            }
            
            // Clear loading state
            if (state.status != Status.loading) {
              setState(() {
                _loadingType = null;
              });
            }
          },
          builder: (context, state) {
            final isLoading = state.status == Status.loading;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - MediaQuery.of(context).padding.vertical - 48,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Logo and Title
                    _buildHeader(theme),
                    
                    const Gap.xl(),
                    
                    // Development Warning (if using dummy credentials)
                    if (AuthConfig.isDummyMode) ...[
                      _buildDummyWarning(theme),
                      const Gap.lg(),
                    ],
                    
                    // Authentication Status
                    if (state.authStatus != AuthStatus.initial) ...[
                      _buildAuthStatus(state, theme),
                      const Gap.lg(),
                    ],
                    
                    // Social Login Buttons
                    _buildSocialButtons(context, isLoading),
                    
                    const Gap.lg(),
                    
                    // Development Bypass Button (Debug & Development only)
                    if (kDebugMode && _isDevelopmentFlavor()) ...[
                      _buildDevelopmentBypassButton(context, theme, isLoading),
                      const Gap.lg(),
                    ],
                    
                    // Or Divider
                    _buildDivider(theme),
                    
                    const Gap.lg(),
                    
                    // Traditional Login Option
                    _buildTraditionalLoginOption(context, theme),
                    
                    const Gap.xl(),
                    
                    // Debug Information (Debug mode only)
                    if (AuthConfig.isDummyMode) _buildDebugInfo(state, theme),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // App Icon/Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.primaryColor,
          ),
          child: Icon(
            Icons.login,
            size: 40,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        
        const Gap.lg(),
        
        Text(
          'Welcome to Daisy',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const Gap.sm(),
        
        Text(
          'Sign in to continue with your account',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDummyWarning(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        border: Border.all(color: Colors.amber),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Development Mode',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Using dummy credentials. Social login will not work until production credentials are configured.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.amber[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthStatus(AuthState state, ThemeData theme) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (state.authStatus) {
      case AuthStatus.authenticating:
        statusColor = Colors.blue;
        statusIcon = Icons.hourglass_empty;
        statusText = 'Authenticating...';
      case AuthStatus.authenticated:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Successfully authenticated!';
      case AuthStatus.unauthenticated:
        if (state.errorMessage != null) {
          statusColor = Colors.red;
          statusIcon = Icons.error;
          statusText = state.errorMessage!;
        } else {
          return const SizedBox.shrink();
        }
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButtons(BuildContext context, bool isLoading) {
    return SocialLoginButtonsSection(
      onApplePressed: () => _handleSocialLogin(
        context,
        SocialButtonType.apple,
        () => context.read<AuthCubit>().signInWithApple(),
      ),
      onGooglePressed: () => _handleSocialLogin(
        context,
        SocialButtonType.google,
        () => context.read<AuthCubit>().signInWithGoogle(),
      ),
      onAnonymousPressed: () => _handleSocialLogin(
        context,
        SocialButtonType.anonymous,
        () => context.read<AuthCubit>().signInAnonymously(),
      ),
      isLoading: isLoading,
      loadingType: _loadingType,
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(child: Divider(color: theme.dividerColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: theme.dividerColor)),
      ],
    );
  }

  Widget _buildTraditionalLoginOption(BuildContext context, ThemeData theme) {
    return OutlinedButton(
      onPressed: () {
        // Navigate to traditional login screen
        // Navigator.pushNamed(context, '/traditional-login');
        _showComingSoonDialog(context);
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Sign in with Email',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDebugInfo(AuthState state, ThemeData theme) {
    return ExpansionTile(
      title: Text(
        'Debug Info',
        style: theme.textTheme.titleSmall,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _debugInfoRow('Auth Status:', state.authStatus.toString()),
              _debugInfoRow('Status:', state.status.toString()),
              _debugInfoRow('Login Type:', state.loginType.toString()),
              _debugInfoRow('Current User:', state.currentUser?.uid ?? 'None'),
              _debugInfoRow('Error:', state.errorMessage ?? 'None'),
              if (state.socialLoginResult != null) ...[
                const Gap.sm(),
                Text(
                  'Social Login Result:',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Success: ${state.socialLoginResult!.isSuccess}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  'Message: ${state.socialLoginResult!.message ?? "N/A"}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _debugInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSocialLogin(
    BuildContext context,
    SocialButtonType type,
    VoidCallback loginAction,
  ) {
    setState(() {
      _loadingType = type;
    });
    
    // Clear any previous errors
    context.read<AuthCubit>().clearError();
    
    // Perform login
    loginAction();
  }

  void _showSuccessSnackBar(BuildContext context, AuthState state) {
    var userName = 'User';
    
    if (state.currentUser?.displayName?.isNotEmpty ?? false) {
      userName = state.currentUser!.displayName!;
    } else if (state.socialLoginResult?.name?.isNotEmpty ?? false) {
      userName = state.socialLoginResult!.name!;
    } else if (state.currentUser?.email?.isNotEmpty == true) {
      userName = state.currentUser!.email!.split('@').first;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome, $userName! 🎉'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Coming Soon'),
          content: const Text(
            'Traditional email/password login will be available in a future update. '
            'For now, please use social login options or check out our premium features!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to purchase screen for demo
                Navigator.pushNamed(context, '/purchase');
              },
              child: const Text('View Premium'),
            ),
          ],
        );
      },
    );
  }

  /// Check if current flavor is development
  bool _isDevelopmentFlavor() {
    try {
      final flavor = AppFlavor.instance();
      return flavor.flavorType == FlavorType.development;
    } catch (e) {
      return false;
    }
  }

  /// Build development bypass button - only shown in debug mode + development flavor
  Widget _buildDevelopmentBypassButton(BuildContext context, ThemeData theme, bool isLoading) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9333EA).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isLoading ? null : () => _handleDevelopmentBypass(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.developer_mode,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Development Bypass',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'DEV',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle development bypass - authenticate as anonymous user and navigate to home
  void _handleDevelopmentBypass(BuildContext context) {
    // Show confirmation dialog
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.developer_mode, color: Colors.purple),
              SizedBox(width: 8),
              Text('Development Bypass'),
            ],
          ),
          content: const Text(
            'This will authenticate you anonymously and take you directly to the home screen. '
            'This feature is only available in development mode.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // For development, set authenticated state
                final authCubit = context.read<AuthCubit>();
                authCubit.setDevAuthenticated();
                // Navigation will happen automatically via listener
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Bypass Login'),
            ),
          ],
        );
      },
    );
  }
}
