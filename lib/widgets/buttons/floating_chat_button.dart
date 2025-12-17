import 'package:flutter/material.dart';

/// Botón flotante de chat con animación
/// 
/// Widget reutilizable para iniciar conversaciones con IA o chatbots.
/// Incluye animación de pulso y diseño moderno.
class FloatingChatButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? heroTag;
  final bool showPulseAnimation;
  final Widget? badge;

  const FloatingChatButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.chat_bubble_outline,
    this.gradient,
    this.backgroundColor,
    this.iconColor = Colors.white,
    this.size = 60,
    this.heroTag,
    this.showPulseAnimation = true,
    this.badge,
  });

  @override
  State<FloatingChatButton> createState() => _FloatingChatButtonState();
}

class _FloatingChatButtonState extends State<FloatingChatButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.showPulseAnimation) {
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..repeat(reverse: true);

      _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  @override
  void dispose() {
    if (widget.showPulseAnimation) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonContent = _buildButtonContent();

    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.showPulseAnimation) _buildPulseEffect(),
        buttonContent,
        if (widget.badge != null)
          Positioned(
            top: 0,
            right: 0,
            child: widget.badge!,
          ),
      ],
    );
  }

  Widget _buildPulseEffect() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: widget.gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (widget.backgroundColor ?? Colors.blue).withOpacity(0.3),
                      (widget.backgroundColor ?? Colors.purple)
                          .withOpacity(0.1),
                    ],
                  ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: widget.gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.backgroundColor ?? const Color(0xFF667eea),
                widget.backgroundColor?.withOpacity(0.8) ??
                    const Color(0xFF764ba2),
              ],
            ),
        boxShadow: [
          BoxShadow(
            color: (widget.backgroundColor ?? Colors.blue).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(widget.size / 2),
          child: Center(
            child: Icon(
              widget.icon,
              color: widget.iconColor,
              size: widget.size * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// Badge para notificaciones en el botón flotante
class ChatBadge extends StatelessWidget {
  final int count;
  final Color backgroundColor;
  final Color textColor;

  const ChatBadge({
    super.key,
    required this.count,
    this.backgroundColor = Colors.red,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 20,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
