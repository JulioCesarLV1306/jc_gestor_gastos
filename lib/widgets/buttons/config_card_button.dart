import 'package:flutter/material.dart';

/// Botón tipo card moderno para configuraciones (Presupuesto, Ahorro, etc.)
/// 
/// Widget reutilizable con diseño glassmorphism y gradientes personalizables.
/// Ideal para pantallas de configuración y dashboards.
class ConfigCardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final double value;
  final Gradient gradient;
  final Color iconColor;
  final VoidCallback onPressed;
  final String? valuePrefix;
  final int? valueDecimals;

  const ConfigCardButton({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.gradient,
    required this.iconColor,
    required this.onPressed,
    this.valuePrefix = '\$',
    this.valueDecimals = 2,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 1200;
        
        // Tamaños responsivos
        final borderRadius = isMobile ? 20.0 : isTablet ? 24.0 : 28.0;
        final horizontalPadding = isMobile ? 16.0 : isTablet ? 20.0 : 24.0;
        final verticalPadding = isMobile ? 16.0 : isTablet ? 18.0 : 20.0;
        final iconSize = isMobile ? 24.0 : isTablet ? 28.0 : 32.0;
        final iconContainerSize = isMobile ? 48.0 : isTablet ? 56.0 : 64.0;
        final labelFontSize = isMobile ? 16.0 : isTablet ? 17.0 : 18.0;
        final subtitleFontSize = isMobile ? 12.0 : isTablet ? 13.0 : 14.0;
        final valueFontSize = isMobile ? 20.0 : isTablet ? 22.0 : 24.0;
        
        return Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Row(
                  children: [
                    // Icono con contenedor glassmorphism
                    _buildIconContainer(
                      iconContainerSize: iconContainerSize,
                      iconSize: iconSize,
                    ),
                    SizedBox(width: isMobile ? 12 : isTablet ? 16 : 20),
                    // Información
                    Expanded(
                      child: _buildInfoSection(
                        labelFontSize: labelFontSize,
                        subtitleFontSize: subtitleFontSize,
                      ),
                    ),
                    // Valor con diseño minimalista
                    _buildValueSection(
                      isMobile: isMobile,
                      isTablet: isTablet,
                      valueFontSize: valueFontSize,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconContainer({
    required double iconContainerSize,
    required double iconSize,
  }) {
    return Container(
      width: iconContainerSize,
      height: iconContainerSize,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: iconSize,
      ),
    );
  }

  Widget _buildInfoSection({
    required double labelFontSize,
    required double subtitleFontSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: subtitleFontSize,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.85),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildValueSection({
    required bool isMobile,
    required bool isTablet,
    required double valueFontSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : isTablet ? 14 : 16,
            vertical: isMobile ? 8 : isTablet ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '$valuePrefix${value.toStringAsFixed(valueDecimals!)}',
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w900,
              color: iconColor,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: isMobile ? 12 : 14,
          ),
        ),
      ],
    );
  }
}
