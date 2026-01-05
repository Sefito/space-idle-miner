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
│   ├── asteroids.png           # Spritesheet con 6 asteroides diferentes
│   ├── expedition_background.png  # Fondo del espacio para expediciones
│   └── ship.png                # Sprite de la nave del jugador
├── autoload/        # Scripts globales (autoload/singleton)
│   ├── Game.gd      # Manejo de estados del juego y variables globales
│   ├── Upgrades.gd  # Sistema de upgrades y cálculo de stats
│   └── Save.gd      # Sistema de guardado y carga de progreso
├── data/            # Datos del juego (configuraciones, etc.)
│   └── upgrades.json  # Definición de todas las mejoras disponibles
├── scenes/          # Escenas de Godot (.tscn) y scripts asociados
│   ├── Main.tscn              # Escena principal del juego
│   ├── Expedition.tscn        # Escena de expedición espacial
│   ├── Expedition.gd          # Lógica de expedición y minado
│   ├── Ship.tscn              # Escena de la nave del jugador
│   ├── Ship.gd                # Control de movimiento de la nave
│   ├── Asteroid.tscn          # Escena de asteroide individual
│   ├── Asteroid.gd            # Lógica de asteroide (HP, minado, etc.)
│   └── AsteroidSpawner.gd     # Sistema de generación de asteroides
├── ui/              # Elementos de interfaz de usuario
│   ├── Screen_Shop.tscn       # Pantalla de tienda/upgrades
│   ├── Screen_Shop.gd         # Lógica de la tienda
│   ├── HUD_Expedition.tscn    # HUD durante expediciones
│   └── HUD_Expedition.gd      # Actualización del HUD
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

## Flujo del Juego

El juego alterna entre dos estados principales:

### Estado: Tienda (SHOP)
- El jugador puede comprar y mejorar upgrades usando minerales recolectados
- Se muestran los minerales totales acumulados
- El jugador puede iniciar una nueva expedición cuando esté listo
- El progreso se guarda automáticamente al regresar de una expedición

### Estado: Expedición (EXPEDITION)
- El jugador controla una nave en un entorno espacial
- Múltiples asteroides aparecen en el área de juego
- El jugador puede moverse libremente y seleccionar asteroides para minar
- Los asteroides son minados automáticamente una vez seleccionados
- La expedición tiene un límite de tiempo (por defecto 30 segundos)
- Al destruir asteroides, se obtienen minerales inmediatamente
- La expedición termina cuando se agota el tiempo
- Los minerales recolectados se suman al total y el juego regresa al estado de Tienda

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

### 6. Cámara Fija
- **Vista estática**: La cámara permanece fija en el centro del viewport
- **Área de juego visible**: El viewport completo (1920x1080) es el área de juego
- **Límites de nave**: La nave permanece dentro de los límites del viewport mientras el jugador la controla

### Controles
- **W / Flecha Arriba**: Mover nave hacia arriba
- **S / Flecha Abajo**: Mover nave hacia abajo
- **A / Flecha Izquierda**: Mover nave hacia la izquierda
- **D / Flecha Derecha**: Mover nave hacia la derecha
- **Click Izquierdo**: Seleccionar asteroide objetivo

### Detalles Técnicos de Implementación

#### Parámetros de Movimiento de la Nave
- **Velocidad máxima**: 400 píxeles/segundo
- **Aceleración**: 1200 píxeles/segundo²
- **Fricción**: 800 píxeles/segundo²
- **Tipo de nodo**: CharacterBody2D con física integrada

#### Configuración de Asteroides
- **Rango de cantidad**: 5-15 asteroides por expedición (aleatorio)
- **Vida base**: 100 HP por asteroide
- **Recompensa base**: 10 minerales por asteroide
- **Distancia mínima de spawn**: 300 píxeles desde la nave
- **Margen de spawn**: 5% del viewport en cada borde
- **Variaciones visuales**: 6 sprites diferentes con rotación y escala aleatoria

#### Sistema de Minado
- **Frecuencia de láser**: Se muestra cada 0.5 segundos
- **Duración de flash**: 0.1 segundos por disparo
- **Daño**: Basado en el `mining_rate` del jugador (aplicado continuamente)
- **Color del láser**: Rojo (RGB: 1.0, 0.2, 0.2, alpha: 0.8)
- **Ancho del láser**: 3 píxeles

#### Feedback Visual
- **Color hover**: Brillo aumentado a 1.2 (20% más brillante)
- **Color objetivo**: Tinte rojo (RGB: 1.5, 0.8, 0.8)
- **Partículas de impacto**: 20 partículas por explosión
- **Duración de partículas**: 0.5 segundos
- **Velocidad de partículas**: 50-150 píxeles/segundo

#### Duración de Expedición
- **Duración base**: 30 segundos
- **Modificable**: Puede ser ajustada mediante upgrades con el efecto `duration_add`
- **Comportamiento**: La expedición termina automáticamente cuando el tiempo llega a 0
- **Progreso guardado**: Los minerales recolectados se guardan al finalizar la expedición

## Licencia

Este proyecto aún no tiene una licencia definida. Para más información sobre el uso del código, contacta con el autor del repositorio.
