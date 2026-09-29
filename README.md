# applicatec

Aplicación Flutter desarrollada por Nick0B3liko & Joji.

## Descripción general

ApplicaTecMap es una aplicación móvil construida con Flutter que integra un mapa interactivo del campus y un módulo de noticias consumidas desde una API externa. El proyecto está organizado con una arquitectura en capas siguiendo el patrón MVVM, lo que permite separar la interfaz, la lógica de presentación y el acceso a datos.

## Arquitectura en capas

### Capa de presentación

La capa de presentación está compuesta por las vistas y el punto de entrada de la app.

- `main.dart`: inicializa la aplicación, configura `MultiProvider` y registra `NewsViewModel`.
- `views/Map.dart`: muestra el mapa principal, permite seleccionar ubicaciones y trabaja con geolocalización.
- `views/News.dart`: presenta el listado de noticias, el buscador y el manejo visual del estado.
- `views/NewsDetail.dart`: muestra el detalle de una noticia seleccionada.

Esta capa solo se encarga de mostrar información y reaccionar a eventos de usuario. No debería contener lógica de negocio pesada ni llamadas directas a la API.

### Capa ViewModel

La lógica de presentación vive en los ViewModels.

- `viewmodels/NewsViewModel.dart`: administra el estado de las noticias, controla la carga inicial, maneja errores y aplica el debounce del buscador.

Este ViewModel actúa como intermediario entre la vista y la capa de datos. Recibe eventos de la UI, ejecuta la lógica necesaria y notifica cambios para refrescar la interfaz.

### Capa de servicios

Aquí se concentra el acceso a datos externos.

- `services/NewsServices.dart`: consume la API REST de noticias, procesa la respuesta y devuelve la información lista para usar.

La idea es que las vistas no conozcan detalles de conexión, parseo o formato de respuesta.

### Capa de modelos

Los modelos representan la estructura de los datos que usa la aplicación.

- `models/NewsModel.dart`: define la entidad de una noticia con título, imagen y contenido.

### Helpers y utilidades

Además de las capas principales, el proyecto incluye utilidades de apoyo.

- `helpers/NewsHelper.dart`: configura `HttpOverrides` para el manejo de red.
- `helpers/mapHelper.dart`: contiene apoyos relacionados con el mapa.
- `helpers/SalonSidebarDrawer.dart`: construye el panel lateral con accesos a salones o ubicaciones.
- `helpers/salonesubicaciones.dart`: centraliza las coordenadas usadas por el mapa.

## Flujo MVVM

1. La vista solicita datos o eventos del usuario.
2. El ViewModel procesa la solicitud y actualiza el estado.
3. El servicio obtiene los datos desde la API o la fuente correspondiente.
4. El modelo transporta la información de forma estructurada.
5. La vista se reconstruye automáticamente cuando el ViewModel notifica cambios.

## Clases principales

- `MyApp`: configura el tema global de Flutter y define la pantalla inicial.
- `MainScreen`: contiene la navegación inferior entre el mapa y las noticias.
- `NewsViewModel`: controla la carga, búsqueda y estado de las noticias.
- `NewsService`: realiza la consulta a la API externa.
- `NewsModel`: representa cada noticia dentro de la app.
- `Map` y `News`: pantallas principales visibles para el usuario.

## Comandos útiles

Estos comandos ayudan a preparar, validar y mantener el proyecto durante el desarrollo:

```bash
flutter pub get
flutter run
flutter clean
flutter pub upgrade
flutter analyze
flutter test
dart format .
```

### ¿Para qué sirve cada uno?

- `flutter pub get`: descarga las dependencias definidas en `pubspec.yaml`.
- `flutter run`: ejecuta la aplicación en el dispositivo o emulador activo.
- `flutter clean`: limpia archivos generados y resuelve problemas de compilación persistentes.
- `flutter pub upgrade`: actualiza dependencias permitidas por el rango de versiones.
- `flutter analyze`: revisa calidad estática y posibles errores de código.
- `flutter test`: ejecuta las pruebas automatizadas del proyecto.
- `dart format .`: aplica formato estándar a los archivos Dart.

## Comandos de Git y GitHub

Estos comandos son útiles para trabajar con el repositorio y publicar cambios:

```bash
git init
git status
git add .
git commit -m "mensaje del cambio"
git branch
git checkout -b nueva-rama
git remote add origin <URL_DEL_REPOSITORIO>
git push -u origin main
git pull origin main
git fetch --all
git log --oneline --graph --decorate
```

### ¿Para qué sirve cada uno?

- `git init`: crea un repositorio Git local si todavía no existe.
- `git status`: muestra qué archivos cambiaron y cuál es su estado.
- `git add .`: prepara todos los cambios para el siguiente commit.
- `git commit -m "mensaje del cambio"`: guarda un punto de control con un mensaje descriptivo.
- `git branch`: lista las ramas disponibles.
- `git checkout -b nueva-rama`: crea y cambia a una nueva rama de trabajo.
- `git remote add origin <URL_DEL_REPOSITORIO>`: vincula el repositorio local con GitHub.
- `git push -u origin main`: sube la rama principal a GitHub y deja el seguimiento configurado.
- `git pull origin main`: descarga y mezcla los cambios remotos de la rama principal.
- `git fetch --all`: actualiza la información de todas las referencias remotas sin mezclar cambios.
- `git log --oneline --graph --decorate`: muestra el historial de commits de forma compacta.

## Estructura resumida

```text
lib/
	main.dart
	helpers/
	models/
	services/
	viewmodels/
	views/
```