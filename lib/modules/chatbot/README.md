# Integración de Gemini 2.5 - Chatbot IA

Este módulo contiene el chatbot con IA para el asistente financiero.

## 📋 Estructura

```
modules/chatbot/
├── chatbot_screen.dart       # Pantalla principal del chatbot
├── gemini_service.dart        # Servicio de API Gemini (pendiente)
└── README.md                  # Este archivo
```

## 🚀 Configuración de Gemini 2.5

### 1. Instalar dependencias

```bash
flutter pub add google_generative_ai
flutter pub add flutter_dotenv
```

### 2. Configurar API Key

Crea un archivo `.env` en la raíz del proyecto:

```env
GEMINI_API_KEY=tu_api_key_aqui
```

Agrega `.env` al `.gitignore`:

```
.env
```

### 3. Crear servicio de Gemini

Crea `gemini_service.dart`:

```dart
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: apiKey,
      systemInstruction: Content.system(
        'Eres un asistente financiero experto. Ayudas a usuarios a '
        'gestionar sus gastos, crear presupuestos y dar consejos financieros. '
        'Sé amigable, conciso y profesional.',
      ),
    );
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(
        Content.text(message),
      );
      return response.text ?? 'No pude generar una respuesta.';
    } catch (e) {
      return 'Error al comunicarse con el asistente: $e';
    }
  }

  void clearHistory() {
    _chat = _model.startChat();
  }
}
```

### 4. Actualizar chatbot_screen.dart

Reemplaza el método `_sendMessage()`:

```dart
final _geminiService = GeminiService();

Future<void> _sendMessage() async {
  final text = _messageController.text.trim();
  if (text.isEmpty) return;

  _addMessage(
    ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ),
  );

  _messageController.clear();
  setState(() => _isTyping = true);

  try {
    final response = await _geminiService.sendMessage(text);
    
    setState(() => _isTyping = false);
    
    _addMessage(
      ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  } catch (e) {
    setState(() => _isTyping = false);
    _addMessage(
      ChatMessage(
        text: 'Lo siento, hubo un error. Intenta de nuevo.',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }
}
```

### 5. Actualizar pubspec.yaml

Asegúrate de cargar el archivo `.env`:

```yaml
flutter:
  assets:
    - .env
```

### 6. Inicializar en main.dart

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");
  
  // ... resto del código
}
```

## 🎯 Características

- ✅ Interfaz de chat moderna y responsive
- ✅ Animación de escritura
- ✅ Burbujas de mensaje personalizadas
- ✅ Botón flotante con animación de pulso
- ⏳ Integración con Gemini 2.5 (pendiente)
- ⏳ Historial de conversaciones
- ⏳ Sugerencias de preguntas

## 📱 Uso

El chatbot está accesible desde el botón flotante en la pantalla principal.

## 🔐 Seguridad

- **NUNCA** subas tu API key al repositorio
- Usa variables de entorno para credenciales
- Agrega `.env` al `.gitignore`

## 📚 Recursos

- [Documentación de Gemini](https://ai.google.dev/docs)
- [Google Generative AI Package](https://pub.dev/packages/google_generative_ai)
