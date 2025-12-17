import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gestor_de_gastos_jc/config/constans/app_colors.dart';
import 'package:gestor_de_gastos_jc/modules/chatbot/gemini_service.dart';
import 'package:gestor_de_gastos_jc/modules/home/provider_home.dart';
import 'package:provider/provider.dart';

/// Pantalla de Chatbot con Gemini 2.5
/// 
/// Interfaz conversacional para interactuar con el asistente de IA.
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _sendWithContext = false;
  late AnimationController _typingAnimationController;

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    // Mensaje de bienvenida
    _addMessage(
      ChatMessage(
        text: '¡Hola! Soy tu asistente financiero inteligente. ¿En qué puedo ayudarte hoy?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Agregar mensaje del usuario
    _addMessage(
      ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    _messageController.clear();

    // Mostrar indicador de escritura
    setState(() {
      _isTyping = true;
    });

    try {
      // Obtener respuesta del servicio Gemini
      final String response;
      
      if (_sendWithContext) {
        // Obtener datos reales del Provider
        final providerHome = Provider.of<ProviderHome>(context, listen: false);
        
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
      
      setState(() {
        _isTyping = false;
      });

      // Agregar respuesta del bot
      _addMessage(
        ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      setState(() {
        _isTyping = false;
      });

      _addMessage(
        ChatMessage(
          text: 'Lo siento, hubo un error al procesar tu mensaje. Por favor, intenta de nuevo.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  void _showSuggestions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lightbulb,
                  color: AppColors.primaryOrange,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Preguntas sugeridas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(_geminiService.getSuggestedQuestions().map((question) =>
                _buildSuggestionChip(question))),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String question) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          _messageController.text = question;
          _sendMessage();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 18,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar conversación'),
        content: const Text(
          '¿Estás seguro de que quieres borrar toda la conversación?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _messages.clear();
              });
              _geminiService.clearChatHistory();
              Navigator.pop(context);
              
              // Agregar mensaje de bienvenida nuevamente
              _addMessage(
                ChatMessage(
                  text: '¡Hola! Soy tu asistente financiero inteligente. ¿En qué puedo ayudarte hoy?',
                  isUser: false,
                  timestamp: DateTime.now(),
                ),
              );
            },
            child: const Text(
              'Borrar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            if (_isTyping) _buildTypingIndicator(),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue.withOpacity(0.8),
                  AppColors.primaryPurple.withOpacity(0.8),
                ],
              ),
            ),
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: Icon(
                Icons.smart_toy_outlined,
                color: AppColors.primaryPurple,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asistente IA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Gemini 2.5',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.lightbulb_outline, color: Colors.white),
          onPressed: () => _showSuggestions(),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white),
          onPressed: () => _clearChat(),
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue.withOpacity(0.2),
                    AppColors.primaryPurple.withOpacity(0.2),
                  ],
                ),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: AppColors.primaryPurple,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Inicia una conversación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Pregúntame sobre tus finanzas, gastos o cualquier consejo financiero',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _ChatBubble(message: _messages[index]);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (index) => AnimatedBuilder(
                  animation: _typingAnimationController,
                  builder: (context, child) {
                    final delay = index * 0.2;
                    final value = (_typingAnimationController.value - delay)
                        .clamp(0.0, 1.0);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withOpacity(0.3 + (value * 0.7)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador de contexto
            if (_sendWithContext)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Enviando con contexto financiero',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                // Botón de contexto
                Container(
                  decoration: BoxDecoration(
                    color: _sendWithContext
                        ? AppColors.primaryBlue.withOpacity(0.15)
                        : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.account_balance_wallet,
                      color: _sendWithContext
                          ? AppColors.primaryBlue
                          : Colors.grey[600],
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _sendWithContext = !_sendWithContext;
                      });
                      
                      // Mostrar mensaje informativo
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _sendWithContext
                                ? '✓ Contexto financiero activado'
                                : '✗ Contexto financiero desactivado',
                          ),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    tooltip: _sendWithContext
                        ? 'Desactivar contexto financiero'
                        : 'Activar contexto financiero',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primaryBlue,
                        AppColors.primaryPurple,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de burbuja de mensaje
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) _buildAvatar(),
          if (!message.isUser) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: message.isUser
                        ? const LinearGradient(
                            colors: [
                              AppColors.primaryBlue,
                              AppColors.primaryPurple,
                            ],
                          )
                        : null,
                    color: message.isUser ? null : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft:
                          Radius.circular(message.isUser ? 20 : 4),
                      bottomRight:
                          Radius.circular(message.isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (message.isUser
                                ? AppColors.primaryBlue
                                : Colors.black)
                            .withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
          if (message.isUser) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: message.isUser
            ? const LinearGradient(
                colors: [
                  AppColors.primaryGreen,
                  AppColors.primaryOrange,
                ],
              )
            : LinearGradient(
                colors: [
                  AppColors.primaryBlue.withOpacity(0.8),
                  AppColors.primaryPurple.withOpacity(0.8),
                ],
              ),
      ),
      child: Icon(
        message.isUser ? Icons.person : Icons.smart_toy,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

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
