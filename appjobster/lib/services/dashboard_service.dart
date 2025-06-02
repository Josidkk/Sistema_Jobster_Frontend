import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/top_plaza.dart';
import '../models/usuario_stats.dart';
import '../models/usuario.dart';

class DashboardService {
  static const String baseUrl = 'http://jobster.somee.com/api';
  static const String apiKey = 'heBJ6u4RtETi9xjC5dICVbmh023nX0sIFrQbMHd9FKiyPBP4QyQe0oW1cYoyFFbwvbeoTP7X4hMxyv6RsMKUMEdVkT3lCHhC80mQirqPUUOW95FFnPedtVw4u3Wj53cf';

  static Future<List<TopPlaza>> getTop5Plazas() async {
    final url = Uri.parse('$baseUrl/Plazas/ListarTop5Plazas');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'X-Api-Key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => TopPlaza.fromJson(item)).toList();
      } else {
        throw Exception('Error al cargar datos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<UsuarioStats> getUsuariosAprobados() async {
    final apiUrl = Uri.parse('$baseUrl/Usuarios/CantidadUsuariosAprobados');
    final usuariosUrl = Uri.parse('$baseUrl/Usuarios/Listar');
    
    try {
      // Obtener cantidad de usuarios aprobados
      final responseAprobados = await http.get(
        apiUrl,
        headers: {
          'accept': '*/*',
          'X-Api-Key': apiKey,
        },
      );

      // Obtener todos los usuarios
      final responseUsuarios = await http.get(
        usuariosUrl,
        headers: {
          'accept': '*/*',
          'X-Api-Key': apiKey,
        },
      );

      if (responseAprobados.statusCode == 200 && responseUsuarios.statusCode == 200) {
        final List<dynamic> dataAprobados = json.decode(responseAprobados.body);
        
        final Map<String, dynamic> dataUsuarios = json.decode(responseUsuarios.body);
        final int totalUsuarios = dataUsuarios['data'] != null ? 
          (dataUsuarios['data'] as List).length : 0;
        
        UsuarioStats stats;
        
        if (dataAprobados.isNotEmpty) {
          stats = UsuarioStats.fromJson(dataAprobados.first);
          stats = UsuarioStats(
            totalAprobados: stats.totalAprobados,
            totalUsuarios: totalUsuarios,
          );
        } else {
          stats = UsuarioStats(totalAprobados: 0, totalUsuarios: totalUsuarios);
        }
        
        return stats;
      } else {
        throw Exception('Error al cargar datos: ${responseAprobados.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<List<Usuario>> getUsuarios() async {
    final url = Uri.parse('$baseUrl/Usuarios/Listar');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'X-Api-Key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> usuariosData = data['data'];
          return usuariosData.map((item) => Usuario.fromJson(item)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Error al cargar datos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
