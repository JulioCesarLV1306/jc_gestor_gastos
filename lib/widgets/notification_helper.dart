import 'package:flutter/material.dart';
import 'package:gestor_de_gastos_jc/config/services/notification_service.dart';
import 'package:gestor_de_gastos_jc/config/services/scheduled_notification_service.dart';

/// Helper para configurar notificaciones de usuario
class NotificationHelper {
  final String userId;
  final NotificationService _notificationService = NotificationService();
  final ScheduledNotificationService _scheduledService = ScheduledNotificationService();

  NotificationHelper(this.userId);

  /// Configuración inicial completa de notificaciones
  Future<void> setupUserNotifications({
    bool enableDailyReminders = true,
    int dailyReminderHour = 20,
    int dailyReminderMinute = 0,
    bool enableWeeklyReports = true,
    int weeklyReportDay = 1, // Lunes
    int weeklyReportHour = 9,
    List<String>? topics,
  }) async {
    try {
      // Guardar token FCM
      await _notificationService.saveTokenToDatabase(userId);
      
      // Configurar recordatorios diarios si están habilitados
      if (enableDailyReminders) {
        await _scheduledService.scheduleDailyExpenseReminder(
          userId: userId,
          hour: dailyReminderHour,
          minute: dailyReminderMinute,
        );
      }
      
      // Configurar reportes semanales si están habilitados
      if (enableWeeklyReports) {
        await _scheduledService.scheduleWeeklyExpenseReminder(
          userId: userId,
          dayOfWeek: weeklyReportDay,
          hour: weeklyReportHour,
          minute: 0,
        );
      }
      
      // Suscribirse a topics
      if (topics != null) {
        for (var topic in topics) {
          await _notificationService.subscribeToTopic(topic);
        }
      }
      
      print('✅ Notificaciones configuradas correctamente');
    } catch (e) {
      print('❌ Error al configurar notificaciones: $e');
    }
  }

  /// Cancelar todas las notificaciones del usuario
  Future<void> cancelAllNotifications() async {
    await _scheduledService.cancelAllReminders();
    await _notificationService.cancelAllNotifications();
  }

  /// Actualizar hora del recordatorio diario
  Future<void> updateDailyReminderTime({
    required int hour,
    required int minute,
  }) async {
    await _scheduledService.scheduleDailyExpenseReminder(
      userId: userId,
      hour: hour,
      minute: minute,
    );
  }
}

/// Widget de configuración de notificaciones
class NotificationSettingsWidget extends StatefulWidget {
  final String userId;
  
  const NotificationSettingsWidget({
    super.key,
    required this.userId,
  });

  @override
  State<NotificationSettingsWidget> createState() => _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState extends State<NotificationSettingsWidget> {
  bool _dailyReminders = true;
  bool _weeklyReports = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  
  late NotificationHelper _helper;

  @override
  void initState() {
    super.initState();
    _helper = NotificationHelper(widget.userId);
  }

  Future<void> _saveSettings() async {
    await _helper.setupUserNotifications(
      enableDailyReminders: _dailyReminders,
      dailyReminderHour: _reminderTime.hour,
      dailyReminderMinute: _reminderTime.minute,
      enableWeeklyReports: _weeklyReports,
      topics: ['gastos_tips', 'ahorro_tips'],
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuración guardada')),
      );
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración de Notificaciones',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Recordatorios diarios
            SwitchListTile(
              title: const Text('Recordatorios Diarios'),
              subtitle: const Text('Te recordaremos registrar tus gastos'),
              value: _dailyReminders,
              onChanged: (value) {
                setState(() {
                  _dailyReminders = value;
                });
              },
            ),
            
            // Selector de hora
            if (_dailyReminders)
              ListTile(
                title: const Text('Hora del recordatorio'),
                subtitle: Text(_reminderTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: _selectTime,
              ),
            
            const Divider(),
            
            // Reportes semanales
            SwitchListTile(
              title: const Text('Reportes Semanales'),
              subtitle: const Text('Resumen de gastos cada lunes'),
              value: _weeklyReports,
              onChanged: (value) {
                setState(() {
                  _weeklyReports = value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Botón guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Configuración'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mostrar diálogo de configuración rápida
Future<void> showNotificationSetupDialog(BuildContext context, String userId) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Configurar Notificaciones'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¿Deseas recibir recordatorios para registrar tus gastos?',
            ),
            const SizedBox(height: 16),
            const Icon(Icons.notifications_active, size: 64, color: Colors.blue),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Ahora no'),
        ),
        ElevatedButton(
          onPressed: () async {
            final helper = NotificationHelper(userId);
            await helper.setupUserNotifications(
              enableDailyReminders: true,
              enableWeeklyReports: true,
              topics: ['gastos_tips'],
            );
            
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Notificaciones activadas!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: const Text('Activar'),
        ),
      ],
    ),
  );
}
