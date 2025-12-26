# 🔍 Diagnóstico: Verificación de Email

## ✅ Estado del Código

### **Implementación Correcta**
El sistema de verificación de email está **correctamente implementado** en el código:

#### 1. Envío durante el Registro
📍 Ubicación: [auth_service.dart](../lib/config/services/auth_service.dart#L55-L63)

```dart
// Enviar email de verificación
try {
  await user.sendEmailVerification();
  print('✅ Email de verificación enviado exitosamente a: ${user.email}');
} on FirebaseAuthException catch (emailError) {
  print('⚠️ Error al enviar email de verificación: ${emailError.code}');
  // No detiene el registro, el usuario puede reenviar después
}
```

#### 2. Reenvío de Email
📍 Ubicación: [auth_service.dart](../lib/config/services/auth_service.dart#L134-L152)

```dart
Future<void> resendVerificationEmail() async {
  // Valida que el usuario esté autenticado
  // Valida que el email no esté ya verificado
  // Envía el email de verificación
  // Maneja errores específicamente
}
```

#### 3. Validación en Login
📍 Ubicación: [auth_service.dart](../lib/config/services/auth_service.dart#L83-L87)

```dart
// Verificar si el email está verificado
if (credential.user != null && !credential.user!.emailVerified) {
  print('⚠️ Email no verificado para: ${credential.user!.email}');
  // Permite login pero informa al usuario
}
```

## 🧪 Cómo Probar el Envío

### Paso 1: Preparación

1. **Eliminar usuario de prueba anterior (si existe):**
   - Ve a [Firebase Console - Authentication](https://console.firebase.google.com/project/gestor-financiero-28ac2/authentication/users)
   - Busca y elimina el usuario de prueba

2. **Usar email válido:**
   - Gmail, Outlook, Yahoo, etc.
   - Asegúrate de tener acceso a la bandeja de entrada

### Paso 2: Ejecutar la App

```bash
# Detener la app actual si está corriendo
Ctrl + C

# Limpiar y ejecutar
flutter clean
flutter pub get
flutter run
```

### Paso 3: Registrar Usuario

1. Abrir la app
2. Ir a **Registro**
3. Completar formulario:
   - **Nombre:** Tu nombre
   - **Email:** email válido (ej: tumail@gmail.com)
   - **Contraseña:** mínimo 6 caracteres
   - **Confirmar Contraseña:** igual que la contraseña
4. Presionar **Registrar**

### Paso 4: Verificar Logs

Deberías ver en la consola de Flutter:

```
🔐 Iniciando registro para: tumail@gmail.com
✅ Usuario creado en Firebase Auth: [UID]
✅ DisplayName actualizado: [nombre]
💾 Guardando perfil en Firestore para UID: [UID]
✅ Perfil guardado en Firestore
✅ Email de verificación enviado exitosamente a: tumail@gmail.com
```

**Si ves error:**
```
⚠️ Error al enviar email de verificación: [código-error]
```

Revisa la sección de **Solución de Problemas** abajo.

### Paso 5: Verificar Email

1. **Revisar bandeja de entrada:**
   - Asunto: "Verify your email for [nombre-proyecto]"
   - Remitente: `noreply@gestor-financiero-28ac2.firebaseapp.com`

2. **Si no está en bandeja, revisar SPAM:**
   - Buscar: "Firebase", "Verify email", "gestor-financiero"
   - Marcar como "No es spam"
   - Agregar remitente a contactos

3. **Hacer clic en el enlace de verificación:**
   - El enlace te llevará a una página de Firebase
   - Verás mensaje: "Your email has been verified"

## 🔧 Solución de Problemas

### ❌ No llega el correo

#### Verificación 1: Firebase Console - Configuración

1. **Ir a:** [Firebase Console - Authentication](https://console.firebase.google.com/project/gestor-financiero-28ac2/authentication/providers)

2. **Verificar que Email/Password esté habilitado:**
   - Provider: **Email/Password** debe estar **✅ Enabled**
   - Si no está habilitado, haz clic para habilitarlo

3. **Verificar plantilla de email:**
   - Ir a: [Templates](https://console.firebase.google.com/project/gestor-financiero-28ac2/authentication/emails)
   - Seleccionar: **Email address verification**
   - Verificar que el template esté configurado

#### Verificación 2: Límites de Cuota

Firebase Plan Spark (gratuito) tiene límites:

- **Límite diario:** ~100 emails de verificación
- **Si se excede:** Los emails no se envían sin error visible

**Solución:**
1. Esperar 24 horas
2. O actualizar a plan Blaze (pago por uso)

#### Verificación 3: Email en Lista de Spam

Firebase puede ser marcado como spam por algunos proveedores:

**Gmail:**
- Buscar: `in:spam from:noreply@gestor-financiero-28ac2.firebaseapp.com`
- Marcar como "No es spam"

**Outlook/Hotmail:**
- Revisar carpeta "Correo no deseado"
- Marcar como "No es spam"

#### Verificación 4: Código de Error Específico

Si ves en los logs:

```
⚠️ Error al enviar email de verificación: [código]
```

**Códigos comunes:**

| Código | Significado | Solución |
|--------|-------------|----------|
| `too-many-requests` | Demasiados intentos | Esperar 15-30 minutos |
| `user-disabled` | Cuenta deshabilitada | Verificar en Firebase Console |
| `network-request-failed` | Sin conexión | Verificar internet |
| `invalid-email` | Email inválido | Verificar formato del email |

### ⚠️ Email ya verificado

Si intentas reenviar y ves:
```
El email ya está verificado
```

**Verificación:**
```dart
// En auth_service.dart ya existe el método:
await authService.isEmailVerified(); // true/false
```

## 📧 Reenviar Email de Verificación

### Opción 1: Desde Login

1. Iniciar sesión con el usuario
2. Si el email no está verificado, verás un diálogo
3. Presionar **"Reenviar correo"**

### Opción 2: Programáticamente

```dart
final authService = AuthService();
try {
  await authService.resendVerificationEmail();
  print('✅ Email reenviado');
} catch (e) {
  print('❌ Error: $e');
}
```

## 🔍 Verificar Estado de Verificación

### Desde Firebase Console

1. Ir a: [Authentication - Users](https://console.firebase.google.com/project/gestor-financiero-28ac2/authentication/users)
2. Buscar usuario por email
3. Ver columna **Email verified:** `Yes` o `No`

### Programáticamente

```dart
User? user = FirebaseAuth.instance.currentUser;
await user?.reload(); // Refrescar estado
print('Email verificado: ${user?.emailVerified}');
```

## 📊 Checklist de Verificación

- [ ] Firebase Authentication habilitado en Console
- [ ] Email/Password provider habilitado
- [ ] Template de email configurado
- [ ] Usuario no existe previamente en Firebase
- [ ] Email válido y accesible
- [ ] No se excedió límite de cuota diaria
- [ ] Revisada bandeja de spam
- [ ] Conexión a internet estable
- [ ] Logs muestran: "Email de verificación enviado exitosamente"

## 🆘 Si Nada Funciona

### Prueba Manual

1. **Ir a Firebase Console - Authentication**
2. **Buscar el usuario creado**
3. **Ver si aparece en la lista**
4. **Verificar campo "Email verified"**

### Verificación Directa en Firebase

Firebase también permite verificación manual (solo para desarrollo):

1. En Firebase Console - Authentication
2. Hacer clic en el usuario
3. Hay una opción para marcar como verificado (solo para pruebas)

### Contacto

Si después de todas estas verificaciones no funciona:

1. **Revisar reglas de Firestore** (pueden bloquear operaciones)
2. **Verificar configuración de red/proxy**
3. **Revisar firewall/antivirus** (pueden bloquear Firebase)

## 📝 Logs Esperados (Flujo Completo)

### Registro Exitoso:
```
🔐 Iniciando registro para: test@example.com
✅ Usuario creado en Firebase Auth: abc123xyz
✅ DisplayName actualizado: Test User
💾 Guardando perfil en Firestore para UID: abc123xyz
✅ Perfil guardado en Firestore
✅ Email de verificación enviado exitosamente a: test@example.com
```

### Login con Email No Verificado:
```
🔐 Retornando usuario después de signIn
⚠️ Email no verificado para: test@example.com
```

### Reenvío de Email:
```
📧 Reenviando email de verificación a: test@example.com
✅ Email de verificación reenviado exitosamente
```

## 🎯 Resumen

**✅ El código está correctamente implementado**
- El método `sendEmailVerification()` se llama correctamente
- Los errores se manejan apropiadamente
- Los logs son claros y detallados

**🔍 Verificar:**
1. Configuración de Firebase Console
2. Límites de cuota
3. Carpeta de spam
4. Estado de la red

**📧 Para probar:**
1. Eliminar usuario anterior
2. Usar email válido y accesible
3. Revisar logs completos
4. Verificar bandeja de entrada y spam
