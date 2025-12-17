import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Botón selector de fecha con diseño moderno
/// 
/// Widget reutilizable para seleccionar fechas con formato personalizable.
class DateSelectorButton extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final String label;
  final String placeholderText;
  final Color iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? labelColor;
  final IconData icon;
  final String dateFormat;

  const DateSelectorButton({
    super.key,
    required this.selectedDate,
    required this.onTap,
    this.label = 'Fecha del gasto',
    this.placeholderText = 'Seleccionar fecha',
    this.iconColor = Colors.orange,
    this.backgroundColor,
    this.borderColor,
    this.textColor = Colors.white,
    this.labelColor,
    this.icon = Icons.calendar_today_outlined,
    this.dateFormat = 'dd/MM/yyyy',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                _buildIconContainer(),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateInfo(),
                ),
                _buildArrowIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildDateInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor ?? textColor!.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          selectedDate == null
              ? placeholderText
              : DateFormat(dateFormat).format(selectedDate!),
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildArrowIcon() {
    return Icon(
      Icons.arrow_forward_ios,
      color: textColor!.withOpacity(0.5),
      size: 16,
    );
  }
}
