# 🚀 Guía Rápida - Probar Email Verification

## ⚡ Inicio Rápido

### 1️⃣ Ejecutar la App
```bash
flutter run
```

### 2️⃣ Probar Registro
1. Ve a la pantalla de **Registro**
2. Completa el formulario:
   - Nombre: Tu nombre
   - Email: tu_email@gmail.com (usa un email real)
   - Contraseña: Test123456
   - Confirmar contraseña: Test123456
3. Presiona **Registrar**
4. Verás un diálogo: **"¡Registro Exitoso!"**
   ```
   Te hemos enviado un correo de verificación a:
   tu_email@gmail.com
   
   Por favor, revisa tu bandeja de entrada y spam,
   y haz clic en el enlace de verificación.
   ```
5. Presiona **"Entendido"** → Te redirige a Login

### 3️⃣ Verificar Email
1. Abre tu correo electrónico
2. Busca email de: `noreply@gestor-de-gastos-jc.firebaseapp.com`
3. **Si no lo ves:**
   - ✅ Revisa **SPAM**
   - ✅ Revisa **Promociones** (Gmail)
   - ✅ Busca "firebase" o "verify"
4. Haz clic en el enlace: **"Verify email address"**
5. Se abrirá una página confirmando la verificación

### 4️⃣ Iniciar Sesión (Sin Verificar)
Si intentas iniciar sesión **ANTES** de verificar:

1. Ve a **Login**
2. Ingresa:
   - Email: tu_email@gmail.com
   - Contraseña: Test123456
3. Presiona **Iniciar Sesión**
4. Verás un diálogo: **"Email No Verificado"** ⚠️
   ```
   Tu correo electrónico aún no ha sido verificado.
   
   Por favor, revisa tu bandeja de entrada (y spam)
   para verificar tu cuenta.
   
   ¿No recibiste el correo?
   ```
5. Opciones:
   - **Reenviar Correo** → Envía otro email de verificación
   - **Continuar de todos modos** → Accede a la app (opcional)

### 5️⃣ Iniciar Sesión (Con Email Verificado)
Después de verificar el email:

1. Ve a **Login**
2. Ingresa tus credenciales
3. Presiona **Iniciar Sesión**
4. ✅ Accederás directamente al **Home** sin advertencias

## 📧 Ejemplo de Email que Recibirás

```
De: noreply@gestor-de-gastos-jc.firebaseapp.com
Asunto: Verify your email for gestor-de-gastos-jc

Hello,

Follow this link to verify your email address.

[Verify email address]

If you didn't ask to verify this address, you can ignore this email.

Thanks,

Your gestor-de-gastos-jc team
```

## 🧪 Testing Completo

### Escenario 1: Flujo Normal ✅
```
1. Registrar usuario → ✅ Email enviado
2. Abrir correo → ✅ Email recibido
3. Verificar email → ✅ Email verificado
4. Iniciar sesión → ✅ Acceso directo
```

### Escenario 2: Sin Verificar ⚠️
```
1. Registrar usuario → ✅ Email enviado
2. Ignorar correo → ⚠️
3. Intentar login → ⚠️ Advertencia mostrada
4. Reenviar correo → ✅ Nuevo email enviado
5. Verificar email → ✅ Email verificado
6. Iniciar sesión → ✅ Acceso directo
```

### Escenario 3: Email No Llega 📧
```
1. Registrar usuario → ✅
2. No recibe correo → 📧
3. Intenta login → ⚠️ Advertencia
4. Presiona "Reenviar Correo" → ✅ Nuevo email
5. Revisa SPAM → 📧 Email encontrado
6. Verifica email → ✅
```

## 🔍 Ver Logs en Consola

Durante el registro verás:
```
🔐 Iniciando registro para: test@ejemplo.com
✅ Usuario creado en Firebase Auth: abc123xyz
✅ DisplayName actualizado: Test User
📝 Creando perfil en Firestore para: abc123xyz
✅ Perfil guardado exitosamente en Firestore
📧 Email de verificación enviado a: test@ejemplo.com
```

Durante el login verás:
```
🔐 Intentando login con: test@ejemplo.com
✅ Login exitoso - Usuario: test@ejemplo.com
🔐 isAuthenticated: true
⚠️ Email no verificado  (si no está verificado)
✅ Navegando a /home...
```

## ⚙️ Configuración Firebase (Solo Primera Vez)

### Verificar en Firebase Console:
1. Ve a: https://console.firebase.google.com/
2. Selecciona tu proyecto: **gestor-de-gastos-jc**
3. **Authentication** → **Sign-in method**
4. Verifica: ✅ **Email/Password** habilitado
5. **Authentication** → **Templates**
6. Personaliza el email de verificación (opcional)

## 🐛 Problemas Comunes

### ❌ Email no llega
**Solución:**
1. Revisa **SPAM** primero
2. Espera 5 minutos
3. Usa "Reenviar Correo" en el diálogo
4. Verifica que el email sea válido

### ❌ "Email already in use"
**Solución:**
1. Ve a Firebase Console → Authentication → Users
2. Elimina el usuario
3. O usa el flujo de Login

### ❌ "Too many requests"
**Solución:**
1. Espera unos minutos
2. Firebase limita intentos por seguridad

### ❌ Usuario no puede hacer login
**Solución:**
1. Verifica credenciales
2. Revisa que el usuario exista en Firebase Console
3. Verifica los logs en consola

## 📱 Probar en Dispositivo Real

### Android:
```bash
flutter run -d <device-id>
```

### iOS:
```bash
flutter run -d <device-id>
```

### Ventajas:
- ✅ Emails se abren en app nativa
- ✅ Mejor experiencia de usuario
- ✅ Notificaciones reales

## ✅ Checklist Final

Antes de marcar como completado, verifica:

- [ ] ✅ Registro envía email
- [ ] ✅ Email llega (revisar spam)
- [ ] ✅ Enlace de verificación funciona
- [ ] ✅ Login muestra advertencia si no verificado
- [ ] ✅ "Reenviar Correo" funciona
- [ ] ✅ Login permite acceso después de verificar
- [ ] ✅ Logs muestran información correcta
- [ ] ✅ No hay errores en consola

## 📚 Documentos Relacionados

- [PROBLEMAS_RESUELTOS_AUTH.md](PROBLEMAS_RESUELTOS_AUTH.md) - Detalles técnicos
- [CHECKLIST_FIREBASE_EMAIL.md](CHECKLIST_FIREBASE_EMAIL.md) - Configuración completa
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Setup inicial

---

**¿Listo para probar?** 🚀
```bash
flutter run
```
