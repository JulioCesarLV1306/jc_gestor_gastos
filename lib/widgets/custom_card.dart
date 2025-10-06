import 'package:blobs/blobs.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  //ontap
  final Function()? onTap;
  final String titulo;
  //subtitulo
  final String subtitulo;
  final String numeroGastos;
  final IconData? icono;
  final Color colorFondo;

  const CustomCard({
    super.key,
    this.onTap,
    required this.titulo,
    required this.numeroGastos,
    this.icono= Icons.attach_money,
    this.colorFondo = const Color(0xFFBBDEFB), 
    required this.subtitulo, // Color azul claro por defecto
  });

  @override
  Widget build(BuildContext context) {
    // Obtener el ancho de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Definir tamaños responsivos
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1200;
    
    final cardWidth = isMobile 
        ? (screenWidth - 24) / 2 // 2 cards por fila en móvil con padding
        : isTablet 
            ? (screenWidth - 48) / 2 // 2 cards por fila en tablet
            : (screenWidth - 96) / 4; // 4 cards por fila en desktop
    
    final cardHeight = isMobile ? 140.0 : isTablet ? 160.0 : 180.0;
    final titleFontSize = isMobile ? 12.0 : isTablet ? 13.0 : 14.0;
    final numberFontSize = isMobile ? 24.0 : isTablet ? 28.0 : 32.0;
    final subtitleFontSize = isMobile ? 11.0 : isTablet ? 12.0 : 13.0;
    final iconSize = isMobile ? 18.0 : isTablet ? 20.0 : 22.0;
    final blobSize = isMobile ? 35.0 : isTablet ? 38.0 : 42.0;
    final cardPadding = isMobile ? 10.0 : isTablet ? 12.0 : 14.0;
    final borderRadius = isMobile ? 16.0 : isTablet ? 18.0 : 20.0;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth - 8, // Restamos el margin
        height: cardHeight,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: colorFondo,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: colorFondo.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    titulo,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Blob.fromID(
                  id: ['5-6-43178'],
                  size: blobSize,
                  styles: BlobStyles(
                    color: Colors.white,
                    fillType: BlobFillType.stroke,
                    strokeWidth: 1,
                  ),
                  child: Icon(
                    icono,
                    size: iconSize,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                ' $numeroGastos',
                style: TextStyle(
                  fontSize: numberFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                subtitulo,
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}