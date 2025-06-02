class Usuario {
  final int? usua_Id;
  final String usua_Nombre;
  final String usua_Contrasena;
  final String? usua_Correo;
  final bool usua_EsAdmin;
  final bool usua_Publicador;
  final String? usua_Imagen;
  final int? pers_Id;
  final String? pers_Nombres;
  final String? pers_Apellidos;
  final int? role_Id;
  final String? role_Descripcion;
  final int? usua_Creacion;
  final DateTime? usua_FechaCreacion;
  final int? usua_Modificacion;
  final DateTime? usua_FechaModificacion;
  final bool usua_Estado;
  final bool? usua_Aprobado;

  Usuario({
    this.usua_Id,
    required this.usua_Nombre,
    required this.usua_Contrasena,
    this.usua_Correo,
    required this.usua_EsAdmin,
    required this.usua_Publicador,
    this.usua_Imagen,
    this.pers_Id,
    this.pers_Nombres,
    this.pers_Apellidos,
    this.role_Id,
    this.role_Descripcion,
    this.usua_Creacion,
    this.usua_FechaCreacion,
    this.usua_Modificacion,
    this.usua_FechaModificacion,
    required this.usua_Estado,
    this.usua_Aprobado,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      usua_Id: json['usua_Id'],
      usua_Nombre: json['usua_Nombre'] ?? '',
      usua_Contrasena: json['usua_Contrasena'] ?? '',
      usua_Correo: json['usua_Correo'],
      usua_EsAdmin: json['usua_EsAdmin'] ?? false,
      usua_Publicador: json['usua_Publicador'] ?? false,
      usua_Imagen: json['usua_Imagen'],
      pers_Id: json['pers_Id'],
      pers_Nombres: json['pers_Nombres'],
      pers_Apellidos: json['pers_Apellidos'],
      role_Id: json['role_Id'],
      role_Descripcion: json['role_Descripcion'],
      usua_Creacion: json['usua_Creacion'],
      usua_FechaCreacion: json['usua_FechaCreacion'] != null
          ? DateTime.parse(json['usua_FechaCreacion'])
          : null,
      usua_Modificacion: json['usua_Modificacion'],
      usua_FechaModificacion: json['usua_FechaModificacion'] != null
          ? DateTime.parse(json['usua_FechaModificacion'])
          : null,
      usua_Estado: json['usua_Estado'] ?? false,
      usua_Aprobado: json['usua_Aprobado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usua_Id': usua_Id,
      'usua_Nombre': usua_Nombre,
      'usua_Contrasena': usua_Contrasena,
      'usua_Correo': usua_Correo,
      'usua_EsAdmin': usua_EsAdmin,
      'usua_Publicador': usua_Publicador,
      'usua_Imagen': usua_Imagen,
      'pers_Id': pers_Id,
      'pers_Nombres': pers_Nombres,
      'pers_Apellidos': pers_Apellidos,
      'role_Id': role_Id,
      'role_Descripcion': role_Descripcion,
      'usua_Creacion': usua_Creacion,
      'usua_FechaCreacion': usua_FechaCreacion?.toIso8601String(),
      'usua_Modificacion': usua_Modificacion,
      'usua_FechaModificacion': usua_FechaModificacion?.toIso8601String(),
      'usua_Estado': usua_Estado,
      'usua_Aprobado': usua_Aprobado,
    };
  }
}
