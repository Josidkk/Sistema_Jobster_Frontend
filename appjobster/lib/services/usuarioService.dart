import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/usuarioViewModel.dart';

class UsuarioService {
  static const String _baseUrl =
      'http://jobster.somee.com/api/Usuarios/IniciarSesion';
  static const String _apikey =
      'heBJ6u4RtETi9xjC5dICVbmh023nX0sIFrQbMHd9FKiyPBP4QyQe0oW1cYoyFFbwvbeoTP7X4hMxyv6RsMKUMEdVkT3lCHhC80mQirqPUUOW95FFnPedtVw4u3Wj53cf';
  static const String _baseUrlBuscar =
      'http://jobster.somee.com/api/Usuarios/Buscar';
  static const String _baseUrlCorreo =
      'http://jobster.somee.com/api/Correo/Verificacion';
  static const String _baseUrlRestablecerContrasena =
      'http://jobster.somee.com/api/Usuarios/RestablecerContrasena';

  Future<Usuario?> login(String usuario, String contra) async {
    final url = Uri.parse(_baseUrl);

    // Using the exact format from the cURL example
    final requestBody = {
      "usua_Id": 0,
      "usua_Nombre": usuario,
      "usua_Contrasena": contra,
      "usua_Correo": "string",
      "usua_EsAdmin": true,
      "usua_Publicador": true,
      "usua_Imagen": "string",
      "pers_Id": 0,
      "pers_Nombres": "string",
      "pers_Apellidos": "string",
      "role_Id": 0,
      "role_Descripcion": "string",
      "usua_Creacion": 0,
      "usua_FechaCreacion": "2025-05-25T21:57:00.644Z",
      "usua_Modificacion": 0,
      "usua_FechaModificacion": "2025-05-25T21:57:00.644Z",
      "usua_Estado": true,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        if (jsonList.isEmpty) {
          return null;
        } else {
          return Usuario.fromJson(jsonList[0]);
        }
      } else {
        throw Exception(
          'Error en la solicitud: Código ${response.statusCode}, Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      developer.log('Login Error: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  //BUSCAR USUARIO
  Future<Usuario?> buscarUsuario(String usuario) async {
    final url = Uri.parse(_baseUrlBuscar);

    // Using the exact format from the cURL example
    final requestBody = {
      "usua_Id": 0,
      "usua_Nombre": usuario,
      "usua_Contrasena": "string",
      "usua_Correo": "string",
      "usua_EsAdmin": true,
      "usua_Publicador": true,
      "usua_Imagen": "string",
      "pers_Id": 0,
      "pers_Nombres": "string",
      "pers_Apellidos": "string",
      "role_Id": 0,
      "role_Descripcion": "string",
      "usua_Creacion": 0,
      "usua_FechaCreacion": "2025-05-25T21:57:00.644Z",
      "usua_Modificacion": 0,
      "usua_FechaModificacion": "2025-05-25T21:57:00.644Z",
      "usua_Estado": true,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        if (jsonList.isEmpty) {
          return null;
        } else {
          return Usuario.fromJson(jsonList[0]);
        }
      } else {
        throw Exception(
          'Error en la solicitud: Código ${response.statusCode}, Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      developer.log('Login Error: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  //MANDAR CORREO
  Future<String> enviarCorreo(String? correo) async {
    final url = Uri.parse(_baseUrlCorreo);

    final requestBody = {
      "destinatario": correo,
      "asunto": "Código de verificación",
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // La API devuelve directamente el código como texto
        return response.body;
      } else {
        throw Exception(
          'Error en la solicitud: Código ${response.statusCode}, Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      developer.log('EnviarCorreo Error: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  //Restablecer contraseña
  Future<Usuario?> restablecerContrasena(int id, String contra) async {
    final url = Uri.parse(_baseUrlRestablecerContrasena);

    // Using the exact format from the cURL example
    final requestBody = {
      "usua_Id": id,
      "usua_Nombre": "string",
      "usua_Contrasena": contra,
      "usua_Correo": "string",
      "usua_EsAdmin": true,
      "usua_Publicador": true,
      "usua_Imagen": "string",
      "pers_Id": 0,
      "pers_Nombres": "string",
      "pers_Apellidos": "string",
      "role_Id": 0,
      "role_Descripcion": "string",
      "usua_Creacion": 0,
      "usua_FechaCreacion": "2025-05-25T21:57:00.644Z",
      "usua_Modificacion": 1, //poner la sesion de modificacion
      "usua_FechaModificacion": "2025-05-25T21:57:00.644Z",
      "usua_Estado": true,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        if (jsonList.isEmpty) {
          return null;
        } else {
          return Usuario.fromJson(jsonList[0]);
        }
      } else {
        throw Exception(
          'Error en la solicitud: Código ${response.statusCode}, Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      developer.log('Login Error: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }
}
