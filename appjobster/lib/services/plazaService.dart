import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:ffi';
import 'package:cloudinary_url_gen/transformation/common.dart';
import 'package:http/http.dart' as http;
import 'package:jobster/services/Session.dart';
import '../models/usuarioViewModel.dart';
import '../services/globalService.dart';
import '../screen/registroUsuarioScreen.dart';

class PlazaService {
  static const String _baseUrl = 'http://$apiServer/api/Usuarios/IniciarSesion';
  static const String _apikey =
      'heBJ6u4RtETi9xjC5dICVbmh023nX0sIFrQbMHd9FKiyPBP4QyQe0oW1cYoyFFbwvbeoTP7X4hMxyv6RsMKUMEdVkT3lCHhC80mQirqPUUOW95FFnPedtVw4u3Wj53cf';

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

    developer.log('Login Request URL: $url');
    developer.log(
      'Login Request Headers: ${{'Content-Type': 'application/json', 'X-Api-Key': _apikey}}',
    );
    developer.log('Login Request Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
        body: jsonEncode(requestBody),
      );

      // Log the response for debugging
      developer.log('Login Response Status: ${response.statusCode}');
      developer.log('Login Response Body: ${response.body}');

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


  Future crearPlaza(String descripcion, String informacion, String imagen, String direccion,
                    int? cate, int? carg, int? tico, List<Map<String, String>> requisitos) async {

    final url = Uri.parse(_baseUrl);

    // Using the exact format from the cURL example
    final requestBody = {
        "plaz_Id": 0,
        "plaz_Descripcion": descripcion,
        "plaz_Informacion": informacion,
        "plaz_Direccion": direccion,
        "plaz_Telefono": "string", //duro
        "plaz_Correo": "string", //duro
        "plaz_Imagen": imagen,
        "muni_Codigo": "0501", //duro
        "cate_Id": cate,
        "usua_Id": Session.usuario_id, //duro
        "carg_Id": carg,
        "tiCo_Id": tico,
        "plaz_Estado": true,
        "usua_Creacion": 1,
        "plaz_FechaCreacion": "2025-05-26T18:57:39.545Z",
        "usua_Modificacion": 0,
        "plaz_FechaModificacion": "2025-05-26T18:57:39.545Z"
    };

    developer.log('Login Request URL: $url');
    developer.log(
      'Login Request Headers: ${{'Content-Type': 'application/json', 'X-Api-Key': _apikey}}',
    );
    developer.log('Login Request Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse('http://$apiServer/api/Plazas/InsertarPlaza'),
        headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
        body: jsonEncode(requestBody),
      );

      // Log the response for debugging
      developer.log('Login Response Status: ${response.statusCode}');
      developer.log('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // final List<dynamic> jsonList = jsonDecode(response.body);

        // if (jsonList.isEmpty) {
        //   return null;
        // } else {
        //   return Usuario.fromJson(jsonList[0]);
        // }

        requisitos.forEach( (requisito) async {

          final requisitoBody = {

            "requ_Id": 0,
            "requ_Descripcion": requisito['requ_Descripcion'],
            "requ_Informacion": requisito['requ_Informacion'],
            "requ_Estado": true,
            "usua_Creacion": Session.usuario_id,
            "plaz_Id": 0,
            "requ_FechaCreacion": DateTime.now().toIso8601String(),
            "usua_Modificacion": 0,
            "requ_FechaModificacion": "2025-06-02T19:43:48.358Z"
          };

          final responseRequ = await http.post(
            Uri.parse('http://$apiServer/api/Requisitos/InsertarRequisito'),
            headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
            body: jsonEncode(requisitoBody),
          );

          
        }
        );
        
        return 'creada';
      } else {
        throw Exception(
          'Error en la solicitud: Código ${response.statusCode}, Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      developer.log('Login Error: $e');
      throw Exception('Error en la solicitud a crear Plaza: $e');
    }
  }

  Future<List<dynamic>> getMunicipios() async {
    final url = Uri.parse('http://$apiServer/api/Generales/ListarMunicipios');
    developer.log('Get Municipios Request URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
      );

      developer.log('Get Municipios Response Status: ${response.statusCode}');
      developer.log('Get Municipios Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> objeto = jsonDecode(response.body);
        final List<dynamic> municipiosList = objeto['data'] as List<dynamic>;

        print('object');
        print(municipiosList);

        // final List<dynamic> municipiosList = jsonDecode(response.body);
        return municipiosList;
      } else {
        throw Exception(
          'Error en la solicitud: Código ${response.statusCode}, Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      developer.log('Get Municipios Error: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }
  // listarmunicipios

  Future<List<dynamic>> getEstadosCiviles() async {
    final url = Uri.parse(
      'http://$apiServer/api/Generales/ListarEstadosCiviles',
    );
    developer.log('Get Municipios Request URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> objeto = jsonDecode(response.body);
        final List<dynamic> estadosCivilesList =
            objeto['data'] as List<dynamic>;

        print('object');
        print(estadosCivilesList);

        // final List<dynamic> municipiosList = jsonDecode(response.body);
        return estadosCivilesList;
      } else {
        throw Exception(
          'Error en la solicitud: Código ${response.statusCode}, Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      developer.log('Get Municipios Error: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }
  // listarmunicipios

  Future<List<dynamic>> getCargos() async {
    final url = Uri.parse('http://$apiServer/api/Cargos/ListarCargos');
    developer.log('Get Cargos Request URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
      );

      developer.log('Get Cargos Response Status: ${response.statusCode}');
      developer.log('Get Cargos Response Body: ${response.body}');
      print('respuesta');
      print(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> cargosList = jsonDecode(response.body);
        return cargosList;
      } else {
        throw Exception(
          'Error en la solicitud: Código ${response.statusCode}, Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      developer.log('Get Cargos Error: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }
  // Listar Cargos

  Future<List<dynamic>> getCategorias() async {
    final url = Uri.parse('http://$apiServer/api/Categorias/ListarCategorias');
    developer.log('Get Categorias Request URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
      );

      developer.log('Get Categorias Response Status: ${response.statusCode}');
      developer.log('Get Categorias Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> categoriasList = jsonDecode(response.body);
        return categoriasList;
      } else {
        throw Exception(
          'Error en la solicitud: Código ${response.statusCode}, Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      developer.log('Get Categorias Error: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<List<dynamic>> getTiposContrato() async {
    final url = Uri.parse(
      'http://$apiServer/api/TiposContrato/ListarTiposContrato',
    );
    developer.log('Get Tipos Contrato Request URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
      );

      developer.log(
        'Get Tipos Contrato Response Status: ${response.statusCode}',
      );
      developer.log('Get Tipos Contrato Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> tiposContratoList = jsonDecode(response.body);
        return tiposContratoList;
      } else {
        throw Exception(
          'Error en la solicitud: Código ${response.statusCode}, Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      developer.log('Get Tipos Contrato Error: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  
  Future<List<dynamic>> getSolicitudes() async{

    final url = Uri.parse('http://$apiServer/api/Solicitudes/ListarSolicitudes');
    developer.log('Get Solicitudes Request URL: $url');

    try {

        final response = await http.get(
          url,
          headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
        );

        developer.log('Get Solicitudes Response Status: ${response.statusCode}');
        developer.log('Get Solicitudes Response Body: ${response.body}');

        if (response.statusCode == 200) {

          final List<dynamic> solicitudeslist = jsonDecode(response.body);
          return solicitudeslist;

        } else {
          throw Exception(
            'Error en la solicitud: Código ${response.statusCode}, Respuesta: ${response.body}',
          );
        }
      } catch (e) {
        developer.log('Get Solicitudes Error: $e');
        throw Exception('Error en la solicitud: $e');
      }

    
  }

  
  Future<List<dynamic>> getGuardados() async{

    final url = Uri.parse('http://$apiServer/api/Guardados/ListarGuardados');
    developer.log('Get Guardados Request URL: $url');

    try {

        final response = await http.get(
          url,
          headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
        );

        developer.log('Get Guardados Response Status: ${response.statusCode}');
        developer.log('Get Guardados Response Body: ${response.body}');

        if (response.statusCode == 200) {

          final List<dynamic> guardadoslist = jsonDecode(response.body);
          return guardadoslist;

        } else {
          throw Exception(
            'Error en la solicitud: Código ${response.statusCode}, Respuesta: ${response.body}',
          );
        }
      } catch (e) {
        developer.log('Get guardados Error: $e');
        throw Exception('Error en la solicitud: $e');
      }

    
  }
  
  Future<List<dynamic>> getRequisitos() async{

    final url = Uri.parse('http://$apiServer/api/Requisitos/ListarRequisitos');
    developer.log('Get Guardados Request URL: $url');

    try {

        final response = await http.get(
          url,
          headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
        );

        developer.log('Get Requisitos Response Status: ${response.statusCode}');
        developer.log('Get Requisitos Response Body: ${response.body}');

        if (response.statusCode == 200) {

          final List<dynamic> requisitoslist = jsonDecode(response.body);
          return requisitoslist;

        } else {
          throw Exception(
            'Error en la solicitud: Código ${response.statusCode}, Respuesta: ${response.body}',
          );
        }
      } catch (e) {
        developer.log('Get Requisitos Error: $e');
        throw Exception('Error en la solicitud: $e');
      }

    
  }
  
 Future crearPersonaUsuario(
    String nombre,
    String contrasena,
    String correo,
    String imagen,
    String dni,
    String nombres,
    String apellidos,
    String telefono,
    String? sexo,
    String direccion,
    int? estadocivil,
    String? municipio,
    int? roleId,
  ) async {

    final url = Uri.parse(_baseUrl);

    // Using the exact format from the cURL example
    final requestBody = {
      "pers_Id": 0,
      "pers_DNI": dni,
      "pers_Nombres": nombres,
      "pers_Apellidos": apellidos,
      "pers_Telefono": telefono,
      "pers_Sexo": sexo,
      "pers_Direccion": direccion,
      "pers_Curriculum": "sincurriculum",
      "esCi_Id": estadocivil,
      "esCi_Descripcion": "string",
      "muni_Codigo": municipio,
      "muni_Descripcion": "string",
      "depa_Codigo": "string",
      "depa_Descripcion": "string",
      "pers_Estado": true,
      "usua_Creacion": 1,
      "usuaC_Nombre": "string",
      "pers_FechaCreacion": "2025-05-27T13:51:24.104Z",
      "usua_Modificacion": 0,
      "usuaM_Nombre": "string",
      "pers_FechaModificacion": "2025-05-27T13:51:24.104Z",
    };

    developer.log('Login Request URL: $url');
    developer.log(
      'Login Request Headers: ${{'Content-Type': 'application/json', 'X-Api-Key': _apikey}}',
    );
    developer.log('Login Request Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse('http://$apiServer/api/Personas/Insertar'),
        headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
        body: jsonEncode(requestBody),
      );

      // Log the response for debugging
      developer.log('Login Response Status: ${response.statusCode}');
      developer.log('Login Response Body: ${response.body}');

      final requestBodyUsua = {
        "usua_Id": 0,
        "usua_Nombre": nombre,
        "usua_Contrasena": contrasena,
        "usua_Correo": correo,
        "usua_EsAdmin": false,
        "usua_Publicador":  (roleId == 4) ? true : false, // Publicador solo si es rol de publicador
        "usua_Imagen": imagen,
        "pers_Id": 1,
        "role_Id": roleId,
        "pers_Nombres": "string",
        "pers_Apellidos": "string",
        "role_Descripcion": "string",
        "usua_Creacion": 1,
        "usua_FechaCreacion": "2025-05-27T12:12:09.180Z",
        "usua_Modificacion": 0,
        "usua_FechaModificacion": "2025-05-27T12:12:09.180Z",
        "usua_Estado": true,
      };

      if (response.statusCode == 200) {
        try {
          final responseUsuario = await http.post(
            Uri.parse('http://$apiServer/api/Usuarios/Insertar'),
            headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
            body: jsonEncode(requestBodyUsua),
          );

          // Log the response for debugging
          developer.log('Login Response Status: ${responseUsuario.statusCode}');
          developer.log('Login Response Body: ${responseUsuario.body}');

          if (responseUsuario.statusCode == 200) {
            return 'creada';
          } else {
            throw Exception(
              'Error en la solicitud: Código ${responseUsuario.statusCode}, Respuesta: ${responseUsuario.body}',
            );
          }
        } catch (e) {
          developer.log('Login Error: $e');
          throw Exception('Error en la solicitud a crear Usuario: $e');
        }

        // return 'creada';
      } else {
        throw Exception(
          'Error en la solicitud: Código ${response.statusCode}, Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      developer.log('Login Error: $e');
      throw Exception('Error en la solicitud a crear Persona: $e');
    }
  }

  Future<List<dynamic>> listarPlazas() async {
    final url = Uri.parse('http://$apiServer/api/Plazas/ListarPlazas');
    developer.log('Get plazas Request URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
      );

      developer.log(
        'Get Tipos Contrato Response Status: ${response.statusCode}',
      );
      developer.log('Get Tipos Contrato Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> plazaslist = jsonDecode(response.body);
        return plazaslist;
      } else {
        throw Exception(
          'Error en la solicitud: Código ${response.statusCode}, Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      developer.log('listar plazas Error: $e');
      throw Exception('Error al listar plazas: $e');
    }
  }

  Future<List<dynamic>> buscarPlaza(String plazaid) async {
    final requestBody = {
      "plaz_Id": plazaid,
      "plaz_Descripcion": "string",
      "plaz_Informacion": "string",
      "plaz_Direccion": "string",
      "plaz_Telefono": "string",
      "plaz_Correo": "string",
      "plaz_Imagen": "string",
      "muni_Codigo": "string",
      "cate_Id": 0,
      "usua_Id": 0,
      "carg_Id": 0,
      "tiCo_Id": 0,
      "plaz_Estado": true,
      "usua_Creacion": 0,
      "plaz_FechaCreacion": "2025-05-30T18:40:05.381Z",
      "usua_Modificacion": 0,
      "plaz_FechaModificacion": "2025-05-30T18:40:05.381Z",
    };

    final url = Uri.parse('http://$apiServer/api/Plazas/BuscarPlaza');
    developer.log('Get plazas Request URL: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
        body: jsonEncode(requestBody),
      );

      developer.log('buscar plaza Response Status: ${response.statusCode}');
      developer.log('buscar plaza Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> plazaslist = jsonDecode(response.body);
        return plazaslist;
      } else {
        throw Exception(
          'Error en la solicitud: Código ${response.statusCode}, Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      developer.log('buscar plaza Error: $e');
      throw Exception('Error al buscar plaza: $e');
    }
  }


  Future crearSolicitud(String? plazaid, String? usuaid) async {

    final url = Uri.parse(_baseUrl);

    // Using the exact format from the cURL example
    final requestBody = {
       
      "soli_Id": 0,
      "soli_Comentario": "string",
      "soli_Revision": "string",
      "plaz_Id": plazaid,
      "usua_Id": usuaid,
      "soli_Estado": true,
      "usua_Creacion": usuaid,
      "soli_FechaCreacion": DateTime.now().toIso8601String(),
      "usua_Modificacion": 0,
      "soli_FechaModificacion": DateTime.now().toIso8601String()

    };

    developer.log('solicitud Request URL: $url');
    developer.log(
      'solicitud Request Headers: ${{'Content-Type': 'application/json', 'X-Api-Key': _apikey}}',
    );
    developer.log('Login Request Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse('http://$apiServer/api/Solicitudes/InsertarSolicitud'),
        headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
        body: jsonEncode(requestBody),
      );

      // Log the response for debugging
      developer.log('solicitud Response Status: ${response.statusCode}');
      developer.log('solicitud Response Body: ${response.body}');

      if (response.statusCode == 200) {
        
        return 'creada';

      } else {
        throw Exception(
          'Error en la solicitud: Código ${response.statusCode}, Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      developer.log('Solicitud Error: $e');
      throw Exception('Error al Solicitar Plaza: $e');
    }
  }

   Future eliminarSolicitud(String? soliId) async {

    final url = Uri.parse(_baseUrl);

    // Using the exact format from the cURL example
    final requestBody = {
       
      "soli_Id": soliId,
      "soli_Comentario": "string",
      "soli_Revision": "string",
      "plaz_Id": 0,
      "usua_Id": 0,
      "soli_Estado": true,
      "usua_Creacion": 0,
      "soli_FechaCreacion": DateTime.now().toIso8601String(),
      "usua_Modificacion": 0,
      "soli_FechaModificacion": DateTime.now().toIso8601String()

    };

    developer.log('solicitud Request URL: $url');
    developer.log(
      'solicitud Request Headers: ${{'Content-Type': 'application/json', 'X-Api-Key': _apikey}}',
    );
    developer.log('Login Request Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse('http://$apiServer/api/Solicitudes/EliminarSolicitud'),
        headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
        body: jsonEncode(requestBody),
      );

      // Log the response for debugging
      developer.log('solicitud Response Status: ${response.statusCode}');
      developer.log('solicitud Response Body: ${response.body}');

      if (response.statusCode == 200) {
        
        return 'eliminada';

      } else {
        throw Exception(
          'Error en la solicitud: Código ${response.statusCode}, Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      developer.log('Solicitud Error: $e');
      throw Exception('Error al Solicitar Plaza: $e');
    }
  }

  Future crearGuardado(String? plazaid, String? usuaid) async {

    final url = Uri.parse(_baseUrl);

    // Using the exact format from the cURL example
    final requestBody = {
            
      "guar_Id": 0,
      "plaz_Id": plazaid,
      "usua_Id": usuaid,
      "guar_Estado": true,
      "usua_Creacion": 0,
      "guar_FechaCreacion": DateTime.now().toIso8601String(),
      "usua_Modificacion": 0,
      "guar_FechaModificacion": "2025-06-02T09:49:20.622Z"

    };

    developer.log('Guardado Request URL: $url');
    developer.log(
      'Guardado Request Headers: ${{'Content-Type': 'application/json', 'X-Api-Key': _apikey}}',
    );
    developer.log('Guardado Request Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse('http://$apiServer/api/Guardados/InsertarGuardado'),
        headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
        body: jsonEncode(requestBody),
      );

      // Log the response for debugging
      developer.log('Guardado Response Status: ${response.statusCode}');
      developer.log('Guardado Response Body: ${response.body}');

      if (response.statusCode == 200) {
        
        return 'creada';

      } else {
        throw Exception(
          'Error en el guardado: Código ${response.statusCode}, Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      developer.log('Guardado Error: $e');
      throw Exception('Error al Guardar Plaza: $e');
    }
  }

  Future eliminarGuardado(String? guarid) async {

    final url = Uri.parse(_baseUrl);

    // Using the exact format from the cURL example
    final requestBody = {
            
      "guar_Id": guarid,
      "plaz_Id": 0,
      "usua_Id": 0,
      "guar_Estado": true,
      "usua_Creacion": 0,
      "guar_FechaCreacion": DateTime.now().toIso8601String(),
      "usua_Modificacion": 0,
      "guar_FechaModificacion": "2025-06-02T09:49:20.622Z"

    };
    
    developer.log('Guardado Request URL: $url');
    developer.log(
      'Guardado Request Headers: ${{'Content-Type': 'application/json', 'X-Api-Key': _apikey}}',
    );
    developer.log('Guardado Request Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse('http://$apiServer/api/Guardados/EliminarGuardado'),
        headers: {'Content-Type': 'application/json', 'X-Api-Key': _apikey},
        body: jsonEncode(requestBody),
      );

      // Log the response for debugging
      developer.log('Guardado Response Status: ${response.statusCode}');
      developer.log('Guardado Response Body: ${response.body}');

      if (response.statusCode == 200) {
        
        return 'eliminada';

      } else {
        throw Exception(
          'Error en eliminar el guardado: Código ${response.statusCode}, Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      developer.log('Guardado eliminar Error: $e');
      throw Exception('Error al eliminar Guardado: $e');
    }
  }











}
