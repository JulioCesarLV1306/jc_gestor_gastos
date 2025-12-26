import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String? id;
  final String userId;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final bool isRecurrent;
  final DateTime createdAt;

  ExpenseModel({
    this.id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    this.isRecurrent = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convertir a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'description': description,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'isRecurrent': isRecurrent,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Crear desde Map de Firestore
  factory ExpenseModel.fromMap(Map<String, dynamic> map, String id) {
    return ExpenseModel(
      id: id,
      userId: map['userId'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      isRecurrent: map['isRecurrent'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Copiar con nuevos valores
  ExpenseModel copyWith({
    String? id,
    String? userId,
    String? description,
    double? amount,
    String? category,
    DateTime? date,
    bool? isRecurrent,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      isRecurrent: isRecurrent ?? this.isRecurrent,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
