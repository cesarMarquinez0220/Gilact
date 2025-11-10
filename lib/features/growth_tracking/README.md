# Growth Tracking Module

Módulo dedicado al seguimiento y análisis de crecimiento del bebé, incluyendo:
- Tendencias de peso con percentiles OMS
- Análisis de alimentación
- Gráficas de crecimiento
- Alertas de crecimiento

## Estructura Clean Architecture

```
growth_tracking/
├── domain/
│   ├── entities/          # Entidades de dominio
│   ├── repositories/      # Interfaces de repositorios
│   └── services/          # Lógica de negocio
├── data/
│   ├── datasources/       # Fuentes de datos (reutiliza lactation)
│   ├── models/            # Modelos de datos
│   └── repositories/      # Implementación de repositorios
└── presentation/
    ├── widgets/           # Widgets de gráficas
    └── pages/             # Páginas (si es necesario)
```

## Dependencias

Este módulo depende de:
- `lactation`: Para obtener registros de lactancia y peso
- `core`: Para servicios compartidos (ConnectivityService)

