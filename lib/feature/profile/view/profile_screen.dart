import 'package:cached_network_image/cached_network_image.dart';
import 'package:daisy/core/enum/common_enum.dart';
import 'package:daisy/core/extension/string_extension.dart';
import 'package:daisy/data/model/auth/login_response_model.dart';
import 'package:daisy/feature/auth/cubit/auth_cubit.dart';
import 'package:daisy/localization/locale_keys/locale_keys.g.dart';
import 'package:daisy/router/screens.dart';
import 'package:daisy/ui/widget/gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.common_profile.t)),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.authStatus == AuthStatus.unauthenticated) {
            context.goNamed(Screens.enhancedLogin.name);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LocaleKeys.auth_logoutSuccess.t),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          final currentUser = state.currentUser;
          final userDisplayName = context.read<AuthCubit>().userDisplayName;
          final isAnonymous = context.read<AuthCubit>().isAnonymous;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _ProfileAvatar(
                          photoUrl: currentUser?.photoURL,
                          isAnonymous: isAnonymous,
                          backgroundColor: theme.primaryColor,
                        ),

                        const Gap.md(),

                        // User Name
                        Text(
                          userDisplayName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const Gap.xs(),

                        Text(
                          currentUser?.email ??
                              (isAnonymous
                                  ? LocaleKeys.auth_anonymousUser.t
                                  : LocaleKeys.auth_noEmail.t),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        if (isAnonymous) ...[
                          const Gap.sm(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              LocaleKeys.auth_guestMode.t,
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const Gap.xl(),

                Text(
                  LocaleKeys.profile_account.t,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Gap.md(),

                _buildInfoCard(
                  context,
                  icon: _getLoginTypeIcon(state.loginType),
                  title: LocaleKeys.auth_loginMethod.t,
                  subtitle: _getLoginTypeDisplayName(state.loginType),
                  iconColor: _getLoginTypeColor(state.loginType),
                ),

                const Gap.md(),

                if (currentUser?.uid != null)
                  _buildInfoCard(
                    context,
                    icon: Icons.badge_outlined,
                    title: LocaleKeys.profile_userId.t,
                    subtitle: currentUser!.uid,
                    iconColor: Colors.blue,
                    isMonospace: true,
                  ),

                const Gap.xl(),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.status == Status.loading
                        ? null
                        : () => _showLogoutDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state.status == Status.loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.logout, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                LocaleKeys.auth_logout.t,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const Gap.md(),

                // Additional info for anonymous users
                if (isAnonymous) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              LocaleKeys.auth_guestAccount.t,
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          LocaleKeys.auth_guestAccountInfo.t,
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    bool isMonospace = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: isMonospace ? 'monospace' : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLoginTypeIcon(LoginType loginType) {
    switch (loginType) {
      case LoginType.apple:
        return Icons.apple;
      case LoginType.google:
        return Icons.g_mobiledata;
      case LoginType.anonymous:
        return Icons.person_outline;
      case LoginType.unknown:
      default:
        return Icons.help_outline;
    }
  }

  String _getLoginTypeDisplayName(LoginType loginType) {
    switch (loginType) {
      case LoginType.apple:
        return LocaleKeys.auth_signInWithApple.t;
      case LoginType.google:
        return LocaleKeys.auth_signInWithGoogle.t;
      case LoginType.anonymous:
        return LocaleKeys.auth_signInAnonymous.t;
      case LoginType.unknown:
      default:
        return LocaleKeys.auth_signInUnknown.t;
    }
  }

  Color _getLoginTypeColor(LoginType loginType) {
    switch (loginType) {
      case LoginType.apple:
        return Colors.black;
      case LoginType.google:
        return Colors.red;
      case LoginType.anonymous:
        return Colors.orange;
      case LoginType.unknown:
      default:
        return Colors.grey;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.logout, color: Colors.red),
              const SizedBox(width: 8),
              Text(LocaleKeys.auth_logoutConfirmTitle.t),
            ],
          ),
          content: Text(LocaleKeys.auth_logoutConfirmBody.t),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(LocaleKeys.common_cancel.t),
            ),
            ElevatedButton(
              onPressed: () {
                final authCubit = context.read<AuthCubit>();
                Navigator.of(dialogContext).pop();
                authCubit.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(LocaleKeys.auth_logout.t),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.photoUrl,
    required this.isAnonymous,
    required this.backgroundColor,
  });

  final String? photoUrl;
  final bool isAnonymous;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final fallbackIcon = Icon(
      isAnonymous ? Icons.person_outline : Icons.person,
      size: 40,
      color: Colors.white,
    );

    if (photoUrl == null || photoUrl!.isEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: backgroundColor,
        child: fallbackIcon,
      );
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: photoUrl!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        placeholder: (_, _) => CircleAvatar(
          radius: 40,
          backgroundColor: backgroundColor,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
        errorWidget: (_, _, _) => CircleAvatar(
          radius: 40,
          backgroundColor: backgroundColor,
          child: fallbackIcon,
        ),
      ),
    );
  }
}
