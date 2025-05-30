import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/PersonasViewModel.dart';
import '../services/globalService.dart';

class PersonaService {
  static const String _apikey =
      'heBJ6u4RtETi9xjC5dICVbmh023nX0sIFrQbMHd9FKiyPBP4QyQe0oW1cYoyFFbwvbeoTP7X4hMxyv6RsMKUMEdVkT3lCHhC80mQirqPUUOW95FFnPedtVw4u3Wj53cf';

  static const String _baseUrlEditarPersona =
      'http://jobster.somee.com/api/Personas/Editar';

  Future<Persona?> buscarPersona(int? id) async {
    if (id == null) {
      return null;
    }
    final url = Uri.parse('http://jobster.somee.com/api/Personas/Buscar/$id');
    final headers = {
      'accept': '*/*',
      'X-Api-Key':
          'heBJ6u4RtETi9xjC5dICVbmh023nX0sIFrQbMHd9FKiyPBP4QyQe0oW1cYoyFFbwvbeoTP7X4hMxyv6RsMKUMEdVkT3lCHhC80mQirqPUUOW95FFnPedtVw4u3Wj53cf',
    };
    
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        return Persona.fromJson(data.first);
      } else {
        return null;
      }
    } else {
      throw Exception('Error al buscar persona: ${response.statusCode}');
    }
  }

  // Editar Persona
  Future<void> editarPersona(Persona persona) async {
    final url = Uri.parse(_baseUrlEditarPersona);
    developer.log('Editando persona ID: ${persona.pers_Id}');

    final requestBody = {
      "pers_Id": persona.pers_Id,
      "pers_DNI": persona.pers_DNI,
      "pers_Nombres": persona.pers_Nombres,
      "pers_Apellidos": persona.pers_Apellidos,
      "pers_Telefono": persona.pers_Telefono,
      "pers_Sexo": persona.pers_Sexo,
      "pers_Direccion": persona.pers_Direccion,
      "pers_Curriculum": persona.pers_Curriculum,
      "esCi_Id": persona.esCi_Id,
      "esCi_Descripcion": persona.esCi_Descripcion,
      "muni_Codigo": persona.muni_Codigo,
      "muni_Descripcion": persona.muni_Descripcion,
      "depa_Codigo": persona.depa_Codigo,
      "depa_Descripcion": persona.depa_Descripcion,
      "pers_Estado": persona.pers_Estado,
      "usua_Creacion": persona.usua_Creacion,
      "usuaC_Nombre": persona.usuaC_Nombre,
      "pers_FechaCreacion": persona.pers_FechaCreacion
          .toUtc()
          .toIso8601String(),
      "usua_Modificacion": persona.usua_Modificacion,
      "usuaM_Nombre": persona.usuaM_Nombre,
      "pers_FechaModificacion": persona.pers_FechaModificacion?.toUtc().toIso8601String(),
    };

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
        body: jsonEncode(requestBody),
      );

      developer.log('Respuesta del servidor: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Error al editar persona: ${response.body}');
      }

      final responseData = jsonDecode(response.body);
    } catch (e) {
      developer.log('Error al editar persona: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}
