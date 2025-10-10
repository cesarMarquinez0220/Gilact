# Funcionalidad de Selección de Situación - Gilact

## Descripción

Se ha implementado una nueva funcionalidad que permite a los usuarios seleccionar su situación actual (preparto o postparto) y completar formularios específicos según su elección.

## Flujo de la Aplicación

### 1. Selección de Situación
- **Ubicación**: `lib/features/onboarding/presentation/pages/situation_selection_page.dart`
- **Funcionalidad**: Permite al usuario elegir entre "Pre-Parto" o "Post-Parto"
- **Navegación**: 
  - Si selecciona "Pre-Parto" → Navega a `/prepartum-form`
  - Si selecciona "Post-Parto" → Navega a `/postpartum-form`

### 2. Formulario de Preparto
- **Ubicación**: `lib/features/onboarding/presentation/pages/prepartum_form_page.dart`
- **Campos**:
  - Fecha aproximada de nacimiento (obligatorio)
- **Almacenamiento**: `Users/{userId}/situacion/preparto`
- **Estructura de datos**:
  ```json
  {
    "expectedBirthDate": "Timestamp",
    "createdAt": "Timestamp",
    "updatedAt": "Timestamp",
    "additionalData": "Map<String, dynamic>"
  }
  ```

### 3. Formulario de Postparto
- **Ubicación**: `lib/features/onboarding/presentation/pages/postpartum_form_page.dart`
- **Campos**:
  - Nombre del bebé (obligatorio)
  - Fecha de nacimiento (obligatorio)
  - Lugar de nacimiento (obligatorio)
  - Peso al nacer (obligatorio)
  - Última menstruación (obligatorio)
  - Edad gestacional (calculada automáticamente)
- **Almacenamiento**: `Users/{userId}/situacion/postparto`
- **Estructura de datos**:
  ```json
  {
    "babyName": "String",
    "birthDate": "Timestamp",
    "birthPlace": "String",
    "birthWeight": "double",
    "gestationalAge": "int",
    "lastMenstruation": "Timestamp",
    "createdAt": "Timestamp",
    "updatedAt": "Timestamp",
    "additionalData": "Map<String, dynamic>"
  }
  ```

## Arquitectura Implementada

### Estructura de Carpetas
```
lib/features/onboarding/
├── data/
│   ├── datasources/
│   │   └── onboarding_remote_data_source.dart
│   └── models/
│       ├── prepartum_info_model.dart
│       └── postpartum_info_model.dart
├── domain/
│   └── entities/
│       ├── prepartum_info.dart
│       └── postpartum_info.dart
└── presentation/
    └── pages/
        ├── prepartum_form_page.dart
        ├── postpartum_form_page.dart
        └── situation_selection_page.dart (modificado)
```

### Patrones Utilizados

1. **Clean Architecture**: Separación clara entre capas de datos, dominio y presentación
2. **Repository Pattern**: Data sources para manejar la persistencia
3. **Model-Entity Pattern**: Separación entre modelos de datos y entidades de dominio
4. **Dependency Injection**: Uso de GetIt para inyección de dependencias

### Componentes Clave

#### Entidades de Dominio
- `PrepartumInfo`: Representa la información de preparto
- `PostpartumInfo`: Representa la información de postparto

#### Modelos de Datos
- `PrepartumInfoModel`: Extiende la entidad para manejo de Firestore
- `PostpartumInfoModel`: Extiende la entidad para manejo de Firestore

#### Data Sources
- `OnboardingRemoteDataSource`: Interfaz para operaciones de datos
- `OnboardingRemoteDataSourceImpl`: Implementación con Firestore

## Rutas Agregadas

Se agregaron las siguientes rutas en `main.dart`:
- `/prepartum-form` → `PrepartumFormPage`
- `/postpartum-form` → `PostpartumFormPage`

## Validaciones Implementadas

### Formulario de Preparto
- Fecha aproximada de nacimiento obligatoria
- Fecha debe estar entre hoy y máximo 1 año en el futuro

### Formulario de Postparto
- Todos los campos son obligatorios
- Validación de formato de peso (número decimal)
- Cálculo automático de edad gestacional basado en fechas
- Validación de fechas (nacimiento no puede ser futura)

## Características de UX/UI

### Animaciones
- Animaciones de entrada suaves con `FadeTransition` y `SlideTransition`
- Partículas animadas de fondo
- Transiciones entre pasos del formulario

### Diseño Responsivo
- Formularios adaptables a diferentes tamaños de pantalla
- Campos de entrada con validación visual
- Botones con estados de carga

### Feedback al Usuario
- Diálogos de confirmación antes de guardar
- Mensajes de éxito y error usando `DialogExample`
- Validación en tiempo real de campos

## Manejo de Errores

- Captura de excepciones en operaciones de Firestore
- Mensajes de error amigables para el usuario
- Manejo de estados de carga y error en la UI

## Próximos Pasos Sugeridos

1. **Implementar BLoC para Onboarding**: Crear un BLoC específico para manejar el estado de los formularios
2. **Agregar Validaciones Adicionales**: Implementar validaciones más específicas según reglas médicas
3. **Implementar Edición**: Permitir editar la información guardada
4. **Agregar Notificaciones**: Implementar recordatorios basados en las fechas ingresadas
5. **Integrar con Analytics**: Agregar tracking de eventos para análisis de uso

## Consideraciones de Seguridad

- Validación de datos en el cliente y servidor
- Sanitización de inputs del usuario
- Manejo seguro de fechas y cálculos
- Validación de permisos de usuario antes de guardar datos
