import 'dart:convert';
import 'package:http/http.dart' as http;

class Session {
  static String? usua_Id; // Mantiene el nombre de usuario
  static int? usuario_id; // Cambiado a int? para almacenar el ID numérico
  static List<String> pantallasDisponibles = [];

  static bool get isLoggedIn => usua_Id != null;
 static bool EsAdmin = false; // Variable para verificar si es administrador

  static String? plaza_Id;

  static void login(String id) {
    usua_Id = id;
  }

  static void EsAdminT(bool id) {
    EsAdmin = true;
  }

  static void id(int? id) {
    usuario_id = id; // Ahora correctamente asigna un int a un int?
  }

  static void logout() {
    usua_Id = null;
    pantallasDisponibles = []; // Limpiar pantallas al cerrar sesión
  }

  static Future<void> obtenerPantallasDisponibles(int? userId) async {
    if (userId == null) {
      print('Error: ID de usuario nulo');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://jobster.somee.com/api/Roles/ListarPantallas/$userId'),
        headers: {
          'accept': '*/*',
          'X-Api-Key':
              'heBJ6u4RtETi9xjC5dICVbmh023nX0sIFrQbMHd9FKiyPBP4QyQe0oW1cYoyFFbwvbeoTP7X4hMxyv6RsMKUMEdVkT3lCHhC80mQirqPUUOW95FFnPedtVw4u3Wj53cf',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        pantallasDisponibles = data
            .where((pantalla) => pantalla['pant_Nombre'] != null)
            .map<String>((pantalla) => pantalla['pant_Nombre'].toString())
            .toSet() // Eliminar duplicados
            .toList();
      } else {
        // Manejar error en la solicitud
        pantallasDisponibles = [];
        print('Error al obtener pantallas: ${response.statusCode}');
      }
    } catch (e) {
      // Manejar excepción
      pantallasDisponibles = [];
      print('Excepción al obtener pantallas: $e');
    }
  }

  // Método para verificar si el usuario tiene acceso a una pantalla específica
  static bool tieneAccesoAPantalla(String nombrePantalla) {
    // Si la lista está vacía, devolver false o manejar según corresponda
    if (pantallasDisponibles.isEmpty) {
      print('La lista de pantallas disponibles está vacía');
      return false;
    }
    return pantallasDisponibles.contains(nombrePantalla);
  }
}
