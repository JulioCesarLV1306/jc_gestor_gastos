# 🔍 Debugging - Email de Verificación No Llega

## ⚠️ Problema Reportado

```
🔐 Iniciando registro para: juliolopezvasquez@gmail.com
🔄 Estado de auth cambió - Usuario: juliolopezvasquez@gmail.com
✅ Usuario creado en Firebase Auth: qrhC9s5ItFPQeLLmll0X2eWbibv2
✅ DisplayName actualizado: admin
📝 Creando perfil en Firestore para: qrhC9s5ItFPQeLLmll0X2eWbibv2
```

**Logs faltantes esperados:**
- ✅ Perfil guardado exitosamente en Firestore
- 📧 Email de verificación enviado a: juliolopezvasquez@gmail.com

## 🔧 Soluciones Aplicadas

### 1. Mejor Manejo de Errores

He mejorado el código para que:
- ✅ Capture errores de Firestore sin detener el registro
- ✅ Capture errores de envío de email sin detener el registro
- ✅ Muestre logs más detallados de cada paso
- ✅ Muestre el StackTrace completo del error

### 2. Logs Mejorados

Ahora verás logs más detallados:
```dart
📝 Creando perfil en Firestore para: qrhC9s5ItFPQeLLmll0X2eWbibv2
📧 Email: juliolopezvasquez@gmail.com
👤 DisplayName: admin
🔄 Convirtiendo a Map...
✅ Map creado: {uid: ..., email: ..., ...}
🔄 Guardando en Firestore...
✅ Perfil guardado exitosamente en Firestore
📧 Email de verificación enviado a: juliolopezvasquez@gmail.com
```

## 🧪 Pasos para Probar

### Paso 1: Limpiar Usuario Anterior

El usuario **juliolopezvasquez@gmail.com** ya existe en Firebase. Debes eliminarlo:

**Opción A: Firebase Console**
1. Ve a: https://console.firebase.google.com/
2. Selecciona tu proyecto
3. **Authentication** → **Users**
4. Busca: `juliolopezvasquez@gmail.com`
5. Haz clic en los 3 puntos → **Delete account**

**Opción B: Usar otro email**
- Usa un email diferente para la prueba
- Ejemplo: `juliolopezvasquez+test@gmail.com`
  (Gmail ignora el +test pero Firebase lo trata como diferente)

### Paso 2: Volver a Ejecutar la App

```bash
# Detener la app actual
# En el terminal, presiona: Ctrl+C

# Ejecutar nuevamente con logs
flutter run
```

### Paso 3: Registrar Usuario Nuevamente

1. Abre la app
2. Ve a **Registro**
3. Completa el formulario:
   - Nombre: admin
   - Email: `juliolopezvasquez@gmail.com` (o el nuevo email)
   - Contraseña: Tu contraseña
4. Presiona **Registrar**

### Paso 4: Verificar Logs Completos

Ahora deberías ver en la consola:

```
🔐 Iniciando registro para: juliolopezvasquez@gmail.com
✅ Usuario creado en Firebase Auth: qrhC9s5ItFPQeLLmll0X2eWbibv2
✅ DisplayName actualizado: admin
📝 Creando perfil en Firestore para: qrhC9s5ItFPQeLLmll0X2eWbibv2
📧 Email: juliolopezvasquez@gmail.com
👤 DisplayName: admin
🔄 Convirtiendo a Map...
✅ Map creado: {...}
🔄 Guardando en Firestore...
✅ Perfil creado en Firestore
✅ Perfil guardado exitosamente en Firestore
📧 Email de verificación enviado a: juliolopezvasquez@gmail.com
```

**Si ves error:**
```
❌ Error al crear perfil en Firestore: [error detallado]
📍 StackTrace: [stack trace completo]
```

**O:**
```
❌ Error al enviar email de verificación: [error detallado]
```

## 🔍 Posibles Causas del Error

### 1. ❌ Usuario ya existe
**Error:** `email-already-in-use`

**Solución:**
```
- Elimina el usuario en Firebase Console
- O usa otro email
```

### 2. ❌ Permisos de Firestore
**Error:** `PERMISSION_DENIED`

**Solución:**
Verifica las reglas de Firestore en [firestore.rules](firestore.rules):
```javascript
match /users/{userId} {
  allow create: if isAuthenticated() && request.auth.uid == userId;
}
```

**Desplegar reglas:**
```bash
firebase deploy --only firestore:rules
```

### 3. ❌ Internet desconectado
**Error:** `network-request-failed`

**Solución:**
- Verifica tu conexión a internet
- Verifica que Firebase esté accesible

