/// Configuration model for developer console settings
class ConsoleConfigModel {
  /// Maximum number of logs to keep in memory
  final int maxLogs;
  
  /// Auto-scroll to new logs
  final bool autoScroll;
  
  /// Show timestamp in logs
  final bool showTimestamp;
  
  /// Show source in logs
  final bool showSource;
  
  /// Enabled log filters
  final Set<String> enabledFilters;
  
  /// Network logging enabled
  final bool networkLoggingEnabled;
  
  /// Analytics tracking enabled
  final bool analyticsEnabled;
  
  /// Show floating overlay button
  final bool showFloatingButton;
  
  /// Console theme (dark/light)
  final String theme;
  
  /// Font size for console logs
  final double fontSize;
  
  /// Enable keyboard shortcuts
  final bool keyboardShortcutsEnabled;
  
  /// Persist logs across sessions
  final bool persistLogs;
  
  /// Auto-clear logs on app restart
  final bool autoClearLogs;

  const ConsoleConfigModel({
    this.maxLogs = 100,
    this.autoScroll = true,
    this.showTimestamp = true,
    this.showSource = false,
    this.enabledFilters = const {'all'},
    this.networkLoggingEnabled = true,
    this.analyticsEnabled = true,
    this.showFloatingButton = false,
    this.theme = 'dark',
    this.fontSize = 12.0,
    this.keyboardShortcutsEnabled = true,
    this.persistLogs = false,
    this.autoClearLogs = false,
  });

  /// Create default configuration
  factory ConsoleConfigModel.defaultConfig() {
    return const ConsoleConfigModel();
  }

  /// Create development configuration (more verbose)
  factory ConsoleConfigModel.development() {
    return const ConsoleConfigModel(
      maxLogs: 200,
      showSource: true,
      persistLogs: true,
      enabledFilters: {'all', 'system', 'console', 'network', 'error'},
    );
  }

  /// Create production configuration (minimal)
  factory ConsoleConfigModel.production() {
    return const ConsoleConfigModel(
      maxLogs: 50,
      showSource: false,
      persistLogs: false,
      analyticsEnabled: false,
      enabledFilters: {'error'},
    );
  }

  /// Copy with new values
  ConsoleConfigModel copyWith({
    int? maxLogs,
    bool? autoScroll,
    bool? showTimestamp,
    bool? showSource,
    Set<String>? enabledFilters,
    bool? networkLoggingEnabled,
    bool? analyticsEnabled,
    bool? showFloatingButton,
    String? theme,
    double? fontSize,
    bool? keyboardShortcutsEnabled,
    bool? persistLogs,
    bool? autoClearLogs,
  }) {
    return ConsoleConfigModel(
      maxLogs: maxLogs ?? this.maxLogs,
      autoScroll: autoScroll ?? this.autoScroll,
      showTimestamp: showTimestamp ?? this.showTimestamp,
      showSource: showSource ?? this.showSource,
      enabledFilters: enabledFilters ?? this.enabledFilters,
      networkLoggingEnabled: networkLoggingEnabled ?? this.networkLoggingEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      showFloatingButton: showFloatingButton ?? this.showFloatingButton,
      theme: theme ?? this.theme,
      fontSize: fontSize ?? this.fontSize,
      keyboardShortcutsEnabled: keyboardShortcutsEnabled ?? this.keyboardShortcutsEnabled,
      persistLogs: persistLogs ?? this.persistLogs,
      autoClearLogs: autoClearLogs ?? this.autoClearLogs,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'maxLogs': maxLogs,
      'autoScroll': autoScroll,
      'showTimestamp': showTimestamp,
      'showSource': showSource,
      'enabledFilters': enabledFilters.toList(),
      'networkLoggingEnabled': networkLoggingEnabled,
      'analyticsEnabled': analyticsEnabled,
      'showFloatingButton': showFloatingButton,
      'theme': theme,
      'fontSize': fontSize,
      'keyboardShortcutsEnabled': keyboardShortcutsEnabled,
      'persistLogs': persistLogs,
      'autoClearLogs': autoClearLogs,
    };
  }

  /// Create from JSON
  factory ConsoleConfigModel.fromJson(Map<String, dynamic> json) {
    return ConsoleConfigModel(
      maxLogs: json['maxLogs'] as int? ?? 100,
      autoScroll: json['autoScroll'] as bool? ?? true,
      showTimestamp: json['showTimestamp'] as bool? ?? true,
      showSource: json['showSource'] as bool? ?? false,
      enabledFilters: (json['enabledFilters'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toSet() ?? const {'all'},
      networkLoggingEnabled: json['networkLoggingEnabled'] as bool? ?? true,
      analyticsEnabled: json['analyticsEnabled'] as bool? ?? true,
      showFloatingButton: json['showFloatingButton'] as bool? ?? false,
      theme: json['theme'] as String? ?? 'dark',
      fontSize: json['fontSize'] as double? ?? 12.0,
      keyboardShortcutsEnabled: json['keyboardShortcutsEnabled'] as bool? ?? true,
      persistLogs: json['persistLogs'] as bool? ?? false,
      autoClearLogs: json['autoClearLogs'] as bool? ?? false,
    );
  }

  /// Validate configuration
  bool isValid() {
    return maxLogs > 0 && 
           maxLogs <= 1000 && 
           fontSize > 0 && 
           fontSize <= 24.0 &&
           ['dark', 'light'].contains(theme);
  }

  /// Get storage key for SharedPreferences
  static String get storageKey => 'developer_console_config';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConsoleConfigModel &&
        other.maxLogs == maxLogs &&
        other.autoScroll == autoScroll &&
        other.showTimestamp == showTimestamp &&
        other.showSource == showSource &&
        other.enabledFilters.toString() == enabledFilters.toString() &&
        other.networkLoggingEnabled == networkLoggingEnabled &&
        other.analyticsEnabled == analyticsEnabled &&
        other.showFloatingButton == showFloatingButton &&
        other.theme == theme &&
        other.fontSize == fontSize &&
        other.keyboardShortcutsEnabled == keyboardShortcutsEnabled &&
        other.persistLogs == persistLogs &&
        other.autoClearLogs == autoClearLogs;
  }

  @override
  int get hashCode {
    return Object.hash(
      maxLogs,
      autoScroll,
      showTimestamp,
      showSource,
      enabledFilters,
      networkLoggingEnabled,
      analyticsEnabled,
      showFloatingButton,
      theme,
      fontSize,
      keyboardShortcutsEnabled,
      persistLogs,
      autoClearLogs,
    );
  }

  @override
  String toString() {
    return 'ConsoleConfigModel('
        'maxLogs: $maxLogs, '
        'autoScroll: $autoScroll, '
        'theme: $theme, '
        'enabledFilters: $enabledFilters'
        ')';
  }
}