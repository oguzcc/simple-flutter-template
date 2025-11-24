import 'package:daisy/core/config/purchase_config.dart';
import 'package:daisy/core/enum/common_enum.dart';
import 'package:daisy/core/manager/purchase/purchase_service.dart';
import 'package:daisy/feature/purchase/cubit/purchase_cubit.dart';
import 'package:daisy/ui/widget/gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Purchase screen for managing subscriptions and premium features
/// 
/// Features:
/// - Display available subscription packages
/// - Show current subscription status
/// - Handle purchase flows
/// - Restore previous purchases
/// - Premium features showcase
class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize purchase system when screen loads
    context.read<PurchaseCubit>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Features'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PurchaseCubit>().refresh(),
          ),
        ],
      ),
      body: BlocConsumer<PurchaseCubit, PurchaseState>(
        listener: (context, state) {
          // Handle purchase success
          if (state.lastPurchaseSuccess && state.status == Status.success) {
            _showSuccessSnackBar(context, 'Purchase successful! 🎉');
          }
          
          // Handle errors
          if (state.status == Status.error && state.errorMessage != null) {
            _showErrorSnackBar(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          if (state.status == Status.loading && !state.isInitialized) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Gap.md(),
                  Text('Initializing purchase system...'),
                ],
              ),
            );
          }

          if (!state.isInitialized) {
            return _buildInitializationError(context);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Development Warning
                if (PurchaseConfig.isDummyMode) ...[
                  _buildDummyWarning(theme),
                  const Gap.lg(),
                ],

                // Current Status
                _buildCurrentStatus(state, theme),
                const Gap.lg(),

                // Premium Features
                _buildPremiumFeatures(theme),
                const Gap.lg(),

                // Available Packages
                if (state.availablePackages.isNotEmpty) ...[
                  _buildAvailablePackages(context, state, theme),
                  const Gap.lg(),
                ],

                // Action Buttons
                _buildActionButtons(context, state),

                const Gap.xl(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitializationError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const Gap.lg(),
            const Text(
              'Purchase System Unavailable',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap.md(),
            const Text(
              'The purchase system could not be initialized. This may be due to dummy credentials being used.',
              textAlign: TextAlign.center,
            ),
            const Gap.lg(),
            ElevatedButton(
              onPressed: () => context.read<PurchaseCubit>().initialize(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
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
            'Using dummy RevenueCat credentials. Purchases will not work until production credentials are configured.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.amber[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatus(PurchaseState state, ThemeData theme) {
    final statusColor = state.hasPremium || state.hasPro ? Colors.green : Colors.grey;
    final statusIcon = state.hasPremium || state.hasPro ? Icons.star : Icons.star_border;
    
    String statusText;
    if (state.hasPro) {
      statusText = 'Pro Member';
    } else if (state.hasPremium) {
      statusText = 'Premium Member';
    } else {
      statusText = 'Free Plan';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 24),
              const SizedBox(width: 12),
              Text(
                statusText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const Spacer(),
              if (state.subscriptionStatus == SubscriptionStatus.active)
                Chip(
                  label: Text(
                    _getSubscriptionStatusDisplay(state.subscriptionStatus),
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: statusColor.withValues(alpha: 0.2),
                ),
            ],
          ),
          if (state.premiumExpirationDate != null) ...[
            const Gap.sm(),
            Text(
              'Geçerlilik: ${state.premiumExpirationDate!.day}/${state.premiumExpirationDate!.month}/${state.premiumExpirationDate!.year}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: statusColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPremiumFeatures(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Premium Features',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap.md(),
        ...PurchaseConfig.premiumFeatures.map((feature) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.check, color: Colors.green, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feature,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),),
      ],
    );
  }

  Widget _buildAvailablePackages(BuildContext context, PurchaseState state, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Plan',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap.md(),
        ...state.availablePackages.map((package) => _buildPackageCard(
          context,
          package,
          state.purchaseInProgress,
          theme,
        ),),
      ],
    );
  }

  Widget _buildPackageCard(BuildContext context, Package package, bool purchaseInProgress, ThemeData theme) {
    final isPopular = package.packageType == PackageType.annual;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPopular ? theme.primaryColor : Colors.grey.withValues(alpha: 0.3),
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getPackageTitle(package.packageType),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      package.storeProduct.priceString,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const Gap.sm(),
                Text(
                  _getPackageDescription(package.packageType),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const Gap.md(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: purchaseInProgress
                        ? null
                        : () => context.read<PurchaseCubit>().purchasePackage(package),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPopular ? theme.primaryColor : null,
                      foregroundColor: isPopular ? Colors.white : null,
                    ),
                    child: purchaseInProgress
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Subscribe'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, PurchaseState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: state.status == Status.loading
              ? null
              : () => context.read<PurchaseCubit>().restorePurchases(),
          icon: const Icon(Icons.restore),
          label: const Text('Restore Purchases'),
        ),
        const Gap.sm(),
        TextButton(
          onPressed: () => _showPurchaseInfo(context),
          child: const Text('How do purchases work?'),
        ),
      ],
    );
  }

  String _getPackageTitle(PackageType type) {
    switch (type) {
      case PackageType.monthly:
        return 'Monthly Premium';
      case PackageType.annual:
        return 'Yearly Premium';
      case PackageType.lifetime:
        return 'Lifetime Access';
      default:
        return 'Premium Plan';
    }
  }

  String _getPackageDescription(PackageType type) {
    switch (type) {
      case PackageType.monthly:
        return 'Full access to all premium features. Renews monthly.';
      case PackageType.annual:
        return 'Full access to all premium features. Best value - save 58%!';
      case PackageType.lifetime:
        return 'One-time payment for lifetime access to all premium features.';
      default:
        return 'Access to premium features';
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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

  void _showPurchaseInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('How Purchases Work'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('• Subscriptions automatically renew unless cancelled'),
                Gap.sm(),
                Text('• You can cancel anytime in your device settings'),
                Gap.sm(),
                Text('• Purchases are tied to your App Store/Play Store account'),
                Gap.sm(),
                Text('• Use "Restore Purchases" if you reinstall the app'),
                Gap.sm(),
                Text('• All purchases are secure and handled by Apple/Google'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  String _getSubscriptionStatusDisplay(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return 'Aktif';
      case SubscriptionStatus.expiring:
        return 'Sona Eriyor';
      case SubscriptionStatus.none:
        return 'Pasif';
    }
  }
}
