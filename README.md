# 🛠️ Core Keeper Dedicated Server (Docker)

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green.style=for-the-badge)

[English](#english) | [Español](#español)

---

<a name="english"></a>
## 🇬🇧 English

A production-ready Docker setup for hosting a **Core Keeper Dedicated Server** with automatic world persistence, customizable configurations, and low resource overhead.

### 📋 Prerequisites

- **Docker Engine** (`>= 20.10.0`)
- **Docker Compose** (`>= v2.0.0`)
- **Host System:** Linux (Ubuntu/Debian recommended), Arch, or WSL2 on Windows.
- **Ports Required:** UDP `27015-27016` (Default Game & Query ports)

---

### 🚀 Quick Start

1. **Clone the repository:**
   ```bash
   git clone git@dangergps.tech:tonyprox/CK-DS-Docker.git
   cd CK-DS-Docker
   ```

2. **Configure Environment Variables:**
   Copy the example environment file and adjust your server settings:
   ```bash
   cp .env.example .env
   nano .env
   ```

3. **Start the Container:**
   ```bash
   docker compose up -d
   ```

4. **Retrieve Server Game ID:**
   Check the container logs to obtain your join code:
   ```bash
   docker compose logs -f
   ```

---

### ⚙️ Configuration & Environment Variables

Key parameters defined in `.env`:

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `WORLD_INDEX` | `0` | World slot index to load/create |
| `WORLD_NAME` | `CoreKeeperWorld` | Name of your dedicated world |
| `WORLD_SEED` | `0` | World seed (`0` for random generation) |
| `GAME_PASSWORD` | `""` | Password required to join (leave blank for none) |
| `MAX_PLAYERS` | `100` | Maximum player limit |

---

### 📂 Persistent Data Structure

All server saves, configuration files, and world data are bound to host volumes:

```text
CK-DS-Docker/
├── docker-compose.yml
├── .env
└── data/
    ├── ServerConfig.json
    └── saves/
        └── 0.world
```

---

### 🛠️ Maintenance & Useful Commands

- **View real-time logs:**
  ```bash
  docker compose logs -f core-keeper
  ```
- **Restart Server:**
  ```bash
  docker compose restart core-keeper
  ```
- **Stop Server:**
  ```bash
  docker compose down
  ```
- **Update Server:**
  ```bash
  docker compose pull
  docker compose up -d --build
  ```

---
---

<a name="español"></a>
## 🇪🇸 Español

Una configuración de Docker lista para producción para alojar un **Servidor Dedicado de Core Keeper** con persistencia de mundo automática, configuraciones personalizables y bajo consumo de recursos.

### 📋 Requisitos Previos

- **Docker Engine** (`>= 20.10.0`)
- **Docker Compose** (`>= v2.0.0`)
- **Sistema Operativo:** Linux (Ubuntu/Debian recomendado), Arch o WSL2 en Windows.
- **Puertos Requeridos:** UDP `27015-27016` (Puertos predeterminados de Juego y Consulta)

---

### 🚀 Inicio Rápido

1. **Clonar el repositorio:**
   ```bash
   git clone git@dangergps.tech:tonyprox/CK-DS-Docker.git
   cd CK-DS-Docker
   ```

2. **Configurar Variables de Entorno:**
   Copia el archivo de entorno de ejemplo y ajusta la configuración de tu servidor:
   ```bash
   cp .env.example .env
   nano .env
   ```

3. **Iniciar el Contenedor:**
   ```bash
   docker compose up -d
   ```

4. **Obtener el Game ID del Servidor:**
   Revisa los registros del contenedor para obtener tu código de acceso al servidor:
   ```bash
   docker compose logs -f
   ```

---

### ⚙️ Configuración y Variables de Entorno

Parámetros clave definidos en el archivo `.env`:

| Variable | Valor por Defecto | Descripción |
| :--- | :--- | :--- |
| `WORLD_INDEX` | `0` | Índice del slot del mundo a cargar/crear |
| `WORLD_NAME` | `CoreKeeperWorld` | Nombre del mundo dedicado |
| `WORLD_SEED` | `0` | Semilla del mundo (`0` para generación aleatoria) |
| `GAME_PASSWORD` | `""` | Contraseña requerida para entrar (vacío para sin clave) |
| `MAX_PLAYERS` | `100` | Límite máximo de jugadores permitidos |

---

### 📂 Estructura de Datos Persistentes

Todas las partidas guardadas, archivos de configuración y datos del mundo están vinculados a volúmenes del host:

```text
CK-DS-Docker/
├── docker-compose.yml
├── .env
└── data/
    ├── ServerConfig.json
    └── saves/
        └── 0.world
```

---

### 🛠️ Mantenimiento y Comandos Útiles

- **Ver registros en tiempo real:**
  ```bash
  docker compose logs -f core-keeper
  ```
- **Reiniciar Servidor:**
  ```bash
  docker compose restart core-keeper
  ```
- **Detener Servidor:**
  ```bash
  docker compose down
  ```
- **Actualizar Servidor:**
  ```bash
  docker compose pull
  docker compose up -d --build
  ```

---

## 📜 License / Licencia

Distributed under the MIT License. See `LICENSE` for more information.