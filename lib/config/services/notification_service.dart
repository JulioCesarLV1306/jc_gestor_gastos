import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

/// Handler para notificaciones en segundo plano
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Notificación en segundo plano: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'gestofin',
  );

  bool _isInitialized = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Inicializar servicio de notificaciones
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Solicitar permisos
      await _requestPermissions();

      // Configurar notificaciones locales
      await _initializeLocalNotifications();

      // Obtener token FCM
      await _getFCMToken();

      // Configurar handlers de FCM
      _setupFCMHandlers();

      _isInitialized = true;
      print('✅ Servicio de notificaciones inicializado');
    } catch (e) {
      print('❌ Error al inicializar notificaciones: $e');
    }
  }

  /// Solicitar permisos de notificaciones
  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('Estado de permisos: ${settings.authorizationStatus}');
    } else if (Platform.isAndroid) {
      // Android 13+ requiere permiso runtime
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  /// Inicializar notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Handler cuando se toca una notificación
  void _onNotificationTapped(NotificationResponse response) {
    print('📱 Notificación tocada: ${response.payload}');
    // Aquí puedes navegar a la pantalla correspondiente
  }

  /// Obtener token FCM
  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      print('🔑 FCM Token: $_fcmToken');
      return _fcmToken;
    } catch (e) {
      print('❌ Error al obtener token: $e');
      return null;
    }
  }

  /// Guardar token en Firestore
  Future<void> saveTokenToDatabase(String userId) async {
    if (_fcmToken == null) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': _fcmToken,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Token guardado en Firestore');
    } catch (e) {
      print('❌ Error al guardar token: $e');
    }
  }

  /// Configurar handlers de FCM
  void _setupFCMHandlers() {
    // Notificación cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Notificación recibida en primer plano');
      _showLocalNotification(message);
    });

    // Notificación tocada cuando la app está en segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 App abierta desde notificación');
      _handleNotificationTap(message);
    });

    // Token actualizado
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      print('🔄 Token actualizado: $newToken');
    });
  }

  /// Mostrar notificación local
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'gastos_channel',
      'Notificaciones de Gastos',
      channelDescription: 'Recordatorios y recomendaciones de gastos',
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

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Nueva notificación',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }

  /// Manejar tap en notificación
  void _handleNotificationTap(RemoteMessage message) {
    // Implementar navegación según el tipo de notificación
    final type = message.data['type'] as String?;
    
    switch (type) {
      case 'expense_reminder':
        print('Navegar a pantalla de gastos');
        break;
      case 'investment_recommendation':
        print('Navegar a recomendaciones');
        break;
      default:
        print('Tipo de notificación desconocido');
    }
  }

  /// Enviar notificación de recordatorio de gastos
  Future<void> sendExpenseReminder({
    required String userId,
    String? title,
    String? body,
  }) async {
    final message = RemoteMessage(
      notification: RemoteNotification(
        title: title ?? '📝 Registra tus gastos',
        body: body ?? '¿Ya registraste tus gastos de hoy?',
      ),
      data: {
        'type': 'expense_reminder',
        'userId': userId,
      },
    );
    await _showLocalNotification(message);
  }

  /// Enviar notificación de recomendación de inversión
  Future<void> sendInvestmentRecommendation({
    required String userId,
    required String recommendation,
    required double amount,
  }) async {
    final message = RemoteMessage(
      notification: RemoteNotification(
        title: '💰 Recomendación de Inversión',
        body: recommendation,
      ),
      data: {
        'type': 'investment_recommendation',
        'userId': userId,
        'amount': amount.toString(),
      },
    );
    await _showLocalNotification(message);
  }

  /// Suscribirse a un topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Suscrito a topic: $topic');
    } catch (e) {
      print('❌ Error al suscribirse: $e');
    }
  }

  /// Desuscribirse de un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Desuscrito del topic: $topic');
    } catch (e) {
      print('❌ Error al desuscribirse: $e');
    }
  }

  /// Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Cancelar notificación específica
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }
}
