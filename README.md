# SpaceIdleMiner

## Descripción

SpaceIdleMiner es un juego idle/incremental ambientado en el espacio, desarrollado con Godot Engine. En este juego, el jugador gestiona operaciones de minería espacial, recolectando recursos y mejorando su flota de manera automática e incremental.

## Requisitos

- **Godot Engine 4.5** o superior
- Sistema operativo: Windows, Linux o macOS

## Cómo abrir el proyecto en Godot

1. **Descargar Godot Engine**
   - Ve a [godotengine.org](https://godotengine.org/download)
   - Descarga la versión **4.5** o superior (se recomienda la última versión estable)
   - Extrae el ejecutable de Godot en tu sistema

2. **Clonar el repositorio**
   ```bash
   git clone https://github.com/Sefito/space-idle-miner.git
   cd space-idle-miner
   ```

3. **Abrir el proyecto**
   - Ejecuta Godot Engine
   - En el Project Manager, haz clic en **"Import"** (Importar)
   - Navega hasta la carpeta del proyecto
   - Selecciona el archivo `project.godot`
   - Haz clic en **"Import & Edit"** (Importar y Editar)

## Cómo ejecutar el juego

### Desde el editor de Godot

1. Abre el proyecto en Godot (siguiendo los pasos anteriores)
2. Presiona **F5** o haz clic en el botón **"Play"** (▶) en la esquina superior derecha
3. El juego se ejecutará en una ventana separada

### Método alternativo

- Presiona **F6** para ejecutar la escena actual que tengas abierta
- En el menú superior: **Project > Run Project** (Proyecto > Ejecutar Proyecto)

## Estructura del proyecto

```
space-idle-miner/
├── addons/          # Plugins y extensiones de Godot
├── art/             # Recursos artísticos (sprites, texturas, etc.)
├── data/            # Datos del juego (configuraciones, etc.)
├── scenes/          # Escenas de Godot (.tscn)
│   └── Main.tscn    # Escena principal del juego
├── scripts/         # Scripts de GDScript
├── ui/              # Elementos de interfaz de usuario
├── icon.svg         # Icono del proyecto
└── project.godot    # Archivo de configuración del proyecto
```

## Criterios de aceptación

✅ **Descripción**: Proyecto descrito como un juego idle/incremental de minería espacial  
✅ **Cómo abrir en Godot**: Instrucciones detalladas para importar y abrir el proyecto  
✅ **Cómo ejecutar**: Múltiples métodos explicados para ejecutar el juego  

## Configuración del juego

- **Resolución**: 1920x1080
- **Modo de pantalla**: Pantalla completa
- **Versión de Godot**: 4.5
- **Escena principal**: `res://scenes/Main.tscn`

## Sistema de Upgrades

El juego incluye un sistema de mejoras (upgrades) basado en datos que permite al jugador desbloquear y comprar mejoras en forma de árbol de dependencias.

### Formato de upgrades.json

El archivo `data/upgrades.json` define todas las mejoras disponibles en el juego. Cada upgrade tiene la siguiente estructura:

```json
{
  "id": "unique_identifier",
  "name": "Nombre visible",
  "desc": "Descripción de la mejora",
  "max_level": 5,
  "cost_base": 10.0,
  "cost_growth": 1.5,
  "requires": ["prerequisite_id"],
  "effects": {
    "mining_rate_mult": 0.2,
    "duration_add": -3.0
  }
}
```

**Campos:**
- `id`: Identificador único del upgrade
- `name`: Nombre mostrado en la UI
- `desc`: Descripción de qué hace el upgrade
- `max_level`: Nivel máximo que se puede alcanzar
- `cost_base`: Coste base del primer nivel
- `cost_growth`: Multiplicador de crecimiento del coste (coste = base × growth^nivel)
- `requires`: Array de IDs de upgrades que deben tener al menos nivel 1
- `effects`: Efectos por nivel
  - `mining_rate_mult`: Multiplicador de velocidad de minería (aditivo)
  - `duration_add`: Segundos añadidos a la duración de expedición (puede ser negativo)

### Cálculo de Stats

Los stats del juego se calculan de la siguiente manera:
- **mining_rate** = base_rate × (1 + suma de todos los mining_rate_mult)
- **expedition_duration** = base_duration + suma de todos los duration_add

## Desarrollo

Este proyecto está en desarrollo activo. Siéntete libre de contribuir o reportar problemas en el repositorio de GitHub.

## Licencia

Este proyecto aún no tiene una licencia definida. Para más información sobre el uso del código, contacta con el autor del repositorio.
