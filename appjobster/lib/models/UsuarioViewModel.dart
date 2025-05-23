class Usuario {
  final String usua_Nombre;
  final String usua_Contrasena;
  final String usua_Correo;
  final bool usua_EsAdmin;
  final bool usua_Publicador;
  final String usua_Imagen;
  final int pers_Id;
  final String pers_Nombres;
  final String pers_Apellidos;
  final int role_Id;
  final String role_Descripcion;
  final int usua_Creacion;
  final DateTime usua_FechaCreacion;
  final int usua_Modificacion;
  final DateTime usua_FechaModificacion;
  final bool usua_Estado;

  Usuario({
    required this.usua_Nombre,
    required this.usua_Contrasena,
    required this.usua_Correo,
    required this.usua_EsAdmin,
    required this.usua_Publicador,
    required this.usua_Imagen,
    required this.pers_Id,
    required this.pers_Nombres,
    required this.pers_Apellidos,
    required this.role_Id,
    required this.role_Descripcion,
    required this.usua_Creacion,
    required this.usua_FechaCreacion,
    required this.usua_Modificacion,
    required this.usua_FechaModificacion,
    required this.usua_Estado,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      usua_Nombre: json['usua_Nombre'],
      usua_Contrasena: json['usua_Contrasena'],
      usua_Correo: json['usua_Correo'],
      usua_EsAdmin: json['usua_EsAdmin'],
      usua_Publicador: json['usua_Publicador'],
      usua_Imagen: json['usua_Imagen'],
      pers_Id: json['pers_Id'],
      pers_Nombres: json['pers_Nombres'],
      pers_Apellidos: json['pers_Apellidos'],
      role_Id: json['role_Id'],
      role_Descripcion: json['role_Descripcion'],
      usua_Creacion: json['usua_Creacion'],
      usua_FechaCreacion: DateTime.parse(json['usua_FechaCreacion']),
      usua_Modificacion: json['usua_Modificacion'],
      usua_FechaModificacion: DateTime.parse(json['usua_FechaModificacion']),
      usua_Estado: json['usua_Estado'],
    );
  }
}