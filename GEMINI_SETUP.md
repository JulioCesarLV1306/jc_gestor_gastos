# Instrucciones para configurar tu API Key de Gemini

## 📝 Paso Final

Abre el archivo `.env` en la raíz del proyecto y reemplaza `YOUR_API_KEY_HERE` con tu API key real de Google AI Studio:

```env
GEMINI_API_KEY=AIzaSy...tu_clave_aqui...
```

## 🔑 ¿Dónde obtener tu API Key?

1. Visita: https://ai.google.dev/
2. Haz clic en "Get API Key" o "Get started"
3. Crea un proyecto en Google AI Studio
4. Copia tu API key
5. Pégala en el archivo `.env`

## ✅ Verificar la configuración

Una vez que hayas configurado tu API key:

1. Ejecuta: `flutter run`
2. Ve al chatbot (botón flotante en la pantalla principal)
3. Escribe un mensaje
4. Si todo está correcto, recibirás respuestas inteligentes de Gemini 2.5

## 🔒 Seguridad

- ✅ El archivo `.env` ya está en `.gitignore`
- ✅ Tu API key NO se subirá al repositorio
- ⚠️ NUNCA compartas tu API key públicamente

## 📱 Uso

El chatbot ahora puede:
- Responder preguntas sobre finanzas
- Dar consejos personalizados
- Analizar tus gastos
- Ayudarte a crear presupuestos
- Y mucho más!

## 🐛 Solución de problemas

Si ves respuestas simuladas en lugar de respuestas de IA:
1. Verifica que tu API key esté correctamente configurada en `.env`
2. Asegúrate de que no diga `YOUR_API_KEY_HERE`
3. Reinicia la aplicación completamente
4. Revisa los logs de la consola para ver mensajes de Gemini Service

## 📚 Modelos disponibles

El servicio está configurado para usar `gemini-2.0-flash-exp` (experimental).
Si quieres usar el modelo estable, cambia en `gemini_service.dart`:

```dart
model: 'gemini-pro'  // Versión estable
```

¡Disfruta de tu asistente financiero con IA! 🤖✨
