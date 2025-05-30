class Persona {
  final int pers_Id;
  final String? pers_DNI;
  final String? pers_Nombres;
  final String? pers_Apellidos;
  final String? pers_Telefono;
  final String? pers_Sexo;
  final String? pers_Direccion;
  final String? pers_Curriculum;
  final int esCi_Id;
  final String? esCi_Descripcion;
  final String? muni_Codigo;
  final String? muni_Descripcion;
  final String? depa_Codigo;
  final String? depa_Descripcion;
  final bool pers_Estado;
  final int usua_Creacion;
  final String? usuaC_Nombre;
  final DateTime pers_FechaCreacion;
  final int? usua_Modificacion;
  final String? usuaM_Nombre;
  final DateTime? pers_FechaModificacion;

  Persona({
    required this.pers_Id,
    required this.pers_DNI,
    required this.pers_Nombres,
    required this.pers_Apellidos,
    required this.pers_Telefono,
    required this.pers_Sexo,
    required this.pers_Direccion,
    required this.pers_Curriculum,
    required this.esCi_Id,
    required this.esCi_Descripcion,
    required this.muni_Codigo,
    required this.muni_Descripcion,
    required this.depa_Codigo,
    required this.depa_Descripcion,
    required this.pers_Estado,
    required this.usua_Creacion,
    required this.usuaC_Nombre,
    required this.pers_FechaCreacion,
    required this.usua_Modificacion,
    required this.usuaM_Nombre,
    required this.pers_FechaModificacion,
  });

  Map<String, dynamic> toJson() {
    return {
      "pers_Id": pers_Id,
      "pers_DNI": pers_DNI,
      "pers_Nombres": pers_Nombres,
      "pers_Apellidos": pers_Apellidos,
      "pers_Telefono": pers_Telefono,
      "pers_Sexo": pers_Sexo,
      "pers_Direccion": pers_Direccion,
      "pers_Curriculum": pers_Curriculum,
      "esCi_Id": esCi_Id,
      "esCi_Descripcion": esCi_Descripcion,
      "muni_Codigo": muni_Codigo,
      "muni_Descripcion": muni_Descripcion,
      "depa_Codigo": depa_Codigo,
      "depa_Descripcion": depa_Descripcion,
      "pers_Estado": pers_Estado,
      "usua_Creacion": usua_Creacion,
      "usuaC_Nombre": usuaC_Nombre,
      "pers_FechaCreacion": pers_FechaCreacion.toUtc().toIso8601String(),
      "usua_Modificacion": usua_Modificacion,
      "usuaM_Nombre": usuaM_Nombre,
      "pers_FechaModificacion":  pers_FechaModificacion?.toUtc().toIso8601String(),
    };
  }

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      pers_Id: json['pers_Id'],
      pers_DNI: json['pers_DNI'],
      pers_Nombres: json['pers_Nombres'],
      pers_Apellidos: json['pers_Apellidos'],
      pers_Telefono: json['pers_Telefono'],
      pers_Sexo: json['pers_Sexo'],
      pers_Direccion: json['pers_Direccion'],
      pers_Curriculum: json['pers_Curriculum'],
      esCi_Id: json['esCi_Id'],
      esCi_Descripcion: json['esCi_Descripcion'],
      muni_Codigo: json['muni_Codigo'],
      muni_Descripcion: json['muni_Descripcion'],
      depa_Codigo: json['depa_Codigo'],
      depa_Descripcion: json['depa_Descripcion'],
      pers_Estado: json['pers_Estado'],
      usua_Creacion: json['usua_Creacion'],
      usuaC_Nombre: json['usuaC_Nombre'],
      pers_FechaCreacion: DateTime.parse(json['pers_FechaCreacion']),
      usua_Modificacion: json['usua_Modificacion'],
      usuaM_Nombre: json['usuaM_Nombre'],
      pers_FechaModificacion: json['pers_FechaModificacion'] != null ? DateTime.parse(json['pers_FechaModificacion']) : null  ,
    );
  }
}
