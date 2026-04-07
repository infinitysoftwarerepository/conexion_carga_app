# Conexión Carga App

## Versionado

La app usa el formato estándar de Flutter:

```yaml
version: x.y.z+build
```

Regla operativa:

- `x.y.z` es la versión visible para usuario.
- `build` es el control técnico interno.
- Android toma:
  - `versionName = x.y.z`
  - `versionCode = build`
- iOS toma:
  - `CFBundleShortVersionString = x.y.z`
  - `CFBundleVersion = build`

## Estrategia recomendada

- Android:
  - Podemos mantener `1.0.0` como versión visible durante varias publicaciones.
  - Debemos incrementar siempre el `build` en cada release: `1.0.0+12`, `1.0.0+13`, `1.0.0+14`.
  - El bloqueo de `force update` se controla principalmente por `build`.
- iOS:
  - También debe incrementar `build` en cada publicación.
  - Puede usar la misma versión visible o cambiarla cuando negocio lo decida.
  - La política de backend ya está preparada para bloquear por `build` o por `version`.

## Force Update

La app consulta:

```text
GET /api/app/version-policy
```

Enviando:

- `platform`
- `version`
- `build`

El backend responde con:

- `comparison_mode`
- `min_supported_version`
- `min_supported_build`
- `latest_version`
- `latest_build`
- `force_update`

Regla recomendada para producción:

- Android: usar `APP_MIN_BUILD_ANDROID` como control principal.
- iOS: usar `APP_MIN_BUILD_IOS` si también se quiere un control técnico preciso.
- `APP_MIN_VERSION_*` queda como respaldo informativo o fallback.

## Publicación

Antes de publicar:

1. Incrementar `build` en `pubspec.yaml`.
2. Ejecutar `flutter pub get`.
3. Generar `appbundle` o `ipa`.
4. Subir a la tienda.
5. Ajustar en backend:
   - `APP_MIN_BUILD_ANDROID`
   - `APP_LATEST_BUILD_ANDROID`
   - `APP_LATEST_VERSION_ANDROID`

Ejemplo:

- build publicada en Play: `1.0.0+12`
- siguiente release: `1.0.0+13`
- para bloquear versiones viejas:
  - `APP_MIN_BUILD_ANDROID=13`
  - `APP_LATEST_BUILD_ANDROID=13`
  - `APP_LATEST_VERSION_ANDROID=1.0.0`
