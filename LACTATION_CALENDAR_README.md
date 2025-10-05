# Calendario de Lactancia Materna - Gilact

## 📅 Descripción

El Calendario de Lactancia Materna es una funcionalidad integrada en la aplicación Gilact que permite a las madres registrar y hacer seguimiento de sus sesiones de lactancia de manera fácil y visual.

## ✨ Características Principales

### 🎯 Vistas Múltiples
- **Vista Diaria**: Registros detallados del día seleccionado
- **Vista Semanal**: Resumen de la semana con registros por día
- **Vista Mensual**: Calendario completo con indicadores visuales

### 📊 Tipos de Registro
- **Lactancia Directa**: Alimentación directa del bebé
- **Extracción**: Uso de extractor de leche
- **Biberón**: Alimentación con leche materna extraída

### 📈 Estadísticas Inteligentes
- Total de sesiones registradas
- Duración total y promedio
- Sesiones del día actual
- Tiempo total de lactancia hoy

### 🎨 Diseño Amigable
- Interfaz intuitiva y fácil de usar
- Diseño adaptado para madres ocupadas
- Colores suaves y elementos visuales claros
- Animaciones suaves para mejor experiencia

## 🚀 Funcionalidades Implementadas

### ✅ Completado
- [x] Estructura de calendario con vistas múltiples
- [x] Modelos de datos para registros de lactancia
- [x] Widget de calendario con diseño amigable
- [x] Formulario rápido para registro (demo)
- [x] Integración en la página principal de navegación
- [x] Persistencia de datos local con SQLite
- [x] Estadísticas en tiempo real
- [x] Navegación fluida entre vistas

### 🔄 En Desarrollo
- [ ] Formulario completo de registro de lactancia
- [ ] Edición de registros existentes
- [ ] Notificaciones de recordatorios
- [ ] Exportación de datos
- [ ] Sincronización con otros dispositivos

## 🏗️ Arquitectura Técnica

### 📁 Estructura de Archivos
```
lib/features/lactation/
├── domain/
│   └── entities/
│       └── lactation_record.dart
├── data/
│   └── datasources/
│       └── lactation_database.dart
└── presentation/
    ├── pages/
    │   ├── lactation_calendar.dart
    │   └── lactation_calendar_demo.dart
    └── widgets/
        └── add_record_dialog.dart
```

### 🗄️ Base de Datos
- **SQLite**: Persistencia local de datos
- **Tabla**: `lactation_records`
- **Campos**: id, dateTime, duration, type, notes, side

### 🎨 Componentes UI
- **LactationCalendar**: Widget principal del calendario
- **ViewSelector**: Selector de vista (día/semana/mes)
- **RecordCard**: Tarjeta de registro individual
- **StatsWidget**: Widget de estadísticas
- **AddRecordDialog**: Diálogo para agregar registros

## 📱 Cómo Usar

### 1. Acceso al Calendario
- Desde la página principal, toca el botón "Calendario"
- O usa la navegación inferior para ir directamente

### 2. Navegación entre Vistas
- **Día**: Toca los botones de navegación o selecciona una fecha
- **Semana**: Navega semana por semana
- **Mes**: Cambia de mes usando los controles

### 3. Agregar Registros
- Toca el botón "+" en la parte inferior
- Completa el formulario con los datos requeridos
- Guarda el registro

### 4. Ver Estadísticas
- Toca el ícono de estadísticas en el header
- Revisa las métricas de lactancia

## 🎯 Beneficios para las Madres

### ⏰ Seguimiento Preciso
- Registro exacto de horarios y duraciones
- Seguimiento de patrones de alimentación
- Identificación de tendencias

### 📊 Información Valiosa
- Estadísticas útiles para consultas médicas
- Datos para ajustar rutinas de alimentación
- Historial completo de lactancia

### 🧘 Tranquilidad
- Interfaz simple y no intimidante
- Diseño pensado para madres ocupadas
- Acceso rápido desde cualquier parte de la app

## 🔧 Configuración Técnica

### Dependencias Agregadas
```yaml
dependencies:
  sqflite: ^2.3.0
  path: ^1.8.3
```

### Integración en Navegación
- Nueva pestaña "Calendario" en la navegación inferior
- Acceso directo desde la página principal
- Navegación fluida entre secciones

## 🚀 Próximos Pasos

1. **Completar Formulario de Registro**
   - Implementar formulario completo con validaciones
   - Agregar opciones avanzadas (lado, notas, etc.)

2. **Funcionalidades Avanzadas**
   - Recordatorios automáticos
   - Exportación de datos
   - Sincronización en la nube

3. **Mejoras de UX**
   - Temas personalizables
   - Accesibilidad mejorada
   - Modo offline completo

## 💡 Consideraciones de Diseño

### Para Madres Ocupadas
- Botones grandes y fáciles de tocar
- Colores suaves y relajantes
- Información clara y concisa
- Acceso rápido a funciones principales

### Accesibilidad
- Contraste adecuado de colores
- Texto legible en diferentes tamaños
- Navegación intuitiva
- Feedback visual claro

---

**Desarrollado con ❤️ para las madres que amamantan**
