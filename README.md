git add README.md<div align="center">

# KAHOOT

### Plataforma interactiva de aprendizaje basada en quizzes

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)

---

[Descripción](#-descripción) • [Estado](#-estado-del-proyecto) • [Instalación](#-acceso-al-proyecto) • [Tecnologías](#-tecnologías-utilizadas) • [Equipo](#-personas-contribuyentes)

</div>

---

## 📋 Tabla de Contenido

- [🎮 KAHOOT](#-kahoot)
  - [📋 Tabla de Contenido](#-tabla-de-contenido)
  - [📖 Descripción](#-descripción)
  - [🚀 Estado del Proyecto](#-estado-del-proyecto)
  - [🎬 Demostración](#-demostración)
  - [💻 Acceso al Proyecto](#-acceso-al-proyecto)
  - [🛠 Tecnologías Utilizadas](#-tecnologías-utilizadas)
  - [🏗️ Arquitectura](#-arquitectura)
  - [🏛 Estructura de Capas](#-estructura-detallada-de-capas)
  - [🔄 Flujo de Datos](#-flujo-de-datos)
  - [👥 Personas Contribuyentes](#-personas-contribuyentes)

---

## 📖 Descripción

**Kahoot** es una aplicación móvil desarrollada en Flutter que permite crear, compartir y jugar quizzes interactivos de forma divertida y educativa.

### ✨ Características principales:

- 🎯 **Creación de Quizzes** - Crea tus propios kahoots con preguntas de opción múltiple y verdadero/falso
- 🤖 **Generación con IA** - Genera quizzes automáticamente usando inteligencia artificial (Google Gemini)
- 🖼️ **Soporte Multimedia** - Añade imágenes a tus preguntas y respuestas
- 🎮 **Modo Multijugador** - Juega en tiempo real con otros usuarios mediante WebSockets
- 👤 **Gestión de Perfil** - Personaliza tu perfil y gestiona tus kahoots
- 🔐 **Autenticación Segura** - Sistema de login con almacenamiento seguro de tokens

---

## 🚀 Estado del Proyecto

<div align="center">

| Módulo | Estado |
|--------|--------|
| 🔐 Autenticación | ✅ Completado |
| 📝 Creación de Quizzes | ✅ Completado |
| 🤖 Generación con IA | ✅ Completado |
| 🖼️ Gestión Multimedia | ✅ Completado |
| 🎮 Modo Multijugador | ✅ Completado |
| 👤 Perfil de Usuario | ✅ Completado |

</div>

> 🟢 **Versión actual:** 1.0.0  
> 📅 **Última actualización:** Enero 2026

---

### 🔧 Funcionalidades

```
✅ Registro e inicio de sesión
✅ Creación de quizzes desde cero y automática con IA
✅ Subida de imágenes multimedia
✅ Preguntas de opción múltiple, verdadero/falso
✅ Configuración de tiempo y puntos
✅ Partidas en tiempo real
```

---

## 💻 Acceso al Proyecto

### 📋 Pre-requisitos

- Flutter SDK `^3.9.2`
- Dart SDK `^3.9.2`
- Android Studio / VS Code
- Git

### 🔧 Instalación

1. **Clona el repositorio**
```bash
git clone https://github.com/tu-usuario/kahoot-flutter.git
cd kahoot-flutter
```

2. **Instala las dependencias**
```bash
flutter pub get
```

3. **Configura las variables de entorno** (opcional)
```bash
# Configura tu API key de Gemini para la generación con IA
```

4. **Ejecuta la aplicación**
```bash
flutter run
```

### 📱 Compilar para producción

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 🛠 Tecnologías Utilizadas

<div align="center">

| Tecnología | Versión | Uso |
|:----------:|:-------:|:---:|
| ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white) | 3.9.2 | Framework UI |
| ![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white) | 3.9.2 | Lenguaje |
| ![Riverpod](https://img.shields.io/badge/Riverpod-00D1B2?style=flat-square&logo=flutter&logoColor=white) | 2.6.1 | Estado |
| ![Dio](https://img.shields.io/badge/Dio-FF6B6B?style=flat-square&logo=flutter&logoColor=white) | 5.7.0 | HTTP Client |
| ![Socket.IO](https://img.shields.io/badge/Socket.IO-010101?style=flat-square&logo=socket.io&logoColor=white) | 2.0.0 | WebSockets |
| ![GoRouter](https://img.shields.io/badge/GoRouter-4285F4?style=flat-square&logo=flutter&logoColor=white) | 14.6.0 | Navegación |

</div>

### 📦 Dependencias principales

```yaml
dependencies:
  flutter_riverpod: ^2.6.1     # Gestión de estado
  dio: ^5.7.0                   # Cliente HTTP
  go_router: ^14.6.0            # Navegación declarativa
  socket_io_client: ^2.0.0      # Conexión en tiempo real
  flutter_secure_storage: ^9.0.0 # Almacenamiento seguro
  image_picker: ^1.2.0          # Selección de imágenes
  shared_preferences: ^2.1.1    # Persistencia local
  url_launcher: ^6.2.5          # Lanzar URLs externas
```

### 🏗️ Arquitectura

El proyecto sigue los principios de **Clean Architecture** combinados con el patrón **MVVM** (Model-View-ViewModel). Esta estructura, junto a una separación por *features*, garantiza la separación de responsabilidades, favorece un trabajo más independiente y desacopla la lógica de negocio de la UI. El proyecto tiene la siguiente estructura:

```
lib/
├── core/                   # Núcleo de la aplicación
│   ├── domain/             # Entidades del dominio
│   ├── exceptions/         # Manejo de errores
│   ├── network/            # Configuración de red
│   ├── providers/          # Providers globales
│   └── services/           # Servicios compartidos
│
├── features/               # Módulos por funcionalidad
│   ├── auth/              # Autenticación
│   ├── create_kahoot/     # Creación de quizzes
│   ├── ai_quiz/           # Generación con IA
│   ├── media/             # Gestión multimedia
│   ├── games/             # Partidas y juegos
│   └── profile/           # Perfil de usuario
│
└── main.dart              # Punto de entrada
```

---

### 🏛 Estructura Detallada de Capas

**1. Capa de Dominio (Domain Layer)** Es el núcleo de la aplicación. Contiene la lógica de negocio pura y es totalmente independiente de librerías externas.
* **Entidades:** Modelos de negocio puros.
* **Contratos (Interfaces):** Definiciones abstractas de los Repositorios (Inversión de Dependencia).

**2. Capa de Aplicación (Application Layer)** Actúa como intermediario entre la presentación y el dominio.
* **Casos de Uso (Use Cases):** Clases que encapsulan una acción específica del negocio, orquestan la lógica y realizan validaciones previas.

**3. Capa de Infraestructura (Infrastructure Layer)** Responsable de la comunicación con el mundo exterior.
* **Implementación de Repositorios:** Clases concretas que implementan los contratos del dominio.
* **Fuentes de Datos:** Manejo de llamadas a API (Dio), mapeo de JSON a Entidades y manejo de errores.

**4. Capa de Presentación (Presentation Layer)** Responsable de la UI y el estado visual.
* **Lógica de UI (Notifier/Riverpod):** Llama a los Casos de Uso y transforma los datos en estado.
* **Vistas (UI):** Widgets que reaccionan a los cambios de estado.
* **ModelUI:** Objetos optimizados para ser consumidos por la vista.

---

### 🔄 Flujo de Datos

El flujo de información sigue un ciclo estricto desde la interacción del usuario hasta la actualización de la interfaz:

1.  **El Disparador (Presentación):** El usuario interactúa con un Widget, el cual llama a un método del Notifier.
2.  **Orquestación (Presentación → Aplicación):** El Notifier emite un estado de carga (*Loading*) e invoca al Caso de Uso.
3.  **Reglas de Negocio (Aplicación → Dominio):** El Caso de Uso valida y llama al contrato del Repositorio.
4.  **Acceso a los Datos (Infraestructura):** La implementación del repositorio ejecuta la llamada técnica (API REST), recibe el JSON y lo mapea a una Entidad.
5.  **Transmisión (Aplicación):** El Caso de Uso recibe la Entidad, aplica lógica adicional si es requerida y la devuelve al Notifier.
6.  **Composición (Presentación):** El Notifier recibe la Entidad, ensambla un objeto de presentación (ModelUI) y actualiza el estado.
7.  **Reacción (UI):** El Widget detecta el nuevo estado y se redibuja automáticamente.

## 👥 Contribuyentes

<div align="center">

| <img src="https://avatars.githubusercontent.com/u/169938669?v=4" width="100"/> | <img src="https://avatars.githubusercontent.com/u/138076587?v=4" width="100"/> | <img src="https://avatars.githubusercontent.com/u/94936491?v=4" width="100"/> | <img src="https://avatars.githubusercontent.com/u/117862951?v=4" width="100"/> |
|:---:|:---:|:---:|:---:|
| **Diego Sperandío** | **Iker Navas** | **Melissa Nessi** | **Ricardo Mejías** |

</div>

---




<br>

[![Flutter](https://img.shields.io/badge/Powered%20by-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)

</div>
