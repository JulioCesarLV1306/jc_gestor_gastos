# 🎯 Navegación Rápida: Páginas ML

## Acceder a las Páginas ML desde tu App

### Opción 1: Desde código (context.go)

```dart
import 'package:go_router/go_router.dart';

// Navegar a ML con Colab
context.go('/colab-ml');

// Navegar a ML Training local
context.go('/ml-training');
```

### Opción 2: Agregar botones en el menú

Edita `lib/modules/home/screen_home.dart` y agrega:

```dart
// En el drawer o AppBar, agrega estos botones:

ListTile(
  leading: Icon(Icons.cloud),
  title: Text('ML con Colab'),
  subtitle: Text('Predicciones en la nube'),
  onTap: () {
    context.go('/colab-ml');
  },
),

ListTile(
  leading: Icon(Icons.model_training),
  title: Text('Entrenamiento ML'),
  subtitle: Text('Entrenar modelo local'),
  onTap: () {
    context.go('/ml-training');
  },
),
```

### Opción 3: FloatingActionButton en Home

```dart
// En screen_home.dart
floatingActionButton: FloatingActionButton.extended(
  onPressed: () => context.go('/colab-ml'),
  icon: Icon(Icons.analytics),
  label: Text('ML'),
  backgroundColor: Colors.deepPurple,
),
```

### Opción 4: Card en la pantalla principal

```dart
Card(
  child: ListTile(
    leading: Icon(Icons.auto_awesome, size: 40, color: Colors.purple),
    title: Text('Predicción de Gastos', 
      style: TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text('IA con Google Colab'),
    trailing: Icon(Icons.arrow_forward_ios),
    onTap: () => context.go('/colab-ml'),
  ),
)
```

---

## 📱 Rutas Disponibles

### `/colab-ml` - ML con Google Colab
**Características:**
- 🔗 Conectar con API de Colab
- 🎓 Entrenar modelo en la nube
- 🔮 Predicciones de gastos futuros
- 🔍 Detección de anomalías
- 📊 Visualización de métricas

**Cuándo usar:**
- Predicciones precisas con datos de muchos usuarios
- Detección avanzada de anomalías
- Recomendaciones personalizadas basadas en ML

### `/ml-training` - Entrenamiento Local
**Características:**
- 📊 Análisis estadístico de usuarios
- 📈 Patrones de gasto
- 📁 Exportar datos a CSV/JSON
- 💾 Guardar en Firestore

**Cuándo usar:**
- Recopilar datos para entrenar
- Análisis de patrones locales
- Exportar datos para uso externo

---

## 🎨 Ejemplo de Implementación Completa

### 1. Agregar Sección ML en Home

```dart
// lib/modules/home/screen_home.dart

class ScreenHome extends StatelessWidget {
  const ScreenHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestor Financiero'),
        actions: [
          // Botón de ML en AppBar
          IconButton(
            icon: Icon(Icons.psychology),
            tooltip: 'Machine Learning',
            onPressed: () => context.go('/colab-ml'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            
            // Sección ML
            ExpansionTile(
              leading: Icon(Icons.auto_awesome),
              title: Text('Machine Learning'),
              children: [
                ListTile(
                  leading: Icon(Icons.cloud),
                  title: Text('ML con Colab'),
                  onTap: () {
                    Navigator.pop(context); // Cerrar drawer
                    context.go('/colab-ml');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.model_training),
                  title: Text('Entrenar Modelo'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/ml-training');
                  },
                ),
              ],
            ),
            
            // Otros items del menú...
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Card destacado para ML
            _buildMLCard(context),
            
            SizedBox(height: 16),
            
            // Resto del contenido...
          ],
        ),
      ),
    );
  }

  Widget _buildMLCard(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.auto_graph, size: 32, color: Colors.white),
          ),
          title: Text(
            '🤖 Predicción Inteligente',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Predice tus gastos futuros con IA',
            style: TextStyle(color: Colors.white70),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
          onTap: () => context.go('/colab-ml'),
        ),
      ),
    );
  }
}
```

---

## 🎯 Bottom Navigation con ML

Si usas BottomNavigationBar, agrega un tab para ML:

```dart
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
    BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Gastos'),
    BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'ML'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
  ],
  currentIndex: _selectedIndex,
  onTap: (index) {
    if (index == 2) {
      context.go('/colab-ml'); // Tab de ML
    }
    setState(() => _selectedIndex = index);
  },
)
```

---

## 📊 Dashboard ML

Crea un widget especializado:

```dart
class MLDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Machine Learning',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        
        SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildMLOption(
                context,
                'Predicciones',
                'Gastos futuros con IA',
                Icons.cloud,
                '/colab-ml',
                Colors.blue,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildMLOption(
                context,
                'Entrenamiento',
                'Datos y análisis',
                Icons.model_training,
                '/ml-training',
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMLOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String route,
    Color color,
  ) {
    return Card(
      child: InkWell(
        onTap: () => context.go(route),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 48, color: color),
              SizedBox(height: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 🚀 Testing Rápido

Para probar las rutas:

```dart
// En cualquier widget
ElevatedButton(
  onPressed: () {
    // Test ruta Colab
    context.go('/colab-ml');
  },
  child: Text('Test Colab ML'),
),

ElevatedButton(
  onPressed: () {
    // Test ruta Training
    context.go('/ml-training');
  },
  child: Text('Test ML Training'),
),
```

---

## ✅ Checklist de Integración

- [ ] Importar go_router en screen_home.dart
- [ ] Agregar botones en drawer/menu
- [ ] Probar navegación a `/colab-ml`
- [ ] Probar navegación a `/ml-training`
- [ ] Agregar iconos visuales
- [ ] Personalizar estilos
- [ ] Documentar para el equipo

---

**¡Listo para integrar ML en tu app!** 🎉
