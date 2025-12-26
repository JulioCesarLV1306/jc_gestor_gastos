# 🚀 Inicio Rápido: Google Colab ML

## ⚡ Pasos Rápidos (5 minutos)

### 1. Subir Notebook
1. Abre https://colab.research.google.com/
2. **File** → **Upload notebook**
3. Sube `colab_expense_predictor.ipynb`

### 2. Configurar Ngrok
1. Crea cuenta: https://dashboard.ngrok.com/signup
2. Obtén token: https://dashboard.ngrok.com/get-started/your-authtoken
3. En el notebook, busca la celda **"🎯 Configurar Token de Ngrok"**
4. Reemplaza:
   ```python
   NGROK_AUTH_TOKEN = "tu_token_aqui"
   ```

### 3. Ejecutar Notebook
1. **Runtime** → **Run all** (o `Ctrl+F9`)
2. Espera 2-3 minutos
3. Copia la URL que aparece:
   ```
   📡 URL Pública de la API: https://xxxx.ngrok.io
   ```

### 4. Conectar en Flutter
1. Abre tu app
2. Navega a la página ML
3. Pega la URL de Ngrok
4. Presiona **Verificar Conexión**

### 5. ¡Listo!
Ahora puedes:
- ✅ Entrenar modelo
- ✅ Predecir gastos
- ✅ Detectar anomalías

---

## 📖 Documentación Completa

Lee [GUIA_COLAB_ML.md](docs/GUIA_COLAB_ML.md) para más detalles.

---

## ⚠️ Importante

- La URL de Ngrok **cambia** cada vez que ejecutas el notebook
- Google Colab se desconecta después de 12 horas
- Guarda tu token de Ngrok en un lugar seguro

---

## 🆘 Problemas Comunes

### "No se pudo conectar"
✅ Verifica que el notebook esté ejecutándose
✅ Copia la URL completa con `https://`
✅ Prueba en el navegador: `https://tu-url.ngrok.io/health`

### "Model not trained yet"
✅ Entrena el modelo primero desde la app

### URL cambió
✅ Normal. Copia la nueva URL del notebook y actualiza en la app

---

## 📱 Navegación en Flutter

```dart
// Para ir a la página ML
context.go('/colab-ml');

// O desde código
Navigator.pushNamed(context, '/colab-ml');
```

---

## 🎯 Endpoints Disponibles

- `/health` - Verificar estado
- `/train` - Entrenar modelo
- `/predict` - Predecir gastos
- `/detect_anomalies` - Detectar anomalías
- `/metrics` - Métricas del modelo

---

**¡Listo para empezar!** 🚀
