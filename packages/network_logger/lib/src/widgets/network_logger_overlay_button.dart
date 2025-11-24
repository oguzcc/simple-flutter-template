import 'package:flutter/material.dart';
import 'network_log_viewer.dart';
import '../core/network_logger_service.dart';

/// Floating overlay button for network logger
class NetworkLoggerOverlayButton extends StatefulWidget {
  const NetworkLoggerOverlayButton({super.key});

  @override
  State<NetworkLoggerOverlayButton> createState() => _NetworkLoggerOverlayButtonState();
}

class _NetworkLoggerOverlayButtonState extends State<NetworkLoggerOverlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Offset _position = const Offset(20, 100);
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final logCount = NetworkLoggerService.instance.networkLogsCount;
    
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const NetworkLogViewer(),
              fullscreenDialog: true,
            ),
          );
        },
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        onPanStart: (_) {
          _isDragging = true;
          _animationController.forward();
        },
        onPanUpdate: (details) {
          if (_isDragging) {
            setState(() {
              _position = Offset(
                (_position.dx + details.delta.dx).clamp(0, screenSize.width - 60),
                (_position.dy + details.delta.dy).clamp(0, screenSize.height - 60),
              );
            });
          }
        },
        onPanEnd: (_) {
          _isDragging = false;
          _animationController.reverse();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(102, 6, 182, 212),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.network_check,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    
                    // Log count badge
                    if (logCount > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              logCount > 99 ? '99+' : logCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}