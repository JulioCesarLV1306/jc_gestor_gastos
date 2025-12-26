import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String? id;
  final String userId;
  final String category;
  final double amount;
  final String period; // 'monthly', 'weekly', 'yearly'
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;

  BudgetModel({
    this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.period,
    required this.startDate,
    this.endDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convertir a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'category': category,
      'amount': amount,
      'period': period,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Crear desde Map de Firestore
  factory BudgetModel.fromMap(Map<String, dynamic> map, String id) {
    return BudgetModel(
      id: id,
      userId: map['userId'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      period: map['period'] ?? 'monthly',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null 
        ? (map['endDate'] as Timestamp).toDate() 
        : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Copiar con nuevos valores
  BudgetModel copyWith({
    String? id,
    String? userId,
    String? category,
    double? amount,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
