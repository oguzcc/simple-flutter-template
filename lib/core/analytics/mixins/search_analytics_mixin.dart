import 'package:daisy/core/analytics/analytics_service.dart';

/// Specialized mixin for search functionality analytics
/// Based on CommerceMinder's advanced search tracking patterns
mixin SearchAnalyticsMixin {
  AnalyticsService get _analytics => AnalyticsService.instance;

  /// Track search query initiation
  Future<void> trackSearchQuery({
    required String searchQuery,
    String? category,
    Map<String, String>? filters,
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackEvent(
      'search_query',
      properties: {
        'search_query': searchQuery,
        'query_length': searchQuery.length,
        'category': ?category,
        'filters': ?filters,
        ...?properties,
      },
    );
  }

  /// Track search results display
  Future<void> trackSearchResults({
    required String searchQuery,
    required int resultCount,
    required double searchTime,
    String? category,
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackEvent(
      'search_results',
      properties: {
        'search_query': searchQuery,
        'result_count': resultCount,
        'search_time_ms': searchTime,
        'has_results': resultCount > 0,
        'category': ?category,
        ...?properties,
      },
    );
  }

  /// Track search result click
  Future<void> trackSearchResultClick({
    required String searchQuery,
    required String? productId,
    required int position,
    String? category,
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackEvent(
      'search_result_click',
      properties: {
        'search_query': searchQuery,
        'product_id': productId ?? '',
        'position': position,
        'click_position': position + 1, // 1-indexed for readability
        'category': ?category,
        ...?properties,
      },
    );
  }

  /// Track search filter application
  Future<void> trackSearchFilter({
    required String searchQuery,
    required String filterType,
    required String filterValue,
    required int resultCount,
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackEvent(
      'search_filter_applied',
      properties: {
        'search_query': searchQuery,
        'filter_type': filterType,
        'filter_value': filterValue,
        'result_count_after_filter': resultCount,
        ...?properties,
      },
    );
  }

  /// Track search abandonment (no results clicked)
  Future<void> trackSearchAbandonment({
    required String searchQuery,
    required int resultCount,
    required double timeSpent,
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackEvent(
      'search_abandoned',
      properties: {
        'search_query': searchQuery,
        'result_count': resultCount,
        'time_spent_seconds': timeSpent,
        ...?properties,
      },
    );
  }

  /// Track search suggestions usage
  Future<void> trackSearchSuggestionClick({
    required String originalQuery,
    required String selectedSuggestion,
    required int suggestionPosition,
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackEvent(
      'search_suggestion_click',
      properties: {
        'original_query': originalQuery,
        'selected_suggestion': selectedSuggestion,
        'suggestion_position': suggestionPosition,
        ...?properties,
      },
    );
  }

  /// Track search autocomplete usage
  Future<void> trackSearchAutocomplete({
    required String query,
    required List<String> suggestions,
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackEvent(
      'search_autocomplete',
      properties: {
        'query': query,
        'suggestion_count': suggestions.length,
        'suggestions': suggestions.take(5).toList(), // Limit for privacy
        ...?properties,
      },
    );
  }

  /// Track voice search usage
  Future<void> trackVoiceSearch({
    required String transcribedQuery,
    required bool transcriptionSuccess,
    double? confidence,
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackEvent(
      'voice_search',
      properties: {
        'transcribed_query': transcribedQuery,
        'transcription_success': transcriptionSuccess,
        'confidence_score': ?confidence,
        ...?properties,
      },
    );
  }
}
