/// Centraliza variables de entorno del cliente.
/// Cambia `baseUrl` con la IP/host y puerto donde corre tu backend FastAPI.
/// Ejemplo en tu VM Ubuntu: http://<IP_DE_TU_VM>:3001
class Env {
  static const String baseUrl = "http://infinity:3001";
}