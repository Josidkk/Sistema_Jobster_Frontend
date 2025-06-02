class TopPlaza {
  final String descripcion;
  final int totalSolicitudes;

  TopPlaza({
    required this.descripcion, 
    required this.totalSolicitudes
  });

  factory TopPlaza.fromJson(Map<String, dynamic> json) {
    return TopPlaza(
      descripcion: json['Plaz_Descripcion'] ?? '',
      totalSolicitudes: json['TotalSolicitudes'] ?? 0,
    );
  }
}
