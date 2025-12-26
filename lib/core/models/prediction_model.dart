import 'package:cloud_firestore/cloud_firestore.dart';

class PredictionModel {
  final String? id;
  final String userId;
  final String type; // 'expense', 'saving', 'budget_alert'
  final double predictedValue;
  final String category;
  final DateTime predictionDate;
  final double confidence; // 0.0 a 1.0
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  PredictionModel({
    this.id,
    required this.userId,
    required this.type,
    required this.predictedValue,
    required this.category,
    required this.predictionDate,
    required this.confidence,
    this.metadata,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convertir a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'predictedValue': predictedValue,
      'category': category,
      'predictionDate': Timestamp.fromDate(predictionDate),
      'confidence': confidence,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Crear desde Map de Firestore
  factory PredictionModel.fromMap(Map<String, dynamic> map, String id) {
    return PredictionModel(
      id: id,
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      predictedValue: (map['predictedValue'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      predictionDate: (map['predictionDate'] as Timestamp).toDate(),
      confidence: (map['confidence'] ?? 0).toDouble(),
      metadata: map['metadata'] as Map<String, dynamic>?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Copiar con nuevos valores
  PredictionModel copyWith({
    String? id,
    String? userId,
    String? type,
    double? predictedValue,
    String? category,
    DateTime? predictionDate,
    double? confidence,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return PredictionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      predictedValue: predictedValue ?? this.predictedValue,
      category: category ?? this.category,
      predictionDate: predictionDate ?? this.predictionDate,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
