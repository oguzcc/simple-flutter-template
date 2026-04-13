import 'dart:developer' as developer;

import 'package:daisy/core/manager/validation/models/validation_result.dart';

/// Specialized logger for configuration validation
class ValidationLogger {
  static const String _loggerName = 'ConfigValidation';
  static const String _resetColor = '\x1B[0m';
  static const String _boldColor = '\x1B[1m';
  static const String _underlineColor = '\x1B[4m';

  /// Log validation summary
  static void logSummary(ValidationSummary summary) {
    _logHeader('🔍 Configuration Validation Summary');

    developer.log(
      '''
${_boldColor}Total Checks: ${summary.totalChecks}$_resetColor
${ValidationStatus.valid.colorCode}✅ Valid: ${summary.validCount}$_resetColor
${ValidationStatus.warning.colorCode}⚠️  Warnings: ${summary.warningCount}$_resetColor
${ValidationStatus.invalid.colorCode}❌ Issues: ${summary.invalidCount}$_resetColor

${_boldColor}Production Ready: ${summary.isProductionReady ? '✅ Yes' : '❌ No'}$_resetColor
${_boldColor}Timestamp: ${summary.timestamp.toIso8601String()}$_resetColor
''',
      name: _loggerName,
    );
  }

  /// Log category results
  static void logCategoryResults(
    String category,
    List<ValidationResult> results,
  ) {
    if (results.isEmpty) return;

    _logSubHeader('📋 $category');

    for (final result in results) {
      final status = result.status;
      final icon = status.icon;
      final color = status.colorCode;

      developer.log(
        '$color$icon ${result.item}: ${status.description}$_resetColor',
        name: _loggerName,
      );

      if (result.description?.isNotEmpty ?? false) {
        developer.log(
          '   📝 ${result.description}',
          name: _loggerName,
        );
      }

      if (result.recommendation?.isNotEmpty ?? false) {
        developer.log(
          '   💡 ${result.recommendation}',
          name: _loggerName,
        );
      }

      if (result.metadata?.isNotEmpty ?? false) {
        developer.log(
          '   📊 Metadata: ${result.metadata}',
          name: _loggerName,
        );
      }
    }
  }

  /// Log missing configurations
  static void logMissingConfigurations(
    List<ValidationResult> missingItems,
  ) {
    if (missingItems.isEmpty) {
      _logSuccess('🎉 No missing configurations found!');
      return;
    }

    _logHeader('❌ Missing Configurations');

    for (final item in missingItems) {
      developer.log(
        '${ValidationStatus.missing.colorCode}❌ ${item.category}: ${item.item}$_resetColor',
        name: _loggerName,
      );

      if (item.recommendation?.isNotEmpty ?? false) {
        developer.log(
          '   💡 ${item.recommendation}',
          name: _loggerName,
        );
      }
    }
  }

  /// Log dummy/development configurations
  static void logDummyConfigurations(
    List<ValidationResult> dummyItems,
  ) {
    if (dummyItems.isEmpty) {
      _logSuccess('🎉 No dummy configurations found!');
      return;
    }

    _logHeader('⚠️ Dummy/Development Configurations');

    developer.log(
      '${ValidationStatus.warning.colorCode}The following configurations are using dummy/development values:$_resetColor',
      name: _loggerName,
    );

    for (final item in dummyItems) {
      developer.log(
        '${ValidationStatus.dummy.colorCode}⚠️  ${item.category}: ${item.item}$_resetColor',
        name: _loggerName,
      );

      if (item.recommendation?.isNotEmpty ?? false) {
        developer.log(
          '   💡 ${item.recommendation}',
          name: _loggerName,
        );
      }
    }
  }

  /// Log production readiness checklist
  static void logProductionChecklist(
    List<String> checklist,
    String category,
  ) {
    _logSubHeader('📋 $category Production Checklist');

    for (final item in checklist) {
      developer.log(
        '  $item',
        name: _loggerName,
      );
    }
  }

  /// Log environment warnings
  static void logEnvironmentWarnings() {
    _logHeader('⚠️ Environment Warnings');

    developer.log(
      '''
${ValidationStatus.warning.colorCode}⚠️  This app is running with development configurations.$_resetColor
${ValidationStatus.warning.colorCode}⚠️  Some features may not work properly until production setup is complete.$_resetColor
${ValidationStatus.warning.colorCode}⚠️  Please review the production checklists above before deployment.$_resetColor
''',
      name: _loggerName,
    );
  }

  /// Log individual validation result
  static void logResult(ValidationResult result) {
    final status = result.status;
    final color = status.colorCode;
    final icon = status.icon;

    developer.log(
      '$color$icon [${result.category}] ${result.item}: ${status.description}$_resetColor',
      name: _loggerName,
    );

    if (result.description?.isNotEmpty ?? false) {
      developer.log('   📝 ${result.description}', name: _loggerName);
    }

    if (result.recommendation?.isNotEmpty ?? false) {
      developer.log('   💡 ${result.recommendation}', name: _loggerName);
    }
  }

  /// Log validation start
  static void logValidationStart() {
    _logHeader('🚀 Starting Configuration Validation');
    developer.log(
      'Checking all environment variables, API keys, and certificates...',
      name: _loggerName,
    );
  }

  /// Log validation complete
  static void logValidationComplete({
    required bool isProductionReady,
  }) {
    _logHeader('✅ Configuration Validation Complete');

    if (isProductionReady) {
      _logSuccess('🎉 All configurations are production ready!');
    } else {
      developer.log(
        '${ValidationStatus.warning.colorCode}⚠️  Some configurations need attention before production deployment.$_resetColor',
        name: _loggerName,
      );
    }
  }

  /// Private helper methods
  static void _logHeader(String message) {
    developer.log(
      '''

$_boldColor$_underlineColor$message$_resetColor
${'=' * message.length}
''',
      name: _loggerName,
    );
  }

  static void _logSubHeader(String message) {
    developer.log(
      '''

$_boldColor$message$_resetColor
${'-' * message.length}
''',
      name: _loggerName,
    );
  }

  static void _logSuccess(String message) {
    developer.log(
      '${ValidationStatus.valid.colorCode}$message$_resetColor',
      name: _loggerName,
    );
  }
}
