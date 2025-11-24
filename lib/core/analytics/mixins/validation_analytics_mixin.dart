import 'package:daisy/core/analytics/analytics_service.dart';

/// Specialized mixin for form validation analytics
/// Tracks form interactions, validation errors, and completion rates
mixin ValidationAnalyticsMixin {
  AnalyticsService get _analytics => AnalyticsService.instance;

  /// Track form field focus
  Future<void> trackFormFieldFocus({
    required String formName,
    required String fieldName,
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackEvent('form_field_focus', properties: {
      'form_name': formName,
      'field_name': fieldName,
      ...?properties,
    });
  }

  /// Track form field validation error
  Future<void> trackFormValidationError({
    required String formName,
    required String fieldName,
    required String errorType,
    String? errorMessage,
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackEvent('form_validation_error', properties: {
      'form_name': formName,
      'field_name': fieldName,
      'error_type': errorType,
      if (errorMessage != null) 'error_message': errorMessage,
      ...?properties,
    });
  }

  /// Track form submission attempt
  Future<void> trackFormSubmissionAttempt({
    required String formName,
    required Map<String, bool> fieldValidityMap,
    Map<String, dynamic>? properties,
  }) async {
    final validFieldCount = fieldValidityMap.values.where((v) => v).length;
    final totalFieldCount = fieldValidityMap.length;
    final invalidFields = fieldValidityMap.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();

    await _analytics.trackEvent('form_submission_attempt', properties: {
      'form_name': formName,
      'valid_field_count': validFieldCount,
      'total_field_count': totalFieldCount,
      'completion_rate': validFieldCount / totalFieldCount,
      'invalid_fields': invalidFields,
      'is_complete': invalidFields.isEmpty,
      ...?properties,
    });
  }

  /// Track form submission success
  Future<void> trackFormSubmissionSuccess({
    required String formName,
    required double formCompletionTime,
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackEvent('form_submission_success', properties: {
      'form_name': formName,
      'completion_time_seconds': formCompletionTime,
      ...?properties,
    });
  }

  /// Track form submission failure
  Future<void> trackFormSubmissionFailure({
    required String formName,
    required String errorType,
    String? errorMessage,
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackEvent('form_submission_failure', properties: {
      'form_name': formName,
      'error_type': errorType,
      if (errorMessage != null) 'error_message': errorMessage,
      ...?properties,
    });
  }

  /// Track form abandonment
  Future<void> trackFormAbandonment({
    required String formName,
    required double timeSpent,
    required int fieldsCompleted,
    required int totalFields,
    String? lastFocusedField,
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackEvent('form_abandoned', properties: {
      'form_name': formName,
      'time_spent_seconds': timeSpent,
      'fields_completed': fieldsCompleted,
      'total_fields': totalFields,
      'completion_percentage': (fieldsCompleted / totalFields) * 100,
      if (lastFocusedField != null) 'last_focused_field': lastFocusedField,
      ...?properties,
    });
  }

  /// Track form field auto-fill usage
  Future<void> trackFormAutoFill({
    required String formName,
    required String fieldName,
    required String autoFillType,
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackEvent('form_autofill_used', properties: {
      'form_name': formName,
      'field_name': fieldName,
      'autofill_type': autoFillType,
      ...?properties,
    });
  }

  /// Track form help/tooltip usage
  Future<void> trackFormHelpUsage({
    required String formName,
    required String fieldName,
    required String helpType, // 'tooltip', 'help_text', 'modal'
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackEvent('form_help_used', properties: {
      'form_name': formName,
      'field_name': fieldName,
      'help_type': helpType,
      ...?properties,
    });
  }

  /// Track password strength validation
  Future<void> trackPasswordStrength({
    required String formName,
    required String strengthLevel, // 'weak', 'medium', 'strong'
    required bool meetsRequirements,
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackEvent('password_strength_check', properties: {
      'form_name': formName,
      'strength_level': strengthLevel,
      'meets_requirements': meetsRequirements,
      ...?properties,
    });
  }

  /// Track multi-step form navigation
  Future<void> trackFormStepNavigation({
    required String formName,
    required int fromStep,
    required int toStep,
    required String navigationAction, // 'next', 'previous', 'jump'
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackEvent('form_step_navigation', properties: {
      'form_name': formName,
      'from_step': fromStep,
      'to_step': toStep,
      'navigation_action': navigationAction,
      'step_direction': toStep > fromStep ? 'forward' : 'backward',
      ...?properties,
    });
  }
}
