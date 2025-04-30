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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        height: 150,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: colorFondo,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(8),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Blob.fromID(
                  id: ['5-6-43178'],
                  size: 40,
                  styles: BlobStyles(
                    color: Colors.white,
                    fillType: BlobFillType.stroke,
                    strokeWidth: 1,
                  ),
                  child: Icon(
                    icono,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ' $numeroGastos',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
             Text(
             subtitulo,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}