### 4. ❌ Firebase no inicializado
**Error:** `Firebase has not been correctly initialized`

**Solución:**
Verifica en [main.dart](lib/main.dart):
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 5. ❌ Email no configurado en Firebase
**Error:** Email settings not configured

**Solución:**
1. Ve a Firebase Console
2. **Authentication** → **Sign-in method**
3. **Email/Password** → Asegúrate que esté **habilitado**
4. Guarda los cambios

### 6. ❌ Cuota de emails excedida
**Error:** `quota-exceeded`

**Solución:**
- Firebase plan gratuito: ~100 emails/día
- Espera 24 horas
- O upgrade a plan Blaze

## 📊 Verificación en Firebase Console

### Verificar que el usuario se creó:
1. Firebase Console → **Authentication** → **Users**
2. Busca: `juliolopezvasquez@gmail.com`
3. Verifica columnas:
   - ✅ **User UID:** qrhC9s5ItFPQeLLmll0X2eWbibv2
   - ✅ **Email:** juliolopezvasquez@gmail.com
   - ❓ **Email verified:** Debe estar en ❌ (false)

### Verificar que el perfil se creó en Firestore:
1. Firebase Console → **Firestore Database**
2. Colección: `users`
3. Documento: `qrhC9s5ItFPQeLLmll0X2eWbibv2`
4. Debe tener:
   ```json
   {
     "uid": "qrhC9s5ItFPQeLLmll0X2eWbibv2",
     "email": "juliolopezvasquez@gmail.com",
     "displayName": "admin",
     "photoUrl": null,
     "createdAt": Timestamp,
     "lastLoginAt": null
   }
   ```

### Si el perfil NO está en Firestore:
- ❌ **Error de permisos** → Revisa las reglas
- ❌ **Error de conexión** → Verifica internet
- ❌ **Error en el modelo** → Verifica UserProfileModel

## 🔐 Reenviar Email de Verificación Manualmente

Si el usuario ya existe pero no recibió el email:

### Opción 1: Desde Firebase Console
1. **Authentication** → **Users**
2. Encuentra el usuario
3. **No hay opción directa en consola** ❌

### Opción 2: Desde la App (Login)
1. Ve a **Login**
2. Ingresa tus credenciales
3. Al iniciar sesión, verás el diálogo: **"Email No Verificado"**
4. Presiona: **"Reenviar Correo"**
5. Revisa tu email

### Opción 3: Código Manual
Puedes usar este código en Dart:

```dart
import 'package:firebase_auth/firebase_auth.dart';

Future<void> resendVerificationEmail() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      print('📧 Email de verificación reenviado a: ${user.email}');
    }
  } catch (e) {
    print('❌ Error al reenviar email: $e');
  }
}
```

## 📧 Verificar Email en Bandeja

### Dónde buscar:
1. ✅ **Bandeja de entrada**
2. ✅ **SPAM** (muy probable)
3. ✅ **Promociones** (Gmail)
4. ✅ **Social** (Gmail)

### Características del email:
- **De:** `noreply@[tu-proyecto].firebaseapp.com`
- **Asunto:** "Verify your email for [proyecto]"
- **Contiene:** Enlace "Verify email address"

### Si no llega después de 5 minutos:
1. ✅ Revisa SPAM
2. ✅ Agrega `noreply@firebase.com` a contactos
3. ✅ Reenvía el email desde la app
4. ✅ Espera 15 minutos más
5. ✅ Prueba con otro email de prueba

## 🆘 Solución Rápida

Si nada funciona, aquí está el proceso completo:

```bash
# 1. Detener la app
Ctrl+C

# 2. Limpiar build
flutter clean

# 3. Obtener dependencias
flutter pub get

# 4. Ejecutar con logs verbosos
flutter run --verbose
```

Luego:
1. Elimina el usuario en Firebase Console
2. Registra nuevamente
3. Revisa los logs completos
4. Busca cualquier error en rojo

## 📝 Checklist Final

- [ ] ✅ Usuario eliminado de Firebase Console (si existe)
- [ ] ✅ App reiniciada (`flutter run`)
- [ ] ✅ Registro completado
- [ ] ✅ Logs completos visibles en consola
- [ ] ✅ Perfil verificado en Firestore Database
- [ ] ✅ Email de verificación visible en logs
- [ ] ✅ Email recibido (revisar SPAM)
- [ ] ✅ Link de verificación funciona
- [ ] ✅ Login exitoso después de verificar

---

**Siguiente paso:** Ejecuta `flutter run` y registra el usuario nuevamente para ver los logs completos.
