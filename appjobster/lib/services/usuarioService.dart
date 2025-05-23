import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuarioViewModel.dart';

class UsuarioService {
  static const String _baseUrl = 'http://jobster.somee.com/api/Usuario/IniciarSesion';
  static const String _apikey = 'heBJ6u4RtETi9xjC5dICVbmh023nX0sIFrQbMHd9FKiyPBP4QyQe0oW1cYoyFFbwvbeoTP7X4hMxyv6RsMKUMEdVkT3lCHhC80mQirqPUUOW95FFnPedtVw4u3Wj53cf';
  
Future<Usuario?>login(String usuario,String contra)async{

final url = Uri.parse(_baseUrl);

final response = await http.post(
url,
    headers: {
    'content-Type': 'application/json',
    'ApiKey': _apikey,
    },

body: jsonEncode({
'usua_Nombre': usuario,
'usua_Contrasena': contra,
}),

);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      
      if(jsonList.isEmpty)
      {
          return null;

      }
      else{
        return Usuario.fromJson(jsonList[0]);
      }
      
    } else {
   throw Exception('error al crear el usuario ${response.statusCode} ');
    }

}
  }