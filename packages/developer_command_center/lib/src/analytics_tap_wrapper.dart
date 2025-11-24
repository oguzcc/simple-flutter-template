import 'package:flutter/material.dart';
import 'interfaces/developer_command_center_dependencies.dart';

/// Widget'ları analytics ile wrap etmek için kullanılan wrapper
class AnalyticsTapWrapper extends StatelessWidget {
  const AnalyticsTapWrapper({
    required this.child,
    required this.widgetId,
    required this.widgetType,
    required this.analyticsClient,
    this.extraData,
    this.onTap,
    super.key,
  });

  final Widget child;
  final String widgetId;
  final String widgetType;
  final AnalyticsClientInterface analyticsClient;
  final Map<String, Object>? extraData;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Analytics tap'ini kaydet
        analyticsClient.logWidgetTap(
          widgetId: widgetId,
          widgetType: widgetType,
          extraData: extraData,
        );
        
        // Original onTap callback'ini çağır
        onTap?.call();
      },
      child: child,
    );
  }
}

/// Button'lar için özel wrapper
class AnalyticsButtonWrapper extends StatelessWidget {
  const AnalyticsButtonWrapper({
    required this.child,
    required this.buttonId,
    required this.buttonText,
    required this.analyticsClient,
    this.buttonType,
    this.extraData,
    this.onPressed,
    super.key,
  });

  final Widget child;
  final String buttonId;
  final String buttonText;
  final AnalyticsClientInterface analyticsClient;
  final String? buttonType;
  final Map<String, Object>? extraData;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Analytics button click'ini kaydet
        analyticsClient.logButtonTap(
          buttonId: buttonId,
          buttonText: buttonText,
          buttonType: buttonType,
          extraData: extraData,
        );
        
        // Original onPressed callback'ini çağır
        onPressed?.call();
      },
      child: child,
    );
  }
}

/// Funnel tracking için wrapper
class FunnelStepWrapper extends StatefulWidget {
  const FunnelStepWrapper({
    required this.child,
    required this.funnelName,
    required this.stepName,
    required this.analyticsClient,
    this.autoTrigger = true,
    this.extraData,
    super.key,
  });

  final Widget child;
  final String funnelName;
  final String stepName;
  final AnalyticsClientInterface analyticsClient;
  final bool autoTrigger;
  final Map<String, Object>? extraData;

  @override 
  State<FunnelStepWrapper> createState() => _FunnelStepWrapperState();
}

class _FunnelStepWrapperState extends State<FunnelStepWrapper> {
  @override
  void initState() {
    super.initState();
    if (widget.autoTrigger) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.analyticsClient.logFunnelStep(
          funnelName: widget.funnelName,
          stepName: widget.stepName,
          extraData: widget.extraData,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}