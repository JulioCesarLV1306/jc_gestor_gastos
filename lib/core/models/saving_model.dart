import 'package:cloud_firestore/cloud_firestore.dart';

class SavingModel {
  final String? id;
  final String userId;
  final String goal;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final DateTime createdAt;

  SavingModel({
    this.id,
    required this.userId,
    required this.goal,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Calcular el progreso (%)
  double get progress {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount * 100).clamp(0, 100);
  }

  // Convertir a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'goal': goal,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': Timestamp.fromDate(targetDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Crear desde Map de Firestore
  factory SavingModel.fromMap(Map<String, dynamic> map, String id) {
    return SavingModel(
      id: id,
      userId: map['userId'] ?? '',
      goal: map['goal'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0).toDouble(),
      targetDate: (map['targetDate'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Copiar con nuevos valores
  SavingModel copyWith({
    String? id,
    String? userId,
    String? goal,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    DateTime? createdAt,
  }) {
    return SavingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goal: goal ?? this.goal,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
