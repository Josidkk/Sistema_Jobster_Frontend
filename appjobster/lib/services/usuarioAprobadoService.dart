import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuarioViewModel.dart';
import 'globalService.dart';

class UsuarioAprobadoService {
  static const String _baseUrl = 'http://$apiServer/api/Usuarios';
  static const String _apikey =
      'heBJ6u4RtETi9xjC5dICVbmh023nX0sIFrQbMHd9FKiyPBP4QyQe0oW1cYoyFFbwvbeoTP7X4hMxyv6RsMKUMEdVkT3lCHhC80mQirqPUUOW95FFnPedtVw4u3Wj53cf';

  Future<List<Usuario>> getUsuariosAprobados() async {
    final url = Uri.parse('$_baseUrl/ListarAprobados');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Api-Key': _apikey,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Usuario.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load usuarios aprobados');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Método para cambiar estado de aprobación de un usuario
  Future<bool> aprobarUsuario(int usuarioId, bool aprobar) async {
    // Endpoint para aprobar/desaprobar un usuario (formato REST)
    final url = Uri.parse('$_baseUrl/AprobarUsuario/$usuarioId');

    try {
      // Imprimir URL para debugging
      print('Llamando a: $url con aprobar=$aprobar');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Api-Key': _apikey,
        },
        // Agregamos el cuerpo para enviar el estado de aprobación
        body: json.encode({'aprobar': aprobar}),
      );

      if (response.statusCode == 200) {
        // Verificar la respuesta JSON
        final responseData = json.decode(response.body);
        if (responseData['codeStatus'] == 1) {
          return true; // Éxito según la respuesta de la API
        }
      }
      
      return false; // Cualquier otro caso se considera error
    } catch (e) {
      throw Exception('Error al ${aprobar ? 'aprobar' : 'desaprobar'} usuario: $e');
    }
  }
}
