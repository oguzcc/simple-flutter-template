import 'package:daisy/core/config/purchase_config.dart';
import 'package:daisy/core/manager/validation/models/validation_result.dart';

class PurchaseValidator {
  const PurchaseValidator._();

  static Future<List<ValidationResult>> validate() async {
    final results = <ValidationResult>[];
    final isDummyMode = PurchaseConfig.isDummyMode;

    results.add(
      ValidationResult(
        category: 'Purchase',
        item: 'RevenueCat API Key',
        isValid: !isDummyMode,
        status: isDummyMode
            ? ValidationStatus.dummy
            : ValidationStatus.production,
        description: isDummyMode
            ? 'Using dummy RevenueCat API key'
            : 'Using production RevenueCat API key',
        recommendation: isDummyMode
            ? 'Replace with actual RevenueCat public API key from dashboard'
            : null,
      ),
    );

    results.add(
      ValidationResult(
        category: 'Purchase',
        item: 'Entitlements',
        isValid: !isDummyMode,
        status: isDummyMode
            ? ValidationStatus.dummy
            : ValidationStatus.production,
        description: isDummyMode
            ? 'Using ${PurchaseConfig.dummyEntitlements.length} dummy entitlements'
            : 'Using production entitlements',
        recommendation: isDummyMode
            ? 'Configure actual entitlements in RevenueCat Dashboard'
            : null,
        metadata: {
          'entitlement_count': PurchaseConfig.dummyEntitlements.length,
          'entitlements': PurchaseConfig.dummyEntitlements.keys.toList(),
        },
      ),
    );

    results.add(
      ValidationResult(
        category: 'Purchase',
        item: 'Production Checklist',
        isValid: !isDummyMode,
        status:
            isDummyMode ? ValidationStatus.warning : ValidationStatus.valid,
        description: isDummyMode
            ? '${PurchaseConfig.productionChecklist.length} items need completion'
            : 'Production checklist completed',
        recommendation: isDummyMode
            ? 'Complete all items in PurchaseConfig.productionChecklist'
            : null,
      ),
    );

    return results;
  }
}
