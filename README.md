git add README.md<div align="center">

# KAHOOT

### Plataforma interactiva de aprendizaje basada en quizzes

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)

---

[Descripción](#-descripción) • [Estado](#-estado-del-proyecto) • [Demo](#-demostración) • [Instalación](#-acceso-al-proyecto) • [Tecnologías](#-tecnologías-utilizadas) • [Equipo](#-personas-contribuyentes)

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
| 🎮 Modo Multijugador | 🔄 En desarrollo |
| 👤 Perfil de Usuario | ✅ Completado |

</div>

> 🟢 **Versión actual:** 1.0.0  
> 📅 **Última actualización:** Enero 2026

---

## 🎬 Demostración

### 📱 Pantallas principales

<div align="center">

| Inicio | Crear Quiz | Jugar |
|:------:|:----------:|:-----:|
| ![Home](docs/screenshots/home.png) | ![Create](docs/screenshots/create.png) | ![Play](docs/screenshots/play.png) |

</div>


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

El proyecto sigue una **Arquitectura Hexagonal** (Ports & Adapters) con la siguiente estructura:

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

## 👥 Contribuyentes

<div align="center">

| <img src="https://github.com/identicons/diego.png" width="100"/> | <img src="https://github.com/identicons/iker.png" width="100"/> | <img src="https://github.com/identicons/melissa.png" width="100"/> | <img src="https://github.com/identicons/ricardo.png" width="100"/> |
|:---:|:---:|:---:|:---:|
| **Diego Sperandío** | **Iker Navas** | **Melissa Nessi** | **Ricardo Mejías** |

</div>

---

<div align="center">

### ⭐ ¡Si te gusta el proyecto, no olvides darle una estrella!

<br>



<br>

[![Flutter](https://img.shields.io/badge/Powered%20by-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)

</div>
