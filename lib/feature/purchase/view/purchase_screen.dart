import 'package:daisy/feature/purchase/cubit/purchase_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// Purchase screen — RevenueCat native paywall'ını göstermek için ince wrapper.
///
/// Ekran açıldığında RevenueCat dashboard'unda yapılandırılmış paywall'u
/// full-screen modal olarak gösterir. Paywall kapandıktan sonra:
/// - Satın alma yapıldıysa: [PurchaseCubit.refresh] state'i günceller ve
///   çağıran route geri push edilir
/// - İptal edilirse: sessizce geri döner
///
/// Custom paywall UI'ı istiyorsan bu widget'ı kendi tasarımınla değiştir;
/// cubit API'si (initialize/refresh/checkEntitlement) değişmeden kalır.
class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _presentPaywall());
  }

  Future<void> _presentPaywall() async {
    final cubit = context.read<PurchaseCubit>();
    if (!cubit.state.isInitialized) {
      await cubit.initialize();
    }

    final result = await RevenueCatUI.presentPaywall();

    if (!mounted) return;
    if (result == PaywallResult.purchased || result == PaywallResult.restored) {
      await cubit.refresh();
    }

    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
