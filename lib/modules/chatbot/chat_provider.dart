import 'package:flutter/material.dart';
import 'package:gestor_de_gastos_jc/modules/chatbot/gemini_service.dart';
import 'package:gestor_de_gastos_jc/modules/home/provider_home.dart';

/// Modelo de mensaje de chat
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// Provider para gestionar el estado del chat
class ChatProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _sendWithContext = false;

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;
  bool get sendWithContext => _sendWithContext;

  ChatProvider() {
    // Mensaje de bienvenida inicial
    _messages.add(
      ChatMessage(
        text: '¡Hola! Soy tu asistente financiero inteligente. ¿En qué puedo ayudarte hoy?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Alternar el envío con contexto financiero
  void toggleContext() {
    _sendWithContext = !_sendWithContext;
    notifyListeners();
  }

  /// Agregar un mensaje al chat
  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  /// Enviar un mensaje al chatbot
  Future<void> sendMessage(String text, {ProviderHome? providerHome}) async {
    if (text.trim().isEmpty) return;

    // Agregar mensaje del usuario
    addMessage(
      ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    // Mostrar indicador de escritura
    _isTyping = true;
    notifyListeners();

    try {
      // Obtener respuesta del servicio Gemini
      final String response;
      
      if (_sendWithContext && providerHome != null) {
        // Calcular total de gastos
        final totalGastos = providerHome.gastos.fold<double>(
          0.0,
          (sum, gasto) => sum + gasto.cantidad,
        );
        
        // Obtener categorías únicas
        final categoriasUnicas = providerHome.gastos
            .map((gasto) => gasto.categoria)
            .toSet()
            .toList();
        
        // Enviar con contexto financiero real
        response = await _geminiService.sendMessageWithContext(
          message: text,
          totalGastos: totalGastos,
          presupuesto: providerHome.presupuestoGeneral,
          ahorro: providerHome.ahorro,
          categorias: categoriasUnicas,
        );
      } else {
        // Enviar sin contexto
        response = await _geminiService.sendMessage(text);
      }
      
      _isTyping = false;
      notifyListeners();

      // Agregar respuesta del bot
      addMessage(
        ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      _isTyping = false;
      notifyListeners();

      addMessage(
        ChatMessage(
          text: 'Lo siento, hubo un error al procesar tu mensaje. Por favor, intenta de nuevo.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  /// Limpiar todo el historial del chat
  void clearChat() {
    _messages.clear();
    _geminiService.clearChatHistory();
    
    // Agregar mensaje de bienvenida nuevamente
    _messages.add(
      ChatMessage(
        text: '¡Hola! Soy tu asistente financiero inteligente. ¿En qué puedo ayudarte hoy?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    
    notifyListeners();
  }

  /// Obtener preguntas sugeridas
  List<String> getSuggestedQuestions() {
    return _geminiService.getSuggestedQuestions();
  }
}
