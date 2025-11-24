import 'package:daisy/core/enum/status_enum.dart';
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
      appBar: AppBar(
        title: Text(LocaleKeys.common_profile.t),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          // Handle successful logout
          if (state.authStatus == AuthStatus.unauthenticated) {
            // Navigate to login screen
            context.goNamed(Screens.enhancedLogin.name);
            
            // Show logout success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully logged out'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
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
                        // Profile Picture
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: theme.primaryColor,
                          backgroundImage: currentUser?.photoURL != null 
                            ? NetworkImage(currentUser!.photoURL!)
                            : null,
                          child: currentUser?.photoURL == null 
                            ? Icon(
                                isAnonymous ? Icons.person_outline : Icons.person,
                                size: 40,
                                color: Colors.white,
                              )
                            : null,
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
                        
                        // User Email or Status
                        Text(
                          currentUser?.email ?? 
                          (isAnonymous ? 'Anonymous User' : 'No email'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        if (isAnonymous) ...[
                          const Gap.sm(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              'Guest Mode',
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
                
                // Account Actions
                Text(
                  'Account',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const Gap.md(),
                
                // Login Type Information
                _buildInfoCard(
                  context,
                  icon: _getLoginTypeIcon(state.loginType),
                  title: 'Login Method',
                  subtitle: _getLoginTypeDisplayName(state.loginType),
                  iconColor: _getLoginTypeColor(state.loginType),
                ),
                
                const Gap.md(),
                
                // User ID Information (for debug)
                if (currentUser?.uid != null)
                  _buildInfoCard(
                    context,
                    icon: Icons.badge_outlined,
                    title: 'User ID',
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
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: TextStyle(
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
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
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
                              'Guest Account',
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
                          'You are using a guest account. Your data may not be saved permanently. '
                          'Consider signing in with a social account for better experience.',
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
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
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
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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
        return 'Sign in with Apple';
      case LoginType.google:
        return 'Sign in with Google';
      case LoginType.anonymous:
        return 'Anonymous / Guest';
      case LoginType.unknown:
      default:
        return 'Unknown';
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout? You will need to sign in again to access your account.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Perform logout
                context.read<AuthCubit>().signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
