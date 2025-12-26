import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:gestor_de_gastos_jc/config/services/notification_service.dart';
import 'package:gestor_de_gastos_jc/config/services/ml_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduledNotificationService {
  static final ScheduledNotificationService _instance = 
      ScheduledNotificationService._internal();
  factory ScheduledNotificationService() => _instance;
  ScheduledNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  final MLService _mlService = MLService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'gestofin',
  );

  bool _isInitialized = false;

  /// Inicializar notificaciones programadas
  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    _isInitialized = true;
    print('✅ Servicio de notificaciones programadas inicializado');
  }

  /// Programar recordatorio diario de gastos
  Future<void> scheduleDailyExpenseReminder({
    required String userId,
    required int hour,
    required int minute,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Recordatorios Diarios',
      channelDescription: 'Recordatorios para registrar gastos diarios',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Programar para la hora especificada
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Si la hora ya pasó hoy, programar para mañana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _localNotifications.zonedSchedule(
      1001, // ID único para recordatorio diario
      '📝 ¡Hora de registrar tus gastos!',
      '¿Ya registraste tus gastos de hoy? Mantén tu presupuesto bajo control.',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'expense_reminder',
    );

    print('✅ Recordatorio diario programado para las $hour:$minute');
  }

  /// Programar recordatorio semanal de gastos
  Future<void> scheduleWeeklyExpenseReminder({
    required String userId,
    required int dayOfWeek, // 1 = Lunes, 7 = Domingo
    required int hour,
    required int minute,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'weekly_reminder_channel',
      'Recordatorios Semanales',
      channelDescription: 'Resumen semanal de gastos',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Calcular próxima fecha del día de la semana
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = _nextInstanceOfDayOfWeek(dayOfWeek, hour, minute);

    await _localNotifications.zonedSchedule(
      1002, // ID único para recordatorio semanal
      '📊 Resumen Semanal de Gastos',
      'Revisa tu progreso semanal y ajusta tu presupuesto.',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'weekly_summary',
    );

    print('✅ Recordatorio semanal programado');
  }

  /// Calcular siguiente instancia de día de la semana
  tz.TZDateTime _nextInstanceOfDayOfWeek(int dayOfWeek, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }

  /// Programar notificación de recomendación de inversión
  Future<void> scheduleInvestmentRecommendation({
    required String userId,
    DateTime? scheduledTime,
  }) async {
    await initialize();

    // Si no se especifica hora, programar para dentro de 1 hora
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = scheduledTime != null
        ? tz.TZDateTime.from(scheduledTime, tz.local)
        : now.add(const Duration(hours: 1));

    try {
      // Generar recomendación usando ML
      final recommendations = await _mlService.generateSavingsRecommendations(
        userId: userId,
      );

      final recommendedAmount = recommendations['recommendedMonthlySavings'] ?? 0;
      final firstRecommendation = (recommendations['recommendations'] as List?)
          ?.isNotEmpty == true
          ? (recommendations['recommendations'] as List).first
          : null;

      String title = '💰 Recomendación de Inversión';
      String body = firstRecommendation != null
          ? firstRecommendation['description']
          : 'Ahorra al menos \$$recommendedAmount este mes';

      const androidDetails = AndroidNotificationDetails(
        'investment_channel',
        'Recomendaciones de Inversión',
        channelDescription: 'Sugerencias personalizadas de ahorro e inversión',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.zonedSchedule(
        1003, // ID único para recomendaciones
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'investment_recommendation|$userId',
      );

      print('✅ Recomendación de inversión programada');
    } catch (e) {
      print('❌ Error al programar recomendación: $e');
    }
  }

  /// Programar alerta de presupuesto excedido
  Future<void> scheduleBudgetAlert({
    required String userId,
    required String category,
    required double budgetAmount,
    required double currentAmount,
  }) async {
    await initialize();

    if (currentAmount < budgetAmount * 0.8) {
      return; // Solo alertar si se gastó más del 80%
    }

    final percentage = (currentAmount / budgetAmount * 100).toStringAsFixed(0);
    
    const androidDetails = AndroidNotificationDetails(
      'budget_alert_channel',
      'Alertas de Presupuesto',
      channelDescription: 'Notificaciones cuando estás cerca del límite',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color.fromARGB(255, 255, 0, 0),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      category.hashCode,
      '⚠️ Alerta de Presupuesto',
      'Has gastado $percentage% de tu presupuesto en $category',
      details,
      payload: 'budget_alert|$category',
    );

    print('✅ Alerta de presupuesto enviada');
  }

  /// Enviar notificación de objetivo de ahorro alcanzado
  Future<void> sendSavingsGoalReached({
    required String userId,
    required String goalName,
    required double amount,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'savings_goal_channel',
      'Metas de Ahorro',
      channelDescription: 'Notificaciones de metas alcanzadas',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      color: Color.fromARGB(255, 0, 255, 0),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      goalName.hashCode,
      '🎉 ¡Meta Alcanzada!',
      '¡Felicidades! Has completado tu meta "$goalName" de \$$amount',
      details,
      payload: 'savings_goal_reached|$goalName',
    );

    print('✅ Notificación de meta alcanzada enviada');
  }

  /// Cancelar recordatorio específico
  Future<void> cancelReminder(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancelar todos los recordatorios
  Future<void> cancelAllReminders() async {
    await _localNotifications.cancelAll();
  }

  /// Obtener notificaciones pendientes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }
}
