# ✅ Checklist de Configuración Firebase - Email Verification

## 🔧 Verificaciones Necesarias

### 1. Firebase Console - Authentication

#### ✅ Habilitar Email/Password Provider
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Authentication** → **Sign-in method**
4. Verifica que **Email/Password** esté **habilitado**

#### ✅ Configurar Plantilla de Email
1. En Firebase Console, ve a **Authentication** → **Templates**
2. Selecciona **Email address verification**
3. Personaliza el email:
   - **Remitente:** Tu nombre o app (ej: "Gestor de Gastos JC")
   - **Asunto:** Verifica tu correo electrónico
   - **Contenido:** Personaliza el mensaje
4. Guarda los cambios

### 2. Configuración de Dominio Autorizado

#### ✅ Verificar Dominios Autorizados
1. Ve a **Authentication** → **Settings** → **Authorized domains**
2. Asegúrate de que tu dominio esté en la lista
3. Para desarrollo local, debe estar `localhost`

### 3. Configuración de Email

#### ⚠️ Importante para Producción
Por defecto, Firebase envía emails desde `noreply@[tu-proyecto].firebaseapp.com`

**Para usar tu propio dominio:**
1. Ve a **Authentication** → **Templates** → **Email address**
2. Configura SMTP personalizado (requiere plan Blaze)
3. O usa el email predeterminado de Firebase

### 4. Verificar Google Services

#### Android
✅ Verifica que existe [android/app/google-services.json](android/app/google-services.json)

#### iOS (si aplica)
✅ Verifica que existe `ios/Runner/GoogleService-Info.plist`

## 🐛 Solución de Problemas

### Problema: No llegan emails

**Posibles causas y soluciones:**

#### 1. Email en Spam
- ✅ Revisa la carpeta de spam
- ✅ Marca el email como "No es spam"
- ✅ Agrega `noreply@firebase.com` a contactos

#### 2. Email Inválido
```dart
// Verifica que el formato sea correcto
if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
  return 'Email inválido';
}
```

#### 3. Problemas de Cuota
- Firebase tiene límites en plan gratuito
- **Spark Plan (Gratis):** ~100 emails/día
- **Blaze Plan (Pago):** Sin límite

#### 4. Verificar Logs
```dart
// En auth_service.dart ya están los logs:
print('📧 Email de verificación enviado a: ${user.email}');
```

#### 5. Estado del Email
```dart
// Verificar si el email fue enviado
User? user = FirebaseAuth.instance.currentUser;
await user?.reload();
print('Email verificado: ${user?.emailVerified}');
```

### Problema: Usuario no puede logearse

**Verificaciones:**

#### 1. Credenciales Correctas
```dart
// Los logs ya muestran:
print('🔐 Intentando login con: $email');
```

#### 2. Cuenta Existe
- Verifica en Firebase Console → Authentication → Users
- Busca el email del usuario

#### 3. Email Verificado
```dart
// El código ya verifica:
if (!credential.user!.emailVerified) {
  print('⚠️ Email no verificado');
}
```

#### 4. Errores Comunes de Firebase
El código ya maneja estos errores en `_handleAuthException()`:
- `user-not-found`: Usuario no encontrado
- `wrong-password`: Contraseña incorrecta
- `invalid-email`: Email inválido
- `user-disabled`: Cuenta deshabilitada
- `too-many-requests`: Demasiados intentos

## 🧪 Probar Email Verification

### Test Manual:

```dart
// 1. Registrar usuario
final user = await authService.registerWithEmail(
  email: 'test@ejemplo.com',
  password: 'Test123456',
  displayName: 'Usuario Test',
);

// 2. Verificar que se envió el email
print('Email enviado a: ${user?.email}');

// 3. Verificar estado
print('Email verificado: ${user?.emailVerified}'); // false

// 4. Después de hacer clic en el enlace del email:
await user?.reload();
print('Email verificado: ${user?.emailVerified}'); // true
```

### Test con Flutter DevTools:

1. Abre Flutter DevTools
2. Ve a la pestaña "Network"
3. Registra un usuario
4. Busca la llamada a Firebase Authentication
5. Verifica que no haya errores

## 📊 Monitoreo

### Firebase Console
1. Ve a **Authentication** → **Users**
2. Verifica la columna "Email verified"
3. Debe mostrar ✅ después de verificar

### Logs en App
Los logs implementados te muestran:
```
🔐 Iniciando registro para: test@ejemplo.com
✅ Usuario creado en Firebase Auth: abc123xyz
✅ DisplayName actualizado: Test User
📝 Creando perfil en Firestore para: abc123xyz
✅ Perfil guardado exitosamente en Firestore
📧 Email de verificación enviado a: test@ejemplo.com
```

## 🔐 Seguridad

### Recomendaciones:

1. **Requiere verificación para funciones sensibles:**
```dart
if (!user.emailVerified) {
  throw Exception('Verifica tu email para acceder a esta función');
}
```

2. **Límite de reenvíos:**
```dart
// Firebase automáticamente limita los reenvíos
// Por defecto: 1 email cada 60 segundos
```

3. **Tiempo de expiración:**
- Los enlaces de verificación expiran en 24 horas
- Después de eso, se debe reenviar

## 📱 Testing en Diferentes Entornos

### Android:
```bash
flutter run -d android
```
- ✅ Verifica permisos de Internet en AndroidManifest.xml
- ✅ Ya configurado en tu proyecto

### iOS:
```bash
flutter run -d ios
```
- ✅ Verifica Info.plist
- ✅ Configura GoogleService-Info.plist

### Web:
```bash
flutter run -d chrome
```
- ✅ Verifica configuración en firebase_options.dart
- ✅ Ya configurado para web

## 📞 Soporte

Si los problemas persisten:

1. **Revisa Firebase Status:**
   - https://status.firebase.google.com/

2. **Stack Overflow:**
   - Tag: `firebase-authentication`
   - Tag: `flutter`

3. **Firebase Support:**
   - https://firebase.google.com/support

4. **Documentación Oficial:**
   - https://firebase.google.com/docs/auth/flutter/manage-users

---

**Última actualización:** 22 de Diciembre, 2025
