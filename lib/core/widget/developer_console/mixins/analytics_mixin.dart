
/// Mixin for analytics data handling and visualization
mixin AnalyticsMixin {
  /// Most tapped widgets data
  Map<String, int> _mostTappedWidgets = {};
  
  /// Most visited screens data  
  Map<String, Duration> _mostVisitedScreens = {};
  
  /// Navigation pattern data
  Map<String, dynamic> _navigationPattern = {};
  
  /// Heatmap data for UI interactions
  Map<String, Map<String, int>> _heatmapData = {};

  /// Get most tapped widgets
  Map<String, int> get mostTappedWidgets => 
      Map.unmodifiable(_mostTappedWidgets);
  
  /// Get most visited screens
  Map<String, Duration> get mostVisitedScreens => 
      Map.unmodifiable(_mostVisitedScreens);
  
  /// Get navigation patterns
  Map<String, dynamic> get navigationPattern => 
      Map.unmodifiable(_navigationPattern);
  
  /// Get heatmap data
  Map<String, Map<String, int>> get heatmapData => 
      Map.unmodifiable(_heatmapData);

  /// Initialize analytics data with mock data for demonstration
  void initializeAnalyticsData() {
    _loadMockAnalyticsData();
  }

  /// Load mock analytics data
  void _loadMockAnalyticsData() {
    _mostTappedWidgets = {
      'LoginButton': 156,
      'ProfileImage': 89,
      'NavigationDrawer': 67,
      'SearchBar': 45,
      'LogoutButton': 23,
      'SettingsIcon': 34,
      'HomeButton': 78,
      'RefreshButton': 56,
    };

    _mostVisitedScreens = {
      'Home': const Duration(minutes: 45),
      'Profile': const Duration(minutes: 23),
      'Settings': const Duration(minutes: 12),
      'About': const Duration(minutes: 8),
      'Search': const Duration(minutes: 15),
      'Login': const Duration(minutes: 5),
    };

    _navigationPattern = {
      'Home -> Profile': 34,
      'Profile -> Settings': 23,
      'Home -> Search': 19,
      'Settings -> About': 12,
      'Search -> Home': 25,
      'Login -> Home': 67,
      'Profile -> Home': 45,
    };

    _heatmapData = {
      'Home': {'center': 45, 'top': 23, 'bottom': 12, 'left': 8, 'right': 15},
      'Profile': {'center': 34, 'top': 19, 'bottom': 8, 'left': 12, 'right': 7},
      'Settings': {'center': 28, 'top': 15, 'bottom': 5, 'left': 9, 'right': 11},
    };
  }

  /// Track widget tap
  void trackWidgetTap(String widgetName) {
    _mostTappedWidgets[widgetName] = 
        (_mostTappedWidgets[widgetName] ?? 0) + 1;
  }

  /// Track screen visit
  void trackScreenVisit(String screenName, Duration duration) {
    final currentDuration = _mostVisitedScreens[screenName] ?? Duration.zero;
    _mostVisitedScreens[screenName] = currentDuration + duration;
  }

  /// Track navigation pattern
  void trackNavigation(String from, String to) {
    final pattern = '$from -> $to';
    _navigationPattern[pattern] = (_navigationPattern[pattern] ?? 0) + 1;
  }

  /// Track UI interaction for heatmap
  void trackUIInteraction(String screen, String area) {
    _heatmapData[screen] ??= {};
    _heatmapData[screen]![area] = (_heatmapData[screen]![area] ?? 0) + 1;
  }

  /// Get top widgets by tap count
  List<MapEntry<String, int>> getTopWidgets({int limit = 5}) {
    final entries = _mostTappedWidgets.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }

  /// Get top screens by visit duration
  List<MapEntry<String, Duration>> getTopScreens({int limit = 5}) {
    final entries = _mostVisitedScreens.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }

  /// Get navigation flow data
  List<MapEntry<String, dynamic>> getNavigationFlow({int limit = 10}) {
    final entries = _navigationPattern.entries.toList()
      ..sort((a, b) => (b.value as int).compareTo(a.value as int));
    return entries.take(limit).toList();
  }

  /// Clear analytics data
  void clearAnalyticsData() {
    _mostTappedWidgets.clear();
    _mostVisitedScreens.clear();
    _navigationPattern.clear();
    _heatmapData.clear();
  }

  /// Export analytics data to JSON-like format
  Map<String, dynamic> exportAnalyticsData() {
    return {
      'mostTappedWidgets': _mostTappedWidgets,
      'mostVisitedScreens': _mostVisitedScreens.map(
        (key, value) => MapEntry(key, value.inMilliseconds),
      ),
      'navigationPattern': _navigationPattern,
      'heatmapData': _heatmapData,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Import analytics data from JSON-like format
  void importAnalyticsData(Map<String, dynamic> data) {
    final tappedWidgetsData = data['mostTappedWidgets'] as Map<String, dynamic>? ?? {};
    _mostTappedWidgets = Map<String, int>.from(tappedWidgetsData);
    
    final screenData = data['mostVisitedScreens'] as Map<String, dynamic>? ?? {};
    _mostVisitedScreens = screenData.map(
      (key, value) => MapEntry(key, Duration(milliseconds: value as int)),
    );
    
    final navigationData = data['navigationPattern'] as Map<String, dynamic>? ?? {};
    _navigationPattern = Map<String, dynamic>.from(navigationData);
    
    _heatmapData = (data['heatmapData'] as Map<String, dynamic>? ?? {}).map(
      (key, value) => MapEntry(
        key, 
        Map<String, int>.from(value as Map<String, dynamic>),
      ),
    );
  }
}
