# Navigation Feature - Clean Architecture

Esta carpeta contiene la funcionalidad de navegación principal de la aplicación, refactorizada siguiendo los principios de Clean Architecture.

## 📁 Estructura de Carpetas

```
lib/features/navigation/
├── domain/
│   └── services/
│       ├── navigation_service.dart      # Lógica de navegación y estado del usuario
│       ├── countdown_service.dart       # Lógica del contador de cuenta regresiva
│       └── app_color_service.dart       # Configuración de colores y gradientes
├── presentation/
│   ├── pages/
│   │   ├── home_page.dart               # Página principal de inicio
│   │   ├── health_page.dart             # Página de salud del bebé
│   │   ├── profile_page.dart            # Página de perfil del usuario
│   │   └── main_navigation_page_refactored.dart  # Página principal refactorizada
│   └── widgets/
│       ├── home_feature_card.dart       # Tarjeta de funcionalidades
│       ├── countdown_card.dart          # Contador de cuenta regresiva
│       ├── modern_header.dart           # Header modernizado
│       ├── modern_bottom_navigation_bar.dart  # Barra de navegación inferior
│       ├── preparto_profile_widget.dart # Widget de perfil preparto
│       └── postparto_profile_widget.dart # Widget de perfil postparto
```

## 🏗️ Arquitectura Implementada

### Domain Layer (Capa de Dominio)
- **Services**: Contienen la lógica de negocio pura
  - `NavigationService`: Maneja navegación y estado del usuario
  - `CountdownService`: Calcula días restantes y progreso del embarazo
  - `AppColorService`: Configuración de colores y gradientes

### Presentation Layer (Capa de Presentación)
- **Pages**: Páginas principales de la aplicación
- **Widgets**: Componentes reutilizables y modulares

## 🎨 Diseño Consistente

### Colores y Gradientes
- **Gradiente de fondo**: Consistente con Salud/Perfil
- **Colores de tarjetas**: Específicos por funcionalidad
- **AppBar**: Mantiene "Hola" con logo pero colores consistentes

### Componentes Modulares
- **HomeFeatureCard**: Tarjeta reutilizable para funcionalidades
- **CountdownCard**: Contador modular con estados específicos
- **ModernHeader**: Header con diseño consistente
- **ModernBottomNavigationBar**: Navegación inferior moderna

## 🔧 Funcionalidades

### Página de Inicio (HomePage)
- Tarjeta de Lecciones
- Contador de cuenta regresiva
- Grid de funcionalidades (condicional según estado del usuario)
- Secciones de perfil específicas

### Página de Salud (HealthPage)
- Seguimiento de peso del bebé
- Registro de temperatura
- Contactos de emergencia

### Página de Perfil (ProfilePage)
- Información del usuario
- Opciones de configuración
- Funcionalidad de cerrar sesión

## 📱 Responsive Design

Todos los componentes están diseñados para ser responsivos y adaptarse a diferentes tamaños de pantalla.

## 🚀 Beneficios de la Refactorización

1. **Mantenibilidad**: Código organizado en archivos pequeños y específicos
2. **Reutilización**: Componentes modulares y reutilizables
3. **Escalabilidad**: Fácil agregar nuevas funcionalidades
4. **Consistencia**: Diseño uniforme en toda la aplicación
5. **Testabilidad**: Componentes aislados fáciles de probar

## 🔄 Migración

Para usar la nueva estructura:

1. Reemplazar `main_navigation_page.dart` con `main_navigation_page_refactored.dart`
2. Los widgets y servicios están listos para usar
3. Mantener toda la funcionalidad existente

## 📝 Notas Técnicas

- **Sin animaciones**: Eliminadas según requerimientos del usuario
- **Fondo consistente**: Gradiente suave sin efecto "recortado"
- **Arquitectura limpia**: Separación clara de responsabilidades
- **Performance**: Componentes optimizados para mejor rendimiento
