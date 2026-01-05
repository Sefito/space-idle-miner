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

## Fase 6: Mejoras de Expedición (Completado)

La Fase 6 introduce mejoras significativas a la experiencia de expedición, transformándola de un sistema automático a uno interactivo:

### 1. Movimiento de Nave (2D con Física)
- **Controles**: WASD o flechas direccionales
- **Física**: Aceleración y fricción para movimiento "espacial" suave
- **Límites**: La nave permanece dentro de los límites de la pantalla
- El movimiento se detiene gradualmente al soltar las teclas

### 2. Sistema de Asteroides Múltiples
- **Cantidad**: Entre 5 y 15 asteroides simultáneos en cada expedición
- **Spawn inteligente**: Los asteroides aparecen en posiciones aleatorias, evitando spawnearse muy cerca de la nave
- **Respawn automático**: Cuando un asteroide se destruye, aparece uno nuevo para mantener la cantidad objetivo

### 3. Sistema de Selección de Objetivos
- **Click para seleccionar**: Haz click en cualquier asteroide para establecerlo como objetivo
- **Auto-target**: Si no hay objetivo seleccionado, el sistema selecciona automáticamente el asteroide más cercano
- **Feedback visual**: El asteroide objetivo se resalta con un color diferente
- **Re-targeting automático**: Cuando un objetivo se destruye, se selecciona automáticamente el siguiente más cercano

### 4. Minado con Progreso Visual
- **Sistema de HP**: Cada asteroide tiene puntos de vida que disminuyen según tu velocidad de minería
- **Barra de progreso**: Cada asteroide muestra una barra de progreso sobre él cuando está siendo minado
- **Recompensas**: Al destruir un asteroide, obtienes minerales instantáneamente
- El sistema de minería usa el mismo `mining_rate` que antes, pero ahora aplicado como daño

### 5. Feedback Visual Mejorado
- **Láser**: Un rayo láser rojo conecta la nave con el asteroide objetivo durante el minado
- **Partículas de impacto**: Efectos de partículas aparecen en el punto de impacto del láser
- **Efectos hover**: Los asteroides cambian de color al pasar el mouse sobre ellos
- **Flash de destrucción**: Efecto visual al destruir un asteroide

### 6. Cámara Dinámica
- **Seguimiento suave**: La cámara sigue a la nave con interpolación suave
- **Límites de área**: La cámara está configurada para mantener el juego visible
- **Sin mareo**: El movimiento de cámara está optimizado para no causar molestias

### Controles
- **W / Flecha Arriba**: Mover nave hacia arriba
- **S / Flecha Abajo**: Mover nave hacia abajo
- **A / Flecha Izquierda**: Mover nave hacia la izquierda
- **D / Flecha Derecha**: Mover nave hacia la derecha
- **Click Izquierdo**: Seleccionar asteroide objetivo

## Licencia

Este proyecto aún no tiene una licencia definida. Para más información sobre el uso del código, contacta con el autor del repositorio.
