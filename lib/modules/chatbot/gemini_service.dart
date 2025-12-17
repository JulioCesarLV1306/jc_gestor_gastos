import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';

/// Servicio de Gemini 2.5
/// 
/// Gestiona la comunicación con la API de Google Gemini.
class GeminiService {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  
  static const String _defaultSystemInstruction = '''
  Eres un asistente financiero experto y amigable. Tu objetivo es ayudar a los usuarios a:
  
  1. Gestionar sus gastos personales de manera efectiva
  2. Crear y mantener presupuestos realistas
  3. Dar consejos para ahorrar dinero
  4. Analizar patrones de gastos
  5. Responder preguntas sobre finanzas personales
  
  Características de tu personalidad:
  - Amigable y cercano
  - Profesional pero no formal en exceso
  - Conciso y claro en tus respuestas
  - Proactivo en dar consejos útiles
  - Sensible a la situación financiera del usuario
  
  Formato de respuestas:
  - Usa párrafos cortos para mejor legibilidad
  - Incluye ejemplos prácticos cuando sea relevante
  - Ofrece opciones cuando sea apropiado
  - Pregunta si necesitan más detalles
  ''';

  GeminiService() {
    _initialize();
  }

  void _initialize() {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      
      if (apiKey.isEmpty || apiKey == 'YOUR_API_KEY_HERE') {
        debugPrint('⚠️ GEMINI_API_KEY no está configurado en .env');
        debugPrint('⚠️ Por favor, configura tu API key en el archivo .env');
        return;
      }

      _model = GenerativeModel(
        model: 'gemini-2.5-flash-lite', // Mejor rendimiento y límites gratuitos
        apiKey: apiKey,
        systemInstruction: Content.system(_defaultSystemInstruction),
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 2048,
        ),
        safetySettings: [
          SafetySetting(
            HarmCategory.harassment,
            HarmBlockThreshold.medium,
          ),
          SafetySetting(
            HarmCategory.hateSpeech,
            HarmBlockThreshold.medium,
          ),
        ],
      );

      _chat = _model.startChat(
        history: [
          Content.text(
            'Hola! Estoy aquí para ayudarte con tus finanzas personales.',
          ),
        ],
      );

      debugPrint('✅ Gemini Service inicializado correctamente');
    } catch (e) {
      debugPrint('❌ Error al inicializar Gemini Service: $e');
    }
  }

  /// Envía un mensaje al chatbot y obtiene una respuesta
  Future<String> sendMessage(String message) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      
      // Si no hay API key configurada, usar respuestas simuladas
      if (apiKey.isEmpty || apiKey == 'YOUR_API_KEY_HERE') {
        debugPrint('⚠️ Usando respuestas simuladas - configura tu API key');
        await Future.delayed(const Duration(seconds: 1));
        return _getSimulatedResponse(message);
      }

      debugPrint('📤 Enviando mensaje: $message');
      
      final response = await _chat.sendMessage(
        Content.text(message),
      );
      
      final text = response.text ?? 'No pude generar una respuesta.';
      debugPrint('📥 Respuesta recibida: ${text.substring(0, min(50, text.length))}...');
      
      return text;
    } catch (e) {
      debugPrint('❌ Error en sendMessage: $e');
      return 'Lo siento, hubo un error al procesar tu mensaje. Intenta de nuevo.';
    }
  }

  /// Envía un mensaje con contexto de las finanzas del usuario
  Future<String> sendMessageWithContext({
    required String message,
    double? totalGastos,
    double? presupuesto,
    double? ahorro,
    List<String>? categorias,
  }) async {
    final context = StringBuffer();
    context.writeln('Contexto del usuario:');
    
    if (totalGastos != null) {
      context.writeln('- Gastos totales: \$${totalGastos.toStringAsFixed(2)}');
    }
    if (presupuesto != null) {
      context.writeln('- Presupuesto: \$${presupuesto.toStringAsFixed(2)}');
    }
    if (ahorro != null) {
      context.writeln('- Ahorro actual: \$${ahorro.toStringAsFixed(2)}');
    }
    if (categorias != null && categorias.isNotEmpty) {
      context.writeln('- Categorías de gastos: ${categorias.join(", ")}');
    }
    
    context.writeln('\nPregunta del usuario: $message');
    
    return sendMessage(context.toString());
  }

  /// Limpia el historial de chat
  void clearChatHistory() {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      
      if (apiKey.isEmpty || apiKey == 'YOUR_API_KEY_HERE') {
        debugPrint('🗑️ Historial simulado limpiado');
        return;
      }

      _chat = _model.startChat();
      debugPrint('🗑️ Historial de chat limpiado');
    } catch (e) {
      debugPrint('❌ Error al limpiar historial: $e');
    }
  }

  /// Obtiene sugerencias de preguntas frecuentes
  List<String> getSuggestedQuestions() {
    return [
      '¿Cómo puedo ahorrar más dinero?',
      'Ayúdame a crear un presupuesto',
      '¿En qué categorías gasto más?',
      'Dame consejos para reducir gastos',
      '¿Cuánto debería ahorrar al mes?',
      'Analiza mis patrones de gasto',
    ];
  }

  /// Respuestas simuladas para testing
  String _getSimulatedResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('hola') || lowerMessage.contains('hi')) {
      return '¡Hola! 👋 Soy tu asistente financiero inteligente. Estoy aquí para ayudarte a gestionar mejor tus finanzas. ¿En qué puedo ayudarte hoy?';
    }
    
    if (lowerMessage.contains('ahorr')) {
      return '''Para mejorar tus ahorros, te recomiendo:

1. **Regla 50/30/20**: Destina 50% a necesidades, 30% a gustos y 20% a ahorros.

2. **Automatiza**: Configura transferencias automáticas a una cuenta de ahorros.

3. **Analiza gastos**: Revisa tus gastos mensuales y elimina suscripciones no utilizadas.

¿Quieres que analice tus gastos actuales para darte consejos personalizados?''';
    }
    
    if (lowerMessage.contains('presupuesto')) {
      return '''Crear un presupuesto efectivo es clave. Aquí te ayudo:

**Pasos básicos:**
1. Calcula tus ingresos mensuales
2. Lista todos tus gastos fijos
3. Establece límites para gastos variables
4. Reserva un porcentaje para ahorros
5. Revisa y ajusta mensualmente

¿Tienes ya establecido tu presupuesto en la app?''';
    }
    
    if (lowerMessage.contains('consejo') || lowerMessage.contains('ayuda')) {
      return '''Aquí van algunos consejos financieros rápidos:

💡 **Evita deudas innecesarias**: No compres a crédito lo que puedes pagar al contado.

💰 **Fondo de emergencia**: Intenta ahorrar al menos 3-6 meses de gastos.

📊 **Revisa tus gastos**: Usa esta app para ver dónde va tu dinero.

🎯 **Metas claras**: Define objetivos financieros específicos.

¿Hay algún área específica en la que necesites ayuda?''';
    }
    
    return '''Entiendo tu pregunta. Como asistente financiero, puedo ayudarte con:

• Análisis de gastos
• Creación de presupuestos
• Consejos de ahorro
• Estrategias financieras

*Nota: Actualmente estoy en modo demo. Para respuestas personalizadas con IA, configura la API de Gemini 2.5.*

¿Sobre qué tema específico te gustaría hablar?''';
  }
}
