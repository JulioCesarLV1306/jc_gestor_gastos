import 'package:hive/hive.dart';

part 'gasto_model.g.dart';

@HiveType(typeId: 0)
class GastoModel extends HiveObject {
  @HiveField(0)
  String descripcion;

  @HiveField(1)
  double cantidad;

  @HiveField(2)
  String categoria;

  @HiveField(3)
  DateTime fecha;

  @HiveField(4)
  String? firestoreId; // ID del documento en Firestore

  @HiveField(5)
  String? userId; // ID del usuario

  GastoModel({
    required this.descripcion,
    required this.cantidad,
    required this.categoria,
    required this.fecha,
    this.firestoreId,
    this.userId,
  });

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'descripcion': descripcion,
      'cantidad': cantidad,
      'categoria': categoria,
      'fecha': fecha.toIso8601String(),
      'userId': userId,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // Crear desde Map de Firestore
  factory GastoModel.fromMap(Map<String, dynamic> map, String firestoreId) {
    return GastoModel(
      descripcion: map['descripcion'] ?? '',
      cantidad: (map['cantidad'] ?? 0).toDouble(),
      categoria: map['categoria'] ?? '',
      fecha: DateTime.parse(map['fecha']),
      firestoreId: firestoreId,
      userId: map['userId'],
    );
  }
}