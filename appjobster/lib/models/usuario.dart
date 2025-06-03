class Usuario {
  final int id;
  final String nombre;
  final String correo;
  final String imagen;
  final String roleDescripcion;
  final bool esAdmin;
  final bool publicador;
  final bool estado;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.imagen,
    required this.roleDescripcion,
    required this.esAdmin,
    required this.publicador,
    required this.estado,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['usua_Id'] ?? 0,
      nombre: json['usua_Nombre'] ?? '',
      correo: json['usua_Correo'] ?? '',
      imagen: json['usua_Imagen'] ?? '',
      roleDescripcion: json['role_Descripcion'] ?? '',
      esAdmin: json['usua_EsAdmin'] ?? false,
      publicador: json['usua_Publicador'] ?? false,
      estado: json['usua_Estado'] ?? false,
    );
  }
}